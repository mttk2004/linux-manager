#!/bin/bash

# Advanced Logging System - V2 Architecture  
# Provides structured logging, performance metrics, and log management

# Logging configuration
LOG_LEVEL=${LOG_LEVEL:-INFO}
LOG_FORMAT=${LOG_FORMAT:-structured} # simple, structured, json
LOG_ROTATION=${LOG_ROTATION:-true}
LOG_MAX_SIZE=${LOG_MAX_SIZE:-10485760} # 10MB in bytes
LOG_MAX_FILES=${LOG_MAX_FILES:-5}
LOG_PERFORMANCE=${LOG_PERFORMANCE:-true}

# Log levels with numeric values
declare -A LOG_LEVELS=(
    [TRACE]=0
    [DEBUG]=1
    [INFO]=2
    [WARN]=3
    [ERROR]=4
    [FATAL]=5
)

# Performance metrics
declare -A PERFORMANCE_METRICS=()
declare -A OPERATION_TIMES=()

# Log files
LOG_FILE="${LOG_FILE:-$LOGS_DIR/manager_$(date +%Y%m%d).log}"
PERFORMANCE_LOG_FILE="${LOGS_DIR}/performance_$(date +%Y%m%d).log"
ERROR_LOG_FILE="${LOGS_DIR}/error_$(date +%Y%m%d).log"

# Initialize logger
init_logger() {
    # Create logs directory if it doesn't exist
    if [[ -n "$LOGS_DIR" ]]; then
        mkdir -p "$LOGS_DIR" 2>/dev/null || true
    fi
    
    # Set current log level numeric value
    CURRENT_LOG_LEVEL=${LOG_LEVELS[$LOG_LEVEL]:-2}
    
    # Initialize performance tracking
    PERFORMANCE_METRICS[operations_count]=0
    PERFORMANCE_METRICS[total_time]=0
    PERFORMANCE_METRICS[avg_time]=0
    
    # Skip log rotation during init for now
    # Log rotation will be handled later
    
    # Simple log initialization without calling log_info to avoid circular dependency
    if [[ -n "$LOG_FILE" && -d "$(dirname "$LOG_FILE")" ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] [LOGGER] Logger initialized with level: $LOG_LEVEL, format: $LOG_FORMAT" >> "$LOG_FILE" 2>/dev/null || true
    fi
    
    return 0
}

# Check if message should be logged based on level
should_log() {
    local level="$1"
    local level_num=${LOG_LEVELS[$level]}
    [[ $level_num -ge $CURRENT_LOG_LEVEL ]]
}

# Get timestamp in different formats
get_timestamp() {
    local format="${1:-iso8601}" # iso8601, simple, epoch
    
    case "$format" in
        "iso8601")
            date -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
            ;;
        "simple")
            date '+%Y-%m-%d %H:%M:%S'
            ;;
        "epoch")
            date +%s
            ;;
    esac
}

# Format log message
format_log_message() {
    local level="$1"
    local component="$2"
    local message="$3"
    local context="$4"
    local format="${5:-$LOG_FORMAT}"
    
    case "$format" in
        "json")
            local timestamp="$(get_timestamp iso8601)"
            local json_context=""
            if [[ -n "$context" ]]; then
                json_context=",\"context\":\"$context\""
            fi
            echo "{\"timestamp\":\"$timestamp\",\"level\":\"$level\",\"component\":\"$component\",\"message\":\"$message\"$json_context}"
            ;;
        "structured")
            local timestamp="$(get_timestamp simple)"
            echo "[$timestamp] [$level] [$component] $message"
            if [[ -n "$context" ]]; then
                echo "  Context: $context"
            fi
            ;;
        *)
            # Simple format
            local timestamp="$(get_timestamp simple)"
            echo "[$timestamp] [$level] $message"
            ;;
    esac
}

# Core logging function
write_log() {
    local level="$1"
    local component="$2"
    local message="$3"
    local context="$4"
    local log_file="${5:-$LOG_FILE}"
    
    # Check if we should log this level
    if ! should_log "$level"; then
        return 0
    fi
    
    # Format message
    local formatted_message="$(format_log_message "$level" "$component" "$message" "$context")"
    
    # Write to log file
    echo "$formatted_message" >> "$log_file"
    
    # Also write errors to error log
    if [[ "$level" == "ERROR" || "$level" == "FATAL" ]]; then
        echo "$formatted_message" >> "$ERROR_LOG_FILE"
    fi
    
    # Write to console in debug mode or for errors
    if [[ "${LOADER_DEBUG:-false}" == "true" ]] || [[ "$level" == "ERROR" || "$level" == "FATAL" ]]; then
        echo "$formatted_message" >&2
    fi
}

# Specific logging functions
log_trace() {
    local component="${2:-GENERAL}"
    local context="${3:-}"
    write_log "TRACE" "$component" "$1" "$context"
}

log_debug() {
    local component="${2:-GENERAL}"
    local context="${3:-}"
    write_log "DEBUG" "$component" "$1" "$context"
}

log_info() {
    local component="${2:-GENERAL}"
    local context="${3:-}"
    write_log "INFO" "$component" "$1" "$context"
}

log_warning() {
    local component="${2:-GENERAL}"
    local context="${3:-}"
    write_log "WARN" "$component" "$1" "$context"
}

log_error() {
    local component="${2:-GENERAL}"
    local context="${3:-}"
    write_log "ERROR" "$component" "$1" "$context"
}

log_fatal() {
    local component="${2:-GENERAL}"
    local context="${3:-}"
    write_log "FATAL" "$component" "$1" "$context"
}

# Performance logging
start_performance_timer() {
    local operation_id="$1"
    OPERATION_TIMES["$operation_id"]="$(date +%s%N)"
}

end_performance_timer() {
    local operation_id="$1"
    local operation_desc="${2:-$operation_id}"
    
    if [[ -z "${OPERATION_TIMES[$operation_id]:-}" ]]; then
        log_warning "PERFORMANCE" "Performance timer not started for: $operation_id"
        return 1
    fi
    
    local start_time="${OPERATION_TIMES[$operation_id]}"
    local end_time="$(date +%s%N)"
    local duration=$(( (end_time - start_time) / 1000000 )) # Convert to milliseconds
    
    # Update performance metrics
    ((PERFORMANCE_METRICS[operations_count]++))
    PERFORMANCE_METRICS[total_time]=$((PERFORMANCE_METRICS[total_time] + duration))
    PERFORMANCE_METRICS[avg_time]=$((PERFORMANCE_METRICS[total_time] / PERFORMANCE_METRICS[operations_count]))
    
    # Log performance
    if [[ "$LOG_PERFORMANCE" == "true" ]]; then
        local perf_message="Operation completed: $operation_desc (${duration}ms)"
        write_log "INFO" "PERFORMANCE" "$perf_message" "" "$PERFORMANCE_LOG_FILE"
    fi
    
    # Clean up
    unset OPERATION_TIMES["$operation_id"]
    
    echo "$duration"
}

# Measure function execution time
measure_execution() {
    local func_name="$1"
    shift
    
    start_performance_timer "$func_name"
    "$@"
    local result=$?
    local duration="$(end_performance_timer "$func_name" "$func_name")"
    
    log_debug "PERFORMANCE" "Function $func_name executed in ${duration}ms"
    return $result
}

# Log rotation
rotate_logs_if_needed() {
    for log_file in "$LOG_FILE" "$PERFORMANCE_LOG_FILE" "$ERROR_LOG_FILE"; do
        if [[ -f "$log_file" ]] && [[ $(stat -c%s "$log_file" 2>/dev/null || echo 0) -gt $LOG_MAX_SIZE ]]; then
            rotate_log_file "$log_file"
        fi
    done
}

rotate_log_file() {
    local log_file="$1"
    local base_name="${log_file%.*}"
    local extension="${log_file##*.}"
    
    # Shift existing rotated files
    for ((i = $((LOG_MAX_FILES - 1)); i >= 1; i--)); do
        local old_file="${base_name}.${i}.${extension}"
        local new_file="${base_name}.$((i + 1)).${extension}"
        
        if [[ -f "$old_file" ]]; then
            if [[ $((i + 1)) -le $LOG_MAX_FILES ]]; then
                mv "$old_file" "$new_file"
            else
                rm -f "$old_file"
            fi
        fi
    done
    
    # Move current log to .1
    if [[ -f "$log_file" ]]; then
        mv "$log_file" "${base_name}.1.${extension}"
    fi
    
    log_info "LOGGER" "Rotated log file: $log_file"
}

# Performance reporting
get_performance_report() {
    local format="${1:-simple}" # simple, detailed, json
    
    case "$format" in
        "json")
            echo "{\"operations_count\":${PERFORMANCE_METRICS[operations_count]},\"total_time\":${PERFORMANCE_METRICS[total_time]},\"avg_time\":${PERFORMANCE_METRICS[avg_time]}}"
            ;;
        "detailed")
            echo "=== Performance Report ==="
            echo "Total operations: ${PERFORMANCE_METRICS[operations_count]}"
            echo "Total time: ${PERFORMANCE_METRICS[total_time]}ms"
            echo "Average time: ${PERFORMANCE_METRICS[avg_time]}ms"
            echo ""
            echo "Active timers:"
            for timer_id in "${!OPERATION_TIMES[@]}"; do
                echo "  $timer_id: Started at ${OPERATION_TIMES[$timer_id]}"
            done
            ;;
        *)
            echo "Operations: ${PERFORMANCE_METRICS[operations_count]}, Avg time: ${PERFORMANCE_METRICS[avg_time]}ms"
            ;;
    esac
}

# Log analysis
analyze_logs() {
    local log_file="${1:-$LOG_FILE}"
    local lines="${2:-20}"
    
    if [[ ! -f "$log_file" ]]; then
        log_error "LOGGER" "Log file not found: $log_file"
        return 1
    fi
    
    echo "=== Log Analysis: $(basename "$log_file") ==="
    echo "Total lines: $(wc -l < "$log_file")"
    
    echo ""
    echo "Log levels:"
    grep -oE '\[(TRACE|DEBUG|INFO|WARN|ERROR|FATAL)\]' "$log_file" | sort | uniq -c
    
    echo ""
    echo "Components:"
    grep -oE '\] \[[^]]+\] \[[^]]+\]' "$log_file" | sed 's/.*\[\([^]]*\)\].*/\1/' | sort | uniq -c | head -10
    
    echo ""
    echo "Recent entries ($lines lines):"
    tail -n "$lines" "$log_file"
}

# Search logs
search_logs() {
    local pattern="$1"
    local log_file="${2:-$LOG_FILE}"
    local context_lines="${3:-2}"
    
    if [[ ! -f "$log_file" ]]; then
        log_error "LOGGER" "Log file not found: $log_file"
        return 1
    fi
    
    echo "=== Search Results for: $pattern ==="
    grep -n -C "$context_lines" "$pattern" "$log_file"
}

# Clean old logs
clean_old_logs() {
    local days="${1:-7}"
    
    echo "Cleaning logs older than $days days..."
    find "$LOGS_DIR" -name "*.log*" -mtime "+$days" -type f -delete
    
    log_info "LOGGER" "Cleaned logs older than $days days"
}

# Log system health
log_system_health() {
    local disk_usage="$(df -h "$LOGS_DIR" | tail -1 | awk '{print $5}')"
    local log_count="$(find "$LOGS_DIR" -name "*.log*" -type f | wc -l)"
    
    log_info "SYSTEM" "Log directory usage: $disk_usage, Log files: $log_count"
    
    # Warn if disk usage is high
    local usage_percent="$(echo "$disk_usage" | sed 's/%//')"
    if [[ "$usage_percent" -gt 90 ]]; then
        log_warning "SYSTEM" "High disk usage in log directory: $disk_usage"
    fi
}

# Export key functions
export -f log_trace log_debug log_info log_warning log_error log_fatal
export -f start_performance_timer end_performance_timer measure_execution
export -f get_performance_report analyze_logs search_logs clean_old_logs
