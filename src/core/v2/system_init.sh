#!/bin/bash

# System Initialization Module - V2 Architecture
# Comprehensive system startup that coordinates all V2 components
#
# @VERSION: 2.0.0
# @DESCRIPTION: Central initialization system for Linux Manager V2
# @AUTHOR: Linux Manager Team
# @LICENSE: MIT

# Define stub logging functions for testing environment
if [[ "${TESTING:-false}" == "true" ]]; then
    log_debug() { [[ "${TEST_VERBOSE:-false}" == "true" ]] && echo "[DEBUG] $*" >&2 || true; }
    log_info() { echo "[INFO] $*" >&2; }
    log_warning() { echo "[WARNING] $*" >&2; }
    log_error() { echo "[ERROR] $*" >&2; }
fi

# System initialization state
declare -g INIT_SYSTEM_READY=false
declare -g INIT_START_TIME=0
declare -g INIT_TOTAL_TIME=0
declare -g INIT_FAILED_COMPONENTS=()
declare -g INIT_SUCCESS_COMPONENTS=()

# Component initialization order and dependencies
declare -gA INIT_COMPONENTS=(
    ["directories"]="create_directories"
    ["error_handler"]="init_error_handler"
    ["logging"]="init_logging"
    ["performance"]="init_performance"
    ["config_manager"]="init_config_manager"
    ["module_loader"]="init_module_loader"
    ["module_registry"]="init_module_registry"
    ["module_communication"]="init_module_communication"
)

# Component dependency mapping
declare -gA INIT_DEPENDENCIES=(
    ["directories"]=""
    ["error_handler"]="directories"
    ["logging"]="directories,error_handler"
    ["performance"]="directories,logging"
    ["config_manager"]="directories,logging,error_handler"
    ["module_loader"]="directories,logging,error_handler,config_manager"
    ["module_registry"]="directories,logging,error_handler,config_manager"
    ["module_communication"]="directories,logging,error_handler,config_manager"
)

# Component critical status (system fails if these fail)
declare -gA INIT_CRITICAL=(
    ["directories"]="true"
    ["error_handler"]="true"
    ["logging"]="true"
    ["performance"]="false"
    ["config_manager"]="true"
    ["module_loader"]="true"
    ["module_registry"]="false"
    ["module_communication"]="false"
)

# Initialize the entire V2 system
init_v2_system() {
    log_info "SYSTEM_INIT" "Starting Linux Manager V2 system initialization"
    
    INIT_START_TIME=$(date +%s%3N)
    INIT_FAILED_COMPONENTS=()
    INIT_SUCCESS_COMPONENTS=()
    
    # Get initialization order
    local init_order
    if ! init_order=$(get_initialization_order); then
        log_error "SYSTEM_INIT" "Failed to determine initialization order"
        return 1
    fi
    
    # Initialize components in dependency order
    local total_components=0
    local successful_components=0
    local critical_failures=0
    
    while IFS= read -r component; do
        ((total_components++))
        
        log_info "SYSTEM_INIT" "Initializing component: $component"
        
        if initialize_component "$component"; then
            INIT_SUCCESS_COMPONENTS+=("$component")
            ((successful_components++))
            log_info "SYSTEM_INIT" "Component initialized successfully: $component"
        else
            INIT_FAILED_COMPONENTS+=("$component")
            log_error "SYSTEM_INIT" "Component initialization failed: $component"
            
            # Check if this is a critical component
            if [[ "${INIT_CRITICAL[$component]:-false}" == "true" ]]; then
                ((critical_failures++))
                log_error "SYSTEM_INIT" "Critical component failed: $component"
            fi
        fi
    done <<< "$init_order"
    
    # Calculate initialization time
    local init_end_time=$(date +%s%3N)
    INIT_TOTAL_TIME=$((init_end_time - INIT_START_TIME))
    
    # Determine initialization result
    if [[ $critical_failures -eq 0 ]]; then
        INIT_SYSTEM_READY=true
        log_info "SYSTEM_INIT" "System initialization completed successfully"
        log_info "SYSTEM_INIT" "Components: $successful_components/$total_components successful (${INIT_TOTAL_TIME}ms)"
        
        # Log component status
        if [[ ${#INIT_FAILED_COMPONENTS[@]} -gt 0 ]]; then
            log_warning "SYSTEM_INIT" "Non-critical components failed: ${INIT_FAILED_COMPONENTS[*]}"
        fi
        
        return 0
    else
        log_error "SYSTEM_INIT" "System initialization failed due to critical component failures"
        log_error "SYSTEM_INIT" "Failed critical components: ${INIT_FAILED_COMPONENTS[*]}"
        return 1
    fi
}

# Get component initialization order based on dependencies
get_initialization_order() {
    local -A visited=()
    local -A temp_mark=()
    local order=()
    
    # Topological sort for dependency resolution
    for component in "${!INIT_COMPONENTS[@]}"; do
        if [[ -z "${visited[$component]:-}" ]]; then
            if ! visit_component "$component" visited temp_mark order; then
                log_error "SYSTEM_INIT" "Circular dependency detected involving: $component"
                return 1
            fi
        fi
    done
    
    # Output order (reversed for proper dependency order)
    local i
    for ((i=${#order[@]}-1; i>=0; i--)); do
        echo "${order[i]}"
    done
    
    return 0
}

# Visit component for topological sort
visit_component() {
    local component="$1"
    local -n visited_ref=$2
    local -n temp_ref=$3
    local -n order_ref=$4
    
    # Check for circular dependency
    if [[ -n "${temp_ref[$component]:-}" ]]; then
        return 1
    fi
    
    # Skip if already visited
    if [[ -n "${visited_ref[$component]:-}" ]]; then
        return 0
    fi
    
    # Mark as temporarily visited
    temp_ref["$component"]=1
    
    # Visit dependencies first
    local dependencies="${INIT_DEPENDENCIES[$component]:-}"
    if [[ -n "$dependencies" ]]; then
        IFS=',' read -ra deps <<< "$dependencies"
        for dep in "${deps[@]}"; do
            dep=$(echo "$dep" | xargs)  # Trim whitespace
            if [[ -n "$dep" ]]; then
                if ! visit_component "$dep" visited_ref temp_ref order_ref; then
                    return 1
                fi
            fi
        done
    fi
    
    # Mark as permanently visited
    unset temp_ref["$component"]
    visited_ref["$component"]=1
    order_ref+=("$component")
    
    return 0
}

# Initialize a specific component
initialize_component() {
    local component="$1"
    local init_function="${INIT_COMPONENTS[$component]:-}"
    
    if [[ -z "$init_function" ]]; then
        log_error "SYSTEM_INIT" "Unknown component: $component"
        return 1
    fi
    
    # Check if dependencies are satisfied
    if ! check_component_dependencies "$component"; then
        log_error "SYSTEM_INIT" "Dependencies not satisfied for: $component"
        return 1
    fi
    
    # Execute initialization function
    local start_time=$(date +%s%3N)
    
    case "$component" in
        "directories")
            create_directories
            local result=$?
            ;;
        *)
            # Load component file if needed
            local component_file="$CORE_V2_DIR/${component}.sh"
            if [[ -f "$component_file" ]] && ! declare -f "$init_function" >/dev/null 2>&1; then
                if ! source "$component_file" 2>/dev/null; then
                    log_error "SYSTEM_INIT" "Failed to load component file: $component_file"
                    return 1
                fi
            fi
            
            # Call initialization function
            if declare -f "$init_function" >/dev/null 2>&1; then
                "$init_function" >/dev/null 2>&1
                local result=$?
            else
                log_warning "SYSTEM_INIT" "Initialization function not found: $init_function"
                local result=0  # Consider it successful if no init function
            fi
            ;;
    esac
    
    local end_time=$(date +%s%3N)
    local duration=$((end_time - start_time))
    
    if [[ $result -eq 0 ]]; then
        log_debug "SYSTEM_INIT" "Component $component initialized in ${duration}ms"
        return 0
    else
        log_error "SYSTEM_INIT" "Component $component failed to initialize (${duration}ms)"
        return 1
    fi
}

# Check if component dependencies are satisfied
check_component_dependencies() {
    local component="$1"
    local dependencies="${INIT_DEPENDENCIES[$component]:-}"
    
    if [[ -z "$dependencies" ]]; then
        return 0  # No dependencies
    fi
    
    IFS=',' read -ra deps <<< "$dependencies"
    for dep in "${deps[@]}"; do
        dep=$(echo "$dep" | xargs)  # Trim whitespace
        if [[ -n "$dep" ]]; then
            # Check if dependency was successfully initialized
            local found=false
            for success_comp in "${INIT_SUCCESS_COMPONENTS[@]}"; do
                if [[ "$success_comp" == "$dep" ]]; then
                    found=true
                    break
                fi
            done
            
            if [[ "$found" == "false" ]]; then
                log_error "SYSTEM_INIT" "Dependency not satisfied: $dep (required by $component)"
                return 1
            fi
        fi
    done
    
    return 0
}

# Create required directories
create_directories() {
    log_debug "SYSTEM_INIT" "Creating required directories..."
    
    local required_dirs=(
        "$LOGS_DIR"
        "$DATA_DIR"
        "$ROOT_DIR/config"
        "$ROOT_DIR/.cache"
        "$ROOT_DIR/backup"
        "$ROOT_DIR/data/registry"
        "$ROOT_DIR/data/messages"
        "$ROOT_DIR/.queue"
        "$HOME/.config/linux-manager"
        "$HOME/.local/share/linux-manager"
    )
    
    local created=0
    local failed=0
    
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            if mkdir -p "$dir" 2>/dev/null; then
                ((created++))
                log_debug "SYSTEM_INIT" "Created directory: $dir"
            else
                ((failed++))
                log_warning "SYSTEM_INIT" "Failed to create directory: $dir"
            fi
        fi
    done
    
    log_info "SYSTEM_INIT" "Directory creation completed: $created created, $failed failed"
    
    # Return success if at least essential directories were created
    [[ -d "$LOGS_DIR" && -d "$DATA_DIR" ]]
}

# Get system initialization status
get_init_status() {
    cat << EOF
{
    "system_ready": $INIT_SYSTEM_READY,
    "initialization_time_ms": $INIT_TOTAL_TIME,
    "total_components": ${#INIT_COMPONENTS[@]},
    "successful_components": ${#INIT_SUCCESS_COMPONENTS[@]},
    "failed_components": ${#INIT_FAILED_COMPONENTS[@]},
    "success_list": [$(printf '"%s",' "${INIT_SUCCESS_COMPONENTS[@]}" | sed 's/,$//')],
    "failure_list": [$(printf '"%s",' "${INIT_FAILED_COMPONENTS[@]}" | sed 's/,$//')],
    "critical_components": [$(for comp in "${!INIT_CRITICAL[@]}"; do [[ "${INIT_CRITICAL[$comp]}" == "true" ]] && printf '"%s",' "$comp"; done | sed 's/,$//')]
}
EOF
}

# Reinitialize a specific component
reinitialize_component() {
    local component="$1"
    
    if [[ -z "${INIT_COMPONENTS[$component]:-}" ]]; then
        log_error "SYSTEM_INIT" "Unknown component: $component"
        return 1
    fi
    
    log_info "SYSTEM_INIT" "Reinitializing component: $component"
    
    # Remove from success list if present
    local new_success=()
    for comp in "${INIT_SUCCESS_COMPONENTS[@]}"; do
        if [[ "$comp" != "$component" ]]; then
            new_success+=("$comp")
        fi
    done
    INIT_SUCCESS_COMPONENTS=("${new_success[@]}")
    
    # Remove from failure list if present
    local new_failed=()
    for comp in "${INIT_FAILED_COMPONENTS[@]}"; do
        if [[ "$comp" != "$component" ]]; then
            new_failed+=("$comp")
        fi
    done
    INIT_FAILED_COMPONENTS=("${new_failed[@]}")
    
    # Reinitialize
    if initialize_component "$component"; then
        log_info "SYSTEM_INIT" "Component reinitialized successfully: $component"
        return 0
    else
        log_error "SYSTEM_INIT" "Component reinitialization failed: $component"
        return 1
    fi
}

# Shutdown system gracefully
shutdown_v2_system() {
    log_info "SYSTEM_INIT" "Shutting down Linux Manager V2 system"
    
    # Shutdown components in reverse order
    local shutdown_order
    shutdown_order=$(get_initialization_order | tac)
    
    while IFS= read -r component; do
        shutdown_component "$component"
    done <<< "$shutdown_order"
    
    INIT_SYSTEM_READY=false
    log_info "SYSTEM_INIT" "System shutdown completed"
}

# Shutdown a specific component
shutdown_component() {
    local component="$1"
    
    log_debug "SYSTEM_INIT" "Shutting down component: $component"
    
    # Try component-specific shutdown function
    local shutdown_function="shutdown_${component}"
    if declare -f "$shutdown_function" >/dev/null 2>&1; then
        "$shutdown_function" >/dev/null 2>&1
    fi
    
    # Try generic shutdown patterns
    case "$component" in
        "module_communication")
            if declare -f "shutdown_communication" >/dev/null 2>&1; then
                shutdown_communication >/dev/null 2>&1
            fi
            ;;
        "module_registry")
            if declare -f "save_registry_data" >/dev/null 2>&1; then
                save_registry_data >/dev/null 2>&1
            fi
            ;;
    esac
    
    log_debug "SYSTEM_INIT" "Component shutdown completed: $component"
}

# System health check
system_health_check() {
    log_info "SYSTEM_INIT" "Running system health check"
    
    local issues=0
    local warnings=0
    
    # Check if system is initialized
    if [[ "$INIT_SYSTEM_READY" != "true" ]]; then
        log_error "SYSTEM_INIT" "System not properly initialized"
        ((issues++))
    fi
    
    # Check critical components
    for component in "${!INIT_CRITICAL[@]}"; do
        if [[ "${INIT_CRITICAL[$component]}" == "true" ]]; then
            local found=false
            for success_comp in "${INIT_SUCCESS_COMPONENTS[@]}"; do
                if [[ "$success_comp" == "$component" ]]; then
                    found=true
                    break
                fi
            done
            
            if [[ "$found" == "false" ]]; then
                log_error "SYSTEM_INIT" "Critical component not initialized: $component"
                ((issues++))
            fi
        fi
    done
    
    # Check failed components
    for component in "${INIT_FAILED_COMPONENTS[@]}"; do
        if [[ "${INIT_CRITICAL[$component]:-false}" == "true" ]]; then
            ((issues++))
        else
            ((warnings++))
        fi
    done
    
    # Report results
    if [[ $issues -eq 0 ]]; then
        log_info "SYSTEM_INIT" "System health check passed"
        if [[ $warnings -gt 0 ]]; then
            log_warning "SYSTEM_INIT" "System health check passed with $warnings warnings"
        fi
        return 0
    else
        log_error "SYSTEM_INIT" "System health check failed with $issues critical issues and $warnings warnings"
        return 1
    fi
}

# Export system initialization functions
export -f init_v2_system get_initialization_order visit_component
export -f initialize_component check_component_dependencies create_directories
export -f get_init_status reinitialize_component shutdown_v2_system
export -f shutdown_component system_health_check
