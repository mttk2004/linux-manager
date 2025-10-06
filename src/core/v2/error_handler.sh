#!/bin/bash

# Advanced Error Handling Framework - V2 Architecture
# Provides centralized error handling, reporting, and recovery mechanisms

# Error handling configuration
ERROR_HANDLER_ENABLED=${ERROR_HANDLER_ENABLED:-true}
ERROR_LOG_STRUCTURED=${ERROR_LOG_STRUCTURED:-true}
ERROR_AUTO_RECOVERY=${ERROR_AUTO_RECOVERY:-false}
ERROR_STACK_TRACE=${ERROR_STACK_TRACE:-true}

# Error severity levels
declare -A ERROR_LEVELS=(
    [TRACE]=0
    [DEBUG]=1
    [INFO]=2
    [WARN]=3
    [ERROR]=4
    [FATAL]=5
)

# Error recovery strategies
declare -A RECOVERY_STRATEGIES=()

# Error statistics
declare -A ERROR_STATS=()

# Initialize error handler
init_error_handler() {
    # Set up error trapping
    if [[ "$ERROR_HANDLER_ENABLED" == "true" ]]; then
        set -eE  # Exit on errors and inherit traps
        trap 'handle_unexpected_error $? $LINENO ${BASH_SOURCE[0]} "${BASH_COMMAND}"' ERR
        trap 'cleanup_on_exit' EXIT
    fi
    
    # Initialize error statistics
    ERROR_STATS[total_errors]=0
    ERROR_STATS[handled_errors]=0
    ERROR_STATS[unhandled_errors]=0
    
    error_debug "Error handler initialized"
}

# Debug logging for error handler
error_debug() {
    if [[ "${LOADER_DEBUG:-false}" == "true" ]]; then
        echo "[ERROR_HANDLER DEBUG] $*" >&2
    fi
}

# Generate error ID for tracking
generate_error_id() {
    echo "ERR_$(date +%Y%m%d_%H%M%S)_$$_${RANDOM}"
}

# Get current call stack
get_call_stack() {
    local stack=""
    local i=1
    
    while [[ "${BASH_SOURCE[$i]}" != "" ]]; do
        if [[ $i -gt 1 ]]; then
            stack+=" -> "
        fi
        stack+="$(basename "${BASH_SOURCE[$i]}"):${BASH_LINENO[$((i-1))]}"
        ((i++))
    done
    
    echo "$stack"
}

# Format error message for different outputs
format_error_message() {
    local error_code="$1"
    local error_message="$2"
    local context="$3"
    local error_id="$4"
    local format="${5:-user}" # user, log, json
    
    case "$format" in
        "json")
            local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
            local stack=""
            if [[ "$ERROR_STACK_TRACE" == "true" ]]; then
                stack=",\"stack\":\"$(get_call_stack)\""
            fi
            
            echo "{\"timestamp\":\"$timestamp\",\"level\":\"ERROR\",\"code\":$error_code,\"message\":\"$error_message\",\"context\":\"$context\",\"error_id\":\"$error_id\"$stack}"
            ;;
        "log")
            local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
            echo "[$timestamp] [ERROR] [$context] [ID:$error_id] Code:$error_code - $error_message"
            if [[ "$ERROR_STACK_TRACE" == "true" ]]; then
                echo "  Stack: $(get_call_stack)"
            fi
            ;;
        *)
            # User-friendly format (Vietnamese)
            if [[ -n "${LIGHT_RED:-}" ]]; then
                echo -e "${LIGHT_RED}✗ Lỗi${NC}: $error_message"
                if [[ "$LOADER_DEBUG" == "true" ]]; then
                    echo -e "${GRAY}  Mã lỗi: $error_code | Ngữ cảnh: $context | ID: $error_id${NC}"
                fi
            else
                echo "✗ Lỗi: $error_message"
            fi
            ;;
    esac
}

# Log error to appropriate destinations
log_error_message() {
    local error_code="$1"
    local error_message="$2" 
    local context="$3"
    local error_id="$4"
    
    # Log to file (structured if enabled)
    if [[ -n "${LOG_FILE:-}" ]]; then
        local log_format="log"
        if [[ "$ERROR_LOG_STRUCTURED" == "true" ]]; then
            log_format="json"
        fi
        
        format_error_message "$error_code" "$error_message" "$context" "$error_id" "$log_format" >> "$LOG_FILE"
    fi
    
    # Log to system logger if available
    if command -v logger >/dev/null 2>&1; then
        logger -t "linux-manager" -p user.error "[$context] Code:$error_code - $error_message (ID:$error_id)"
    fi
}

# Attempt error recovery
attempt_error_recovery() {
    local error_code="$1"
    local context="$2"
    local recovery_key="$context:$error_code"
    
    if [[ "$ERROR_AUTO_RECOVERY" != "true" ]]; then
        return 1
    fi
    
    # Check if there's a recovery strategy
    if [[ -n "${RECOVERY_STRATEGIES[$recovery_key]:-}" ]]; then
        error_debug "Attempting recovery for $recovery_key"
        
        # Execute recovery strategy
        if eval "${RECOVERY_STRATEGIES[$recovery_key]}"; then
            error_debug "Recovery successful for $recovery_key"
            return 0
        else
            error_debug "Recovery failed for $recovery_key"
            return 1
        fi
    fi
    
    return 1
}

# Main error handling function
handle_error() {
    local error_code="${1:-1}"
    local error_message="${2:-Unknown error}"
    local context="${3:-GENERAL}"
    local show_user="${4:-true}"
    
    # Generate unique error ID
    local error_id="$(generate_error_id)"
    
    # Update error statistics
    ((ERROR_STATS[total_errors]++))
    
    # Show user-friendly message if requested
    if [[ "$show_user" == "true" ]]; then
        format_error_message "$error_code" "$error_message" "$context" "$error_id" "user" >&2
    fi
    
    # Log error
    log_error_message "$error_code" "$error_message" "$context" "$error_id"
    
    # Attempt recovery
    if attempt_error_recovery "$error_code" "$context"; then
        ((ERROR_STATS[handled_errors]++))
        return 0
    else
        ((ERROR_STATS[unhandled_errors]++))
    fi
    
    return "$error_code"
}

# Handle unexpected errors (from trap)
handle_unexpected_error() {
    local exit_code="$1"
    local line_number="$2"
    local source_file="$3"
    local failed_command="$4"
    
    local error_message="Unexpected error in $(basename "$source_file"):$line_number"
    local context="UNEXPECTED"
    
    if [[ -n "$failed_command" ]]; then
        error_message+=" while executing: $failed_command"
    fi
    
    handle_error "$exit_code" "$error_message" "$context" true
    
    # Don't exit immediately, let cleanup happen
    return 0
}

# Register error recovery strategy
register_recovery_strategy() {
    local context="$1"
    local error_code="$2"
    local recovery_command="$3"
    
    local recovery_key="$context:$error_code"
    RECOVERY_STRATEGIES["$recovery_key"]="$recovery_command"
    
    error_debug "Registered recovery strategy for $recovery_key"
}

# Specific error type handlers
handle_module_error() {
    handle_error "$1" "$2" "MODULE" "$3"
}

handle_package_error() {
    handle_error "$1" "$2" "PACKAGE" "$3"
}

handle_config_error() {
    handle_error "$1" "$2" "CONFIG" "$3"
}

handle_ui_error() {
    handle_error "$1" "$2" "UI" "$3"
}

# Validation helpers
validate_required_param() {
    local param_name="$1"
    local param_value="$2"
    
    if [[ -z "$param_value" ]]; then
        handle_error 100 "Required parameter missing: $param_name" "VALIDATION"
        return 1
    fi
}

validate_file_exists() {
    local file_path="$1"
    local context="${2:-FILE_VALIDATION}"
    
    if [[ ! -f "$file_path" ]]; then
        handle_error 101 "File not found: $file_path" "$context"
        return 1
    fi
}

validate_directory_exists() {
    local dir_path="$1" 
    local context="${2:-DIR_VALIDATION}"
    
    if [[ ! -d "$dir_path" ]]; then
        handle_error 102 "Directory not found: $dir_path" "$context"
        return 1
    fi
}

validate_command_exists() {
    local command_name="$1"
    local context="${2:-CMD_VALIDATION}"
    
    if ! command -v "$command_name" >/dev/null 2>&1; then
        handle_error 103 "Command not found: $command_name" "$context"
        return 1
    fi
}

# Error statistics and reporting
get_error_stats() {
    echo "=== Error Statistics ==="
    echo "Total errors: ${ERROR_STATS[total_errors]}"
    echo "Handled errors: ${ERROR_STATS[handled_errors]}"
    echo "Unhandled errors: ${ERROR_STATS[unhandled_errors]}"
    
    if [[ ${ERROR_STATS[total_errors]} -gt 0 ]]; then
        local success_rate=$(( ERROR_STATS[handled_errors] * 100 / ERROR_STATS[total_errors] ))
        echo "Recovery rate: ${success_rate}%"
    fi
}

# Reset error statistics
reset_error_stats() {
    ERROR_STATS[total_errors]=0
    ERROR_STATS[handled_errors]=0
    ERROR_STATS[unhandled_errors]=0
}

# Cleanup function for exit trap
cleanup_on_exit() {
    if [[ "${ERROR_STATS[total_errors]}" -gt 0 ]] && [[ "${LOADER_DEBUG:-false}" == "true" ]]; then
        get_error_stats >&2
    fi
}

# Test error handler
test_error_handler() {
    echo "Testing error handler..."
    
    # Test basic error
    handle_error 42 "Test error message" "TEST"
    
    # Test validation
    validate_required_param "test_param" ""
    
    # Test file validation
    validate_file_exists "/nonexistent/file" "TEST"
    
    # Show stats
    get_error_stats
}

# Export key functions
export -f handle_error handle_module_error handle_package_error handle_config_error handle_ui_error
export -f validate_required_param validate_file_exists validate_directory_exists validate_command_exists
export -f register_recovery_strategy get_error_stats reset_error_stats
