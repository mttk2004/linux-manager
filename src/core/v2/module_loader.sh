#!/bin/bash

# Advanced Module Loader - V2 Architecture
# Provides consistent module loading with caching, error handling, and dependency management

# Global variables for module management
declare -A LOADED_MODULES=()
declare -A MODULE_DEPENDENCIES=()
declare -A MODULE_LOAD_TIMES=()
LOADER_DEBUG=${LOADER_DEBUG:-false}

# Module loader configuration
MODULE_CACHE_ENABLED=${MODULE_CACHE_ENABLED:-true}
MODULE_PERFORMANCE_TRACKING=${MODULE_PERFORMANCE_TRACKING:-true}

# Initialize module loader
init_module_loader() {
    local base_dir="${1:-$(dirname "$(dirname "$(dirname "${BASH_SOURCE[0]}")")")}"
    
    # Set global paths
    export LINUX_MANAGER_ROOT="$base_dir"
    export CORE_DIR="$base_dir/src/core"
    export CORE_V2_DIR="$base_dir/src/core/v2"
    export MODULES_DIR="$base_dir/src/modules"
    export DATA_DIR="$base_dir/src/data"
    export TEMPLATES_DIR="$base_dir/src/templates"
    export CONFIG_DIR="$base_dir/src/config"
    export LOGS_DIR="$base_dir/logs"
    export TESTS_DIR="$base_dir/tests"

    # Create required directories
    mkdir -p "$LOGS_DIR" "$CONFIG_DIR"
    
    # Load core error handler first
    if [[ -f "$CORE_V2_DIR/error_handler.sh" ]]; then
        source "$CORE_V2_DIR/error_handler.sh"
    fi
    
    loader_debug "Module loader initialized with base: $base_dir"
}

# Debug logging for module loader
loader_debug() {
    if [[ "$LOADER_DEBUG" == "true" ]]; then
        echo "[MODULE_LOADER DEBUG] $*" >&2
    fi
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

# Export key functions
export -f init_module_loader load_module_safe load_modules reload_module unload_module
export -f list_loaded_modules clear_module_cache module_loader_health_check load_module
