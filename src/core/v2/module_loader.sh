#!/bin/bash

# Enhanced Module Loader - V2 Architecture
# Provides sophisticated module loading with dependency resolution, lazy loading, and error recovery
#
# Features:
# - Dynamic module discovery and loading
# - Dependency resolution with circular detection
# - Lazy loading and on-demand module initialization
# - Module health monitoring and error recovery
# - Performance tracking and caching
# - Version compatibility checking
# - Plugin architecture support

# Define stub logging functions for testing environment
if [[ "${TESTING:-false}" == "true" ]]; then
    log_debug() { [[ "${TEST_VERBOSE:-false}" == "true" ]] && echo "[DEBUG] $*" >&2 || true; }
    log_info() { echo "[INFO] $*" >&2; }
    log_warning() { echo "[WARNING] $*" >&2; }
    log_error() { echo "[ERROR] $*" >&2; }
fi

# Enhanced global variables for module management
declare -A LOADED_MODULES=()
declare -A MODULE_DEPENDENCIES=()
declare -A MODULE_LOAD_TIMES=()
declare -A MODULE_REGISTRY=()
declare -A MODULE_STATUS=()
declare -A MODULE_METADATA=()
declare -A MODULE_ERROR_COUNT=()
declare -A MODULE_HEALTH_STATUS=()
declare -A MODULE_LOAD_ORDER=()

# Module loading states
declare -r MODULE_STATE_UNLOADED="unloaded"
declare -r MODULE_STATE_LOADING="loading"
declare -r MODULE_STATE_LOADED="loaded"
declare -r MODULE_STATE_ACTIVE="active"
declare -r MODULE_STATE_ERROR="error"
declare -r MODULE_STATE_DISABLED="disabled"

# Enhanced module loader configuration
LOADER_DEBUG=${LOADER_DEBUG:-false}
MODULE_CACHE_ENABLED=${MODULE_CACHE_ENABLED:-true}
MODULE_PERFORMANCE_TRACKING=${MODULE_PERFORMANCE_TRACKING:-true}
MODULE_LAZY_LOADING=${MODULE_LAZY_LOADING:-true}
MODULE_MAX_LOAD_ATTEMPTS=${MODULE_MAX_LOAD_ATTEMPTS:-3}
MODULE_LOAD_TIMEOUT=${MODULE_LOAD_TIMEOUT:-30}
MODULE_HEALTH_CHECK_INTERVAL=${MODULE_HEALTH_CHECK_INTERVAL:-300}  # 5 minutes

# Initialize enhanced module loader
init_module_loader() {
    local base_dir="${1:-$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")}"
    
    log_info "MODULE_LOADER" "Initializing enhanced module loading system..."
    
    # Set global paths (avoid conflicts with readonly variables from main script)
    export LINUX_MANAGER_ROOT="$base_dir"
    
    # Use existing readonly variables if already set, otherwise set them
    if [[ -z "${CORE_DIR:-}" ]]; then
        export CORE_DIR="$base_dir/src/core"
    fi
    
    if [[ -z "${CORE_V2_DIR:-}" ]]; then
        export CORE_V2_DIR="$base_dir/src/core/v2"
    fi
    
    if [[ -z "${MODULES_DIR:-}" ]]; then
        export MODULES_DIR="$base_dir/src/modules"
    fi
    
    if [[ -z "${DATA_DIR:-}" ]]; then
        export DATA_DIR="$base_dir/src/data"
    fi
    
    if [[ -z "${LOGS_DIR:-}" ]]; then
        export LOGS_DIR="$base_dir/logs"
    fi
    
    # Set module-loader specific paths
    export TEMPLATES_DIR="$base_dir/src/templates"
    export CONFIG_DIR="$base_dir/src/config"
    export TESTS_DIR="$base_dir/tests"
    export MODULES_PLUGINS_DIR="$base_dir/plugins"
    export MODULES_USER_DIR="${HOME}/.local/share/linux-manager/modules"

    # Create required directories
    mkdir -p "$LOGS_DIR" "$CONFIG_DIR" "$MODULES_PLUGINS_DIR" "$MODULES_USER_DIR"
    
    # Load core error handler first
    if [[ -f "$CORE_V2_DIR/error_handler.sh" ]]; then
        source "$CORE_V2_DIR/error_handler.sh"
    fi
    
    # Clear any existing state
    clear_module_state
    
    # Discover available modules
    discover_modules
    
    # Load core modules first
    load_core_modules
    
    # Initialize health monitoring if enabled
    if [[ "$(get_config "MODULE_HEALTH_MONITORING" "true" 2>/dev/null || echo "true")" == "true" ]]; then
        start_health_monitoring
    fi
    
    log_info "MODULE_LOADER" "Enhanced module loading system initialized with base: $base_dir"
}

# Clear module loading state
clear_module_state() {
    log_debug "MODULE_LOADER" "Clearing module state..."
    
    LOADED_MODULES=()
    MODULE_DEPENDENCIES=()
    MODULE_LOAD_TIMES=()
    MODULE_REGISTRY=()
    MODULE_STATUS=()
    MODULE_METADATA=()
    MODULE_ERROR_COUNT=()
    MODULE_HEALTH_STATUS=()
    MODULE_LOAD_ORDER=()
}

# Discover all available modules
discover_modules() {
    log_debug "MODULE_LOADER" "Discovering available modules..."
    
    local module_count=0
    
    # Discover core modules
    module_count=$((module_count + $(discover_modules_in_directory "$CORE_DIR" "core")))
    module_count=$((module_count + $(discover_modules_in_directory "$CORE_V2_DIR" "core-v2")))
    
    # Discover standard modules
    module_count=$((module_count + $(discover_modules_in_directory "$MODULES_DIR" "standard")))
    
    # Discover plugin modules
    if [[ -d "$MODULES_PLUGINS_DIR" ]]; then
        module_count=$((module_count + $(discover_modules_in_directory "$MODULES_PLUGINS_DIR" "plugin")))
    fi
    
    # Discover user modules
    if [[ -d "$MODULES_USER_DIR" ]]; then
        module_count=$((module_count + $(discover_modules_in_directory "$MODULES_USER_DIR" "user")))
    fi
    
    log_info "MODULE_LOADER" "Discovered $module_count modules"
    return 0
}

# Discover modules in a specific directory
discover_modules_in_directory() {
    local search_dir="$1"
    local module_type="$2"
    local count=0
    
    if [[ ! -d "$search_dir" ]]; then
        echo 0
        return 0
    fi
    
    # Find all .sh files and module directories
    while IFS= read -r -d '' item; do
        local module_name
        local entry_point
        
        if [[ -f "$item" && "$item" =~ \.sh$ ]]; then
            # Single .sh file
            module_name=$(basename "$item" .sh)
            entry_point="$item"
        elif [[ -d "$item" ]]; then
            # Module directory
            module_name=$(basename "$item")
            
            # Look for module entry point
            if [[ -f "$item/manager.sh" ]]; then
                entry_point="$item/manager.sh"
            elif [[ -f "$item/module.sh" ]]; then
                entry_point="$item/module.sh"
            elif [[ -f "$item/$module_name.sh" ]]; then
                entry_point="$item/$module_name.sh"
            else
                continue  # No valid entry point
            fi
        else
            continue
        fi
        
        # Skip if already registered
        [[ -n "${MODULE_REGISTRY[$module_name]:-}" ]] && continue
        
        # Register the module
        register_module "$module_name" "$entry_point" "$module_type"
        ((count++))
        
    done < <(find "$search_dir" -maxdepth 2 \( -name "*.sh" -o -type d \) -print0 2>/dev/null)
    
    echo $count
}

# Register a discovered module
register_module() {
    local module_name="$1"
    local entry_point="$2"
    local module_type="$3"
    
    log_debug "MODULE_LOADER" "Registering module: $module_name ($module_type)"
    
    MODULE_REGISTRY["$module_name"]="$entry_point"
    MODULE_STATUS["$module_name"]="$MODULE_STATE_UNLOADED"
    MODULE_ERROR_COUNT["$module_name"]=0
    
    # Extract module metadata
    extract_module_metadata "$module_name" "$entry_point" "$module_type"
}

# Extract module metadata from the module file
extract_module_metadata() {
    local module_name="$1"
    local entry_point="$2"
    local module_type="$3"
    
    local version="1.0.0"
    local description="Module: $module_name"
    local dependencies=""
    local author=""
    local license=""
    
    if [[ -f "$entry_point" ]]; then
        # Parse metadata from file header comments
        while IFS= read -r line; do
            if [[ "$line" =~ ^#[[:space:]]*@([A-Z_]+):[[:space:]]*(.+)$ ]]; then
                local key="${BASH_REMATCH[1]}"
                local value="${BASH_REMATCH[2]}"
                
                case "$key" in
                    "VERSION") version="$value" ;;
                    "DESCRIPTION") description="$value" ;;
                    "DEPENDS") dependencies="$value" ;;
                    "AUTHOR") author="$value" ;;
                    "LICENSE") license="$value" ;;
                esac
            elif [[ "$line" =~ ^[[:space:]]*$ ]] || [[ ! "$line" =~ ^# ]]; then
                # Stop at first non-comment line
                break
            fi
        done < <(head -20 "$entry_point")
    fi
    
    # Store metadata
    MODULE_METADATA["$module_name"]="type:$module_type,version:$version,description:$description,dependencies:$dependencies,author:$author,license:$license"
    
    # Store dependencies separately for easier access
    if [[ -n "$dependencies" ]]; then
        MODULE_DEPENDENCIES["$module_name"]="$dependencies"
    fi
    
    log_debug "MODULE_LOADER" "Module $module_name metadata: version=$version, dependencies=$dependencies"
}

# Load core modules in the correct order
load_core_modules() {
    log_info "MODULE_LOADER" "Loading core modules..."
    
    # Define core module loading order
    local core_modules=(
        "config_manager"   # Configuration system 
        "logging"          # Logging system  
        "performance"      # Performance monitoring
        "cache"            # Caching system
        "ui"               # User interface components
        "utils"            # Utility functions
    )
    
    for module in "${core_modules[@]}"; do
        if [[ -n "${MODULE_REGISTRY[$module]:-}" ]]; then
            load_module_enhanced "$module" true
        else
            log_debug "MODULE_LOADER" "Core module not found: $module"
        fi
    done
}

# Debug logging for module loader
loader_debug() {
    if [[ "$LOADER_DEBUG" == "true" ]]; then
        echo "[MODULE_LOADER DEBUG] $*" >&2
    fi
}

# Enhanced module loading with dependency resolution
load_module_enhanced() {
    local module_name="$1"
    local force_load="${2:-false}"
    
    # Check if module exists
    if [[ -z "${MODULE_REGISTRY[$module_name]:-}" ]]; then
        log_error "MODULE_LOADER" "Module not found: $module_name"
        return 1
    fi
    
    # Check current status
    local current_status="${MODULE_STATUS[$module_name]}"
    
    # Skip if already loaded (unless forced)
    if [[ "$current_status" == "$MODULE_STATE_LOADED" || "$current_status" == "$MODULE_STATE_ACTIVE" ]]; then
        if [[ "$force_load" != "true" ]]; then
            log_debug "MODULE_LOADER" "Module already loaded: $module_name"
            return 0
        fi
    fi
    
    # Check if loading
    if [[ "$current_status" == "$MODULE_STATE_LOADING" ]]; then
        log_warning "MODULE_LOADER" "Module is already being loaded: $module_name"
        return 1
    fi
    
    # Check if disabled
    if [[ "$current_status" == "$MODULE_STATE_DISABLED" ]]; then
        log_warning "MODULE_LOADER" "Module is disabled: $module_name"
        return 1
    fi
    
    # Check error count
    local error_count="${MODULE_ERROR_COUNT[$module_name]}"
    if [[ $error_count -ge $MODULE_MAX_LOAD_ATTEMPTS ]]; then
        log_error "MODULE_LOADER" "Module has exceeded max load attempts: $module_name"
        MODULE_STATUS["$module_name"]="$MODULE_STATE_ERROR"
        return 1
    fi
    
    log_info "MODULE_LOADER" "Loading module: $module_name"
    
    # Set loading status
    MODULE_STATUS["$module_name"]="$MODULE_STATE_LOADING"
    
    # Load dependencies first
    if ! load_module_dependencies_enhanced "$module_name"; then
        log_error "MODULE_LOADER" "Failed to load dependencies for module: $module_name"
        MODULE_STATUS["$module_name"]="$MODULE_STATE_ERROR"
        ((MODULE_ERROR_COUNT["$module_name"]++))
        return 1
    fi
    
    # Load the module file using existing function
    local entry_point="${MODULE_REGISTRY[$module_name]}"
    if load_module_file_enhanced "$module_name" "$entry_point"; then
        MODULE_STATUS["$module_name"]="$MODULE_STATE_LOADED"
        
        # Add to loaded modules tracking
        local module_key="$(get_module_key "$entry_point")"
        LOADED_MODULES["$module_key"]="$entry_point"
        
        # Initialize module if it has an init function
        initialize_module_enhanced "$module_name"
        
        log_info "MODULE_LOADER" "Successfully loaded module: $module_name"
        return 0
    else
        MODULE_STATUS["$module_name"]="$MODULE_STATE_ERROR"
        ((MODULE_ERROR_COUNT["$module_name"]++))
        log_error "MODULE_LOADER" "Failed to load module: $module_name"
        return 1
    fi
}

# Enhanced dependency loading with circular detection
load_module_dependencies_enhanced() {
    local module_name="$1"
    local dependencies="${MODULE_DEPENDENCIES[$module_name]:-}"
    
    if [[ -z "$dependencies" ]]; then
        return 0
    fi
    
    log_debug "MODULE_LOADER" "Loading dependencies for $module_name: $dependencies"
    
    # Parse dependencies (comma-separated)
    IFS=',' read -ra dep_array <<< "$dependencies"
    
    for dep in "${dep_array[@]}"; do
        # Trim whitespace
        dep=$(echo "$dep" | xargs)
        
        # Check for circular dependency
        if check_circular_dependency "$module_name" "$dep"; then
            log_error "MODULE_LOADER" "Circular dependency detected: $module_name -> $dep"
            return 1
        fi
        
        # Load dependency
        if ! load_module_enhanced "$dep"; then
            log_error "MODULE_LOADER" "Failed to load dependency '$dep' for module '$module_name'"
            return 1
        fi
    done
    
    return 0
}

# Check for circular dependencies
check_circular_dependency() {
    local module_name="$1"
    local dependency="$2"
    local visited="${3:-}"
    
    # Add current module to visited list
    if [[ -z "$visited" ]]; then
        visited="$module_name"
    else
        visited="$visited,$module_name"
    fi
    
    # Check if dependency depends on any module in the visited chain
    local dep_dependencies="${MODULE_DEPENDENCIES[$dependency]:-}"
    if [[ -n "$dep_dependencies" ]]; then
        IFS=',' read -ra dep_array <<< "$dep_dependencies"
        
        for dep in "${dep_array[@]}"; do
            dep=$(echo "$dep" | xargs)
            
            # Check if this dependency is in our visited chain
            if [[ ",$visited," =~ ,$dep, ]]; then
                return 0  # Circular dependency found
            fi
            
            # Recursively check this dependency
            if check_circular_dependency "$module_name" "$dep" "$visited"; then
                return 0  # Circular dependency found in deeper chain
            fi
        done
    fi
    
    return 1  # No circular dependency
}

# Enhanced module file loading
load_module_file_enhanced() {
    local module_name="$1"
    local entry_point="$2"
    
    if [[ ! -f "$entry_point" ]]; then
        log_error "MODULE_LOADER" "Module file not found: $entry_point"
        return 1
    fi
    
    log_debug "MODULE_LOADER" "Loading module file: $entry_point"
    
    # Check syntax before loading
    if ! bash -n "$entry_point" 2>/dev/null; then
        log_error "MODULE_LOADER" "Module has syntax errors: $entry_point"
        return 1
    fi
    
    # Load with performance tracking
    local start_time
    start_time=$(date +%s%3N)
    
    if timeout "$MODULE_LOAD_TIMEOUT" bash -c "source '$entry_point'" 2>/dev/null; then
        local end_time
        end_time=$(date +%s%3N)
        local load_time=$((end_time - start_time))
        
        MODULE_LOAD_TIMES["$module_name"]="$load_time"
        log_debug "MODULE_LOADER" "Module loaded in ${load_time}ms: $module_name"
        return 0
    else
        log_error "MODULE_LOADER" "Failed to source module file: $entry_point"
        return 1
    fi
}

# Initialize a loaded module
initialize_module_enhanced() {
    local module_name="$1"
    
    # Check if module has an initialization function
    local init_function="init_${module_name}_module"
    
    if declare -f "$init_function" >/dev/null 2>&1; then
        log_debug "MODULE_LOADER" "Initializing module: $module_name"
        
        if "$init_function"; then
            MODULE_STATUS["$module_name"]="$MODULE_STATE_ACTIVE"
            log_debug "MODULE_LOADER" "Module initialized: $module_name"
        else
            log_warning "MODULE_LOADER" "Module initialization failed: $module_name"
            # Module is loaded but not active
        fi
    else
        # No init function, consider module active
        MODULE_STATUS["$module_name"]="$MODULE_STATE_ACTIVE"
    fi
}

# Start health monitoring for modules
start_health_monitoring() {
    log_debug "MODULE_LOADER" "Starting module health monitoring..."
    # This would typically start a background process for health checks
    # For now, we'll just log that it's enabled
    MODULE_HEALTH_MONITORING_ENABLED=true
}

# Check if module is already loaded
is_module_loaded() {
    local module_key="$1"
    [[ -n "${LOADED_MODULES[$module_key]}" ]]
}

# Get module key from path
get_module_key() {
    local module_path="$1"
    echo "${module_path}" | sed 's|/|_|g' | sed 's|\.sh$||'
}

# Resolve module path
resolve_module_path() {
    local module_spec="$1"
    local resolved_path=""
    
    # If it's already a full path and exists
    if [[ -f "$module_spec" ]]; then
        resolved_path="$module_spec"
    # Try relative to modules directory
    elif [[ -f "$MODULES_DIR/$module_spec" ]]; then
        resolved_path="$MODULES_DIR/$module_spec"
    # Try relative to core directory  
    elif [[ -f "$CORE_DIR/$module_spec" ]]; then
        resolved_path="$CORE_DIR/$module_spec"
    # Try relative to core v2 directory
    elif [[ -f "$CORE_V2_DIR/$module_spec" ]]; then
        resolved_path="$CORE_V2_DIR/$module_spec"
    # Try adding .sh extension
    elif [[ -f "$MODULES_DIR/$module_spec.sh" ]]; then
        resolved_path="$MODULES_DIR/$module_spec.sh"
    else
        return 1
    fi
    
    echo "$resolved_path"
}

# Load module dependencies
load_module_dependencies() {
    local module_path="$1"
    local deps_file="$(dirname "$module_path")/.dependencies"
    
    if [[ -f "$deps_file" ]]; then
        local module_name="$(basename "$module_path")"
        loader_debug "Loading dependencies for $module_name"
        
        while IFS= read -r dep_line; do
            # Skip comments and empty lines
            [[ "$dep_line" =~ ^[[:space:]]*# ]] && continue
            [[ -z "${dep_line// }" ]] && continue
            
            local dep_module="${dep_line// }"
            loader_debug "Loading dependency: $dep_module"
            
            if ! load_module_safe "$dep_module"; then
                handle_error 1 "Failed to load dependency: $dep_module" "MODULE_LOADER"
                return 1
            fi
        done < "$deps_file"
    fi
}

# Measure module load performance
measure_module_load() {
    local module_path="$1"
    local start_time end_time duration
    
    if [[ "$MODULE_PERFORMANCE_TRACKING" == "true" ]]; then
        start_time=$(date +%s%N)
    fi
    
    # Source the module
    source "$module_path"
    local result=$?
    
    if [[ "$MODULE_PERFORMANCE_TRACKING" == "true" ]]; then
        end_time=$(date +%s%N)
        duration=$(( (end_time - start_time) / 1000000 ))
        MODULE_LOAD_TIMES["$(basename "$module_path")"]="$duration"
        loader_debug "Module $(basename "$module_path") loaded in ${duration}ms"
    fi
    
    return $result
}

# Load module with full error handling and caching
load_module_safe() {
    local module_spec="$1"
    local force_reload="${2:-false}"
    
    # Resolve module path
    local module_path
    if ! module_path="$(resolve_module_path "$module_spec")"; then
        handle_error 2 "Module not found: $module_spec" "MODULE_LOADER"
        return 2
    fi
    
    local module_key="$(get_module_key "$module_path")"
    
    # Check cache if enabled
    if [[ "$MODULE_CACHE_ENABLED" == "true" && "$force_reload" != "true" ]]; then
        if is_module_loaded "$module_key"; then
            loader_debug "Module already loaded (cached): $module_spec"
            return 0
        fi
    fi
    
    loader_debug "Loading module: $module_spec -> $module_path"
    
    # Load dependencies first
    if ! load_module_dependencies "$module_path"; then
        handle_error 3 "Failed to load dependencies for: $module_spec" "MODULE_LOADER"
        return 3
    fi
    
    # Validate file is readable
    if [[ ! -r "$module_path" ]]; then
        handle_error 4 "Module not readable: $module_path" "MODULE_LOADER" 
        return 4
    fi
    
    # Check syntax before loading
    if ! bash -n "$module_path" 2>/dev/null; then
        handle_error 5 "Module has syntax errors: $module_path" "MODULE_LOADER"
        return 5
    fi
    
    # Load the module with performance tracking
    if measure_module_load "$module_path"; then
        LOADED_MODULES["$module_key"]="$module_path"
        loader_debug "Successfully loaded module: $module_spec"
        return 0
    else
        handle_error 6 "Failed to source module: $module_path" "MODULE_LOADER"
        return 6
    fi
}

# Load multiple modules
load_modules() {
    local modules=("$@")
    local failed_modules=()
    local success_count=0
    
    for module in "${modules[@]}"; do
        if load_module_safe "$module"; then
            ((success_count++))
        else
            failed_modules+=("$module")
        fi
    done
    
    if [[ ${#failed_modules[@]} -gt 0 ]]; then
        handle_error 7 "Failed to load modules: ${failed_modules[*]}" "MODULE_LOADER"
        return 7
    fi
    
    loader_debug "Successfully loaded $success_count modules"
    return 0
}

# Reload module (bypass cache)
reload_module() {
    local module_spec="$1"
    load_module_safe "$module_spec" true
}

# Unload module (remove from cache)
unload_module() {
    local module_spec="$1"
    local module_path
    
    if module_path="$(resolve_module_path "$module_spec")"; then
        local module_key="$(get_module_key "$module_path")"
        unset LOADED_MODULES["$module_key"]
        loader_debug "Unloaded module: $module_spec"
    fi
}

# List loaded modules
list_loaded_modules() {
    local format="${1:-simple}" # simple, detailed, performance
    
    case "$format" in
        "detailed")
            echo "=== Loaded Modules ==="
            for key in "${!LOADED_MODULES[@]}"; do
                echo "  $key -> ${LOADED_MODULES[$key]}"
            done
            ;;
        "performance") 
            echo "=== Module Load Performance ==="
            for module in "${!MODULE_LOAD_TIMES[@]}"; do
                echo "  $module: ${MODULE_LOAD_TIMES[$module]}ms"
            done
            ;;
        *)
            echo "Loaded modules: ${#LOADED_MODULES[@]}"
            printf '  %s\n' "${!LOADED_MODULES[@]}"
            ;;
    esac
}

# Clear module cache
clear_module_cache() {
    LOADED_MODULES=()
    MODULE_LOAD_TIMES=()
    loader_debug "Module cache cleared"
}

# Module loader health check
module_loader_health_check() {
    local issues=()
    
    # Check if core directories exist
    [[ ! -d "$CORE_DIR" ]] && issues+=("CORE_DIR not found: $CORE_DIR")
    [[ ! -d "$MODULES_DIR" ]] && issues+=("MODULES_DIR not found: $MODULES_DIR")
    
    # Check permissions
    [[ ! -w "$LOGS_DIR" ]] && issues+=("LOGS_DIR not writable: $LOGS_DIR")
    
    # Report issues
    if [[ ${#issues[@]} -gt 0 ]]; then
        handle_error 8 "Module loader health check failed: ${issues[*]}" "MODULE_LOADER"
        return 1
    fi
    
    echo "Module loader health check: OK"
    return 0
}

# Legacy compatibility wrapper
load_module() {
    load_module_safe "$@"
}

# Enhanced module management functions

# Get enhanced module status
get_module_status_enhanced() {
    local module_name="$1"
    echo "${MODULE_STATUS[$module_name]:-unknown}"
}

# Get comprehensive module information
get_module_info_enhanced() {
    local module_name="$1"
    
    if [[ -z "${MODULE_REGISTRY[$module_name]:-}" ]]; then
        return 1
    fi
    
    local metadata="${MODULE_METADATA[$module_name]:-}"
    local status="${MODULE_STATUS[$module_name]:-unknown}"
    local load_time="${MODULE_LOAD_TIMES[$module_name]:-0}"
    local error_count="${MODULE_ERROR_COUNT[$module_name]:-0}"
    local entry_point="${MODULE_REGISTRY[$module_name]}"
    
    echo "name:$module_name,status:$status,entry_point:$entry_point,load_time:${load_time}ms,error_count:$error_count,$metadata"
}

# List modules with enhanced filtering
list_modules_enhanced() {
    local filter="${1:-all}"  # all, loaded, unloaded, error, active, core, plugin
    
    for module_name in "${!MODULE_REGISTRY[@]}"; do
        local status="${MODULE_STATUS[$module_name]}"
        local metadata="${MODULE_METADATA[$module_name]:-}"
        local module_type="${metadata##*type:}"
        module_type="${module_type%%,*}"
        
        case "$filter" in
            "all")
                echo "$module_name:$status:$module_type"
                ;;
            "loaded")
                if [[ "$status" == "$MODULE_STATE_LOADED" || "$status" == "$MODULE_STATE_ACTIVE" ]]; then
                    echo "$module_name:$status:$module_type"
                fi
                ;;
            "unloaded")
                if [[ "$status" == "$MODULE_STATE_UNLOADED" ]]; then
                    echo "$module_name:$status:$module_type"
                fi
                ;;
            "error")
                if [[ "$status" == "$MODULE_STATE_ERROR" ]]; then
                    echo "$module_name:$status:$module_type"
                fi
                ;;
            "active")
                if [[ "$status" == "$MODULE_STATE_ACTIVE" ]]; then
                    echo "$module_name:$status:$module_type"
                fi
                ;;
            "core")
                if [[ "$module_type" =~ ^core ]]; then
                    echo "$module_name:$status:$module_type"
                fi
                ;;
            "plugin")
                if [[ "$module_type" == "plugin" ]]; then
                    echo "$module_name:$status:$module_type"
                fi
                ;;
        esac
    done | sort
}

# Check if module is loaded (enhanced)
is_module_loaded_enhanced() {
    local module_name="$1"
    local status="${MODULE_STATUS[$module_name]:-unknown}"
    
    [[ "$status" == "$MODULE_STATE_LOADED" || "$status" == "$MODULE_STATE_ACTIVE" ]]
}

# Unload module (enhanced)
unload_module_enhanced() {
    local module_name="$1"
    
    if [[ -z "${MODULE_REGISTRY[$module_name]:-}" ]]; then
        log_error "MODULE_LOADER" "Module not found: $module_name"
        return 1
    fi
    
    log_info "MODULE_LOADER" "Unloading module: $module_name"
    
    # Check if module has a cleanup function
    local cleanup_function="cleanup_${module_name}_module"
    
    if declare -f "$cleanup_function" >/dev/null 2>&1; then
        log_debug "MODULE_LOADER" "Running cleanup for module: $module_name"
        "$cleanup_function"
    fi
    
    # Update status
    MODULE_STATUS["$module_name"]="$MODULE_STATE_UNLOADED"
    
    # Remove from loaded modules tracking
    local entry_point="${MODULE_REGISTRY[$module_name]}"
    local module_key="$(get_module_key "$entry_point")"
    unset LOADED_MODULES["$module_key"]
    
    log_info "MODULE_LOADER" "Module unloaded: $module_name"
}

# Reload module (enhanced)
reload_module_enhanced() {
    local module_name="$1"
    
    log_info "MODULE_LOADER" "Reloading module: $module_name"
    
    # Unload first
    unload_module_enhanced "$module_name"
    
    # Load again
    load_module_enhanced "$module_name" true
}

# Enable/disable module
enable_module() {
    local module_name="$1"
    
    if [[ -z "${MODULE_REGISTRY[$module_name]:-}" ]]; then
        log_error "MODULE_LOADER" "Module not found: $module_name"
        return 1
    fi
    
    if [[ "${MODULE_STATUS[$module_name]}" == "$MODULE_STATE_DISABLED" ]]; then
        MODULE_STATUS["$module_name"]="$MODULE_STATE_UNLOADED"
        log_info "MODULE_LOADER" "Module enabled: $module_name"
    else
        log_info "MODULE_LOADER" "Module is already enabled: $module_name"
    fi
}

disable_module() {
    local module_name="$1"
    
    if [[ -z "${MODULE_REGISTRY[$module_name]:-}" ]]; then
        log_error "MODULE_LOADER" "Module not found: $module_name"
        return 1
    fi
    
    # Unload if currently loaded
    if is_module_loaded_enhanced "$module_name"; then
        unload_module_enhanced "$module_name"
    fi
    
    MODULE_STATUS["$module_name"]="$MODULE_STATE_DISABLED"
    log_info "MODULE_LOADER" "Module disabled: $module_name"
}

# Module health check
check_module_health() {
    local module_name="$1"
    
    if [[ -z "${MODULE_REGISTRY[$module_name]:-}" ]]; then
        return 1
    fi
    
    local status="${MODULE_STATUS[$module_name]}"
    local entry_point="${MODULE_REGISTRY[$module_name]}"
    local health_status="healthy"
    
    # Check if file still exists
    if [[ ! -f "$entry_point" ]]; then
        health_status="missing_file"
    # Check if module is in error state
    elif [[ "$status" == "$MODULE_STATE_ERROR" ]]; then
        health_status="error"
    # Check if module has too many errors
    elif [[ "${MODULE_ERROR_COUNT[$module_name]}" -gt 0 ]]; then
        health_status="degraded"
    fi
    
    MODULE_HEALTH_STATUS["$module_name"]="$health_status"
    echo "$health_status"
}

# Get module dependencies
get_module_dependencies() {
    local module_name="$1"
    echo "${MODULE_DEPENDENCIES[$module_name]:-}"
}

# Get modules that depend on a given module
get_dependent_modules() {
    local target_module="$1"
    local dependents=()
    
    for module_name in "${!MODULE_DEPENDENCIES[@]}"; do
        local dependencies="${MODULE_DEPENDENCIES[$module_name]}"
        if [[ ",$dependencies," =~ ,$target_module, ]]; then
            dependents+=("$module_name")
        fi
    done
    
    printf '%s\n' "${dependents[@]}"
}

# Export enhanced functions
export -f init_module_loader load_module_safe load_modules reload_module unload_module
export -f list_loaded_modules clear_module_cache module_loader_health_check load_module
export -f load_module_enhanced load_module_dependencies_enhanced check_circular_dependency
export -f load_module_file_enhanced initialize_module_enhanced start_health_monitoring
export -f get_module_status_enhanced get_module_info_enhanced list_modules_enhanced
export -f is_module_loaded_enhanced unload_module_enhanced reload_module_enhanced
export -f enable_module disable_module check_module_health get_module_dependencies
export -f get_dependent_modules discover_modules register_module extract_module_metadata
