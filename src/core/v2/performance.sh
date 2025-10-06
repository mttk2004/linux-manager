#!/bin/bash

# Performance Optimization Framework - V2 Architecture
# Implements caching, lazy loading, and performance monitoring

# Performance configuration
PERF_ENABLED=${PERF_ENABLED:-true}
PERF_CACHE_ENABLED=${PERF_CACHE_ENABLED:-true}
PERF_LAZY_LOADING=${PERF_LAZY_LOADING:-true}
PERF_MONITORING_ENABLED=${PERF_MONITORING_ENABLED:-true}

# Cache configuration
CACHE_MAX_SIZE=${CACHE_MAX_SIZE:-1000}  # Maximum cache entries
CACHE_TTL=${CACHE_TTL:-300}             # Cache TTL in seconds (5 minutes)
CACHE_DIR="${ROOT_DIR}/cache"
CACHE_CLEANUP_INTERVAL=${CACHE_CLEANUP_INTERVAL:-60}  # seconds

# Performance tracking
declare -A PERF_TIMERS=()
declare -A PERF_COUNTERS=()
declare -A PERF_CACHE=()
declare -A PERF_CACHE_TTL=()
declare -A PERF_METRICS=()

# Lazy loading registry
declare -A LAZY_MODULES=()
declare -A LOADED_MODULES=()

# Performance thresholds
PERF_SLOW_THRESHOLD=${PERF_SLOW_THRESHOLD:-1000}  # ms
PERF_MEMORY_THRESHOLD=${PERF_MEMORY_THRESHOLD:-100}  # MB

# Initialize performance system
init_performance_system() {
    if [[ "$PERF_ENABLED" != "true" ]]; then
        return 0
    fi
    
    log_debug "PERFORMANCE" "Initializing performance system..."
    
    # Create cache directory
    if [[ "$PERF_CACHE_ENABLED" == "true" ]]; then
        if ! mkdir -p "$CACHE_DIR"; then
            log_warning "PERFORMANCE" "Failed to create cache directory: $CACHE_DIR"
        fi
    fi
    
    # Initialize performance metrics
    PERF_METRICS[start_time]=$(get_timestamp_ms)
    PERF_METRICS[cache_hits]=0
    PERF_METRICS[cache_misses]=0
    PERF_METRICS[modules_loaded]=0
    PERF_METRICS[slow_operations]=0
    
    # Start background cleanup if enabled
    if [[ "$PERF_CACHE_ENABLED" == "true" ]]; then
        start_cache_cleanup_daemon &
    fi
    
    log_info "PERFORMANCE" "Performance system initialized successfully"
    return 0
}

# High-precision timestamp
get_timestamp_ms() {
    if command -v date >/dev/null 2>&1; then
        date +%s%3N 2>/dev/null || echo $(($(date +%s) * 1000))
    else
        echo $(($(printf '%(%s)T' -1) * 1000))
    fi
}

# Start performance timer
perf_start_timer() {
    local timer_name="$1"
    
    if [[ "$PERF_ENABLED" != "true" ]]; then
        return 0
    fi
    
    PERF_TIMERS["$timer_name"]=$(get_timestamp_ms)
}

# End performance timer and log if slow
perf_end_timer() {
    local timer_name="$1"
    local operation_description="${2:-$timer_name}"
    
    if [[ "$PERF_ENABLED" != "true" ]]; then
        return 0
    fi
    
    local start_time="${PERF_TIMERS[$timer_name]:-}"
    if [[ -z "$start_time" ]]; then
        log_warning "PERFORMANCE" "Timer not found: $timer_name"
        return 1
    fi
    
    local end_time duration
    end_time=$(get_timestamp_ms)
    duration=$((end_time - start_time))
    
    # Log performance metrics
    log_performance "PERFORMANCE" "$operation_description" "$duration"
    
    # Track slow operations
    if [[ $duration -gt $PERF_SLOW_THRESHOLD ]]; then
        ((PERF_METRICS[slow_operations]++))
        log_warning "PERFORMANCE" "Slow operation detected: $operation_description took ${duration}ms"
    fi
    
    # Clean up timer
    unset PERF_TIMERS["$timer_name"]
    
    echo "$duration"
}

# Increment performance counter
perf_increment_counter() {
    local counter_name="$1"
    local increment="${2:-1}"
    
    if [[ "$PERF_ENABLED" != "true" ]]; then
        return 0
    fi
    
    local current_value="${PERF_COUNTERS[$counter_name]:-0}"
    PERF_COUNTERS["$counter_name"]=$((current_value + increment))
}

# Get performance counter value
perf_get_counter() {
    local counter_name="$1"
    echo "${PERF_COUNTERS[$counter_name]:-0}"
}

# Cache functions
cache_key_hash() {
    local key="$1"
    echo -n "$key" | md5sum 2>/dev/null | cut -d' ' -f1 || echo "$key"
}

# Store value in cache
cache_set() {
    local key="$1"
    local value="$2"
    local ttl="${3:-$CACHE_TTL}"
    
    if [[ "$PERF_CACHE_ENABLED" != "true" ]]; then
        return 0
    fi
    
    local cache_key
    cache_key=$(cache_key_hash "$key")
    local expire_time=$(($(date +%s) + ttl))
    
    PERF_CACHE["$cache_key"]="$value"
    PERF_CACHE_TTL["$cache_key"]="$expire_time"
    
    # Persistent cache file
    local cache_file="${CACHE_DIR}/${cache_key}.cache"
    printf '%s\n%d\n%s' "$key" "$expire_time" "$value" > "$cache_file" 2>/dev/null
    
    log_debug "PERFORMANCE" "Cached value for key: $key"
}

# Get value from cache
cache_get() {
    local key="$1"
    
    if [[ "$PERF_CACHE_ENABLED" != "true" ]]; then
        return 1
    fi
    
    local cache_key
    cache_key=$(cache_key_hash "$key")
    local current_time
    current_time=$(date +%s)
    
    # Check memory cache first
    if [[ -n "${PERF_CACHE[$cache_key]:-}" ]]; then
        local expire_time="${PERF_CACHE_TTL[$cache_key]:-0}"
        
        if [[ $current_time -lt $expire_time ]]; then
            ((PERF_METRICS[cache_hits]++))
            echo "${PERF_CACHE[$cache_key]}"
            log_debug "PERFORMANCE" "Cache hit (memory): $key"
            return 0
        else
            # Expired, remove from memory
            unset PERF_CACHE["$cache_key"]
            unset PERF_CACHE_TTL["$cache_key"]
        fi
    fi
    
    # Check persistent cache
    local cache_file="${CACHE_DIR}/${cache_key}.cache"
    if [[ -f "$cache_file" ]]; then
        local stored_key stored_expire_time stored_value
        
        if IFS= read -r stored_key && \
           IFS= read -r stored_expire_time && \
           IFS= read -r stored_value < "$cache_file"; then
            
            if [[ $current_time -lt $stored_expire_time ]]; then
                # Load back into memory cache
                PERF_CACHE["$cache_key"]="$stored_value"
                PERF_CACHE_TTL["$cache_key"]="$stored_expire_time"
                
                ((PERF_METRICS[cache_hits]++))
                echo "$stored_value"
                log_debug "PERFORMANCE" "Cache hit (file): $key"
                return 0
            else
                # Expired file cache, remove it
                rm -f "$cache_file" 2>/dev/null
            fi
        fi
    fi
    
    # Cache miss
    ((PERF_METRICS[cache_misses]++))
    log_debug "PERFORMANCE" "Cache miss: $key"
    return 1
}

# Check if cached value exists and is not expired
cache_exists() {
    local key="$1"
    cache_get "$key" >/dev/null 2>&1
}

# Clear cache entry
cache_clear() {
    local key="$1"
    
    if [[ "$PERF_CACHE_ENABLED" != "true" ]]; then
        return 0
    fi
    
    local cache_key
    cache_key=$(cache_key_hash "$key")
    
    # Remove from memory
    unset PERF_CACHE["$cache_key"]
    unset PERF_CACHE_TTL["$cache_key"]
    
    # Remove cache file
    local cache_file="${CACHE_DIR}/${cache_key}.cache"
    rm -f "$cache_file" 2>/dev/null
    
    log_debug "PERFORMANCE" "Cache cleared for key: $key"
}

# Clear all cache
cache_clear_all() {
    if [[ "$PERF_CACHE_ENABLED" != "true" ]]; then
        return 0
    fi
    
    # Clear memory cache
    PERF_CACHE=()
    PERF_CACHE_TTL=()
    
    # Clear file cache
    if [[ -d "$CACHE_DIR" ]]; then
        rm -rf "${CACHE_DIR}"/*.cache 2>/dev/null
    fi
    
    # Reset cache metrics
    PERF_METRICS[cache_hits]=0
    PERF_METRICS[cache_misses]=0
    
    log_info "PERFORMANCE" "All cache cleared"
}

# Cached command execution
cached_command() {
    local cache_key="$1"
    local ttl="$2"
    shift 2
    local command=("$@")
    
    # Try to get from cache first
    local cached_result
    if cached_result=$(cache_get "$cache_key"); then
        echo "$cached_result"
        return 0
    fi
    
    # Execute command and cache result
    perf_start_timer "cached_command_$cache_key"
    
    local result exit_code
    result=$("${command[@]}" 2>&1)
    exit_code=$?
    
    perf_end_timer "cached_command_$cache_key" "Cached command: ${command[*]}"
    
    if [[ $exit_code -eq 0 ]]; then
        cache_set "$cache_key" "$result" "$ttl"
    fi
    
    echo "$result"
    return $exit_code
}

# Lazy loading system
register_lazy_module() {
    local module_name="$1"
    local module_path="$2"
    local loader_function="${3:-load_module}"
    
    if [[ "$PERF_LAZY_LOADING" != "true" ]]; then
        # Load immediately if lazy loading is disabled
        "$loader_function" "$module_path"
        return $?
    fi
    
    LAZY_MODULES["$module_name"]="$module_path:$loader_function"
    log_debug "PERFORMANCE" "Registered lazy module: $module_name"
}

# Load lazy module on demand
load_lazy_module() {
    local module_name="$1"
    
    # Check if already loaded
    if [[ -n "${LOADED_MODULES[$module_name]:-}" ]]; then
        return 0
    fi
    
    # Check if registered for lazy loading
    if [[ -z "${LAZY_MODULES[$module_name]:-}" ]]; then
        log_error "PERFORMANCE" "Lazy module not registered: $module_name"
        return 1
    fi
    
    perf_start_timer "lazy_load_$module_name"
    
    local module_info="${LAZY_MODULES[$module_name]}"
    local module_path="${module_info%%:*}"
    local loader_function="${module_info##*:}"
    
    if "$loader_function" "$module_path"; then
        LOADED_MODULES["$module_name"]=1
        ((PERF_METRICS[modules_loaded]++))
        log_info "PERFORMANCE" "Lazy loaded module: $module_name"
    else
        log_error "PERFORMANCE" "Failed to lazy load module: $module_name"
        perf_end_timer "lazy_load_$module_name" "Failed lazy load: $module_name"
        return 1
    fi
    
    perf_end_timer "lazy_load_$module_name" "Lazy load: $module_name"
    return 0
}

# Memory usage monitoring
get_memory_usage() {
    if command -v ps >/dev/null 2>&1; then
        ps -o rss= -p $$ 2>/dev/null | awk '{print int($1/1024)}' || echo "0"
    else
        echo "0"
    fi
}

# Check memory usage and warn if high
check_memory_usage() {
    local current_memory
    current_memory=$(get_memory_usage)
    
    if [[ $current_memory -gt $PERF_MEMORY_THRESHOLD ]]; then
        log_warning "PERFORMANCE" "High memory usage detected: ${current_memory}MB"
        return 1
    fi
    
    return 0
}

# Background cache cleanup daemon
start_cache_cleanup_daemon() {
    while true; do
        sleep "$CACHE_CLEANUP_INTERVAL"
        
        if [[ "$PERF_CACHE_ENABLED" == "true" && -d "$CACHE_DIR" ]]; then
            local current_time
            current_time=$(date +%s)
            local cleaned_count=0
            
            # Clean expired cache files
            for cache_file in "$CACHE_DIR"/*.cache; do
                if [[ -f "$cache_file" ]]; then
                    local stored_expire_time
                    if stored_expire_time=$(sed -n '2p' "$cache_file" 2>/dev/null); then
                        if [[ $current_time -gt $stored_expire_time ]]; then
                            rm -f "$cache_file" 2>/dev/null
                            ((cleaned_count++))
                        fi
                    fi
                fi
            done
            
            if [[ $cleaned_count -gt 0 ]]; then
                log_debug "PERFORMANCE" "Cleaned $cleaned_count expired cache entries"
            fi
        fi
    done
}

# Performance report
generate_performance_report() {
    if [[ "$PERF_ENABLED" != "true" ]]; then
        echo "Performance monitoring is disabled"
        return 0
    fi
    
    local uptime_ms current_memory
    uptime_ms=$(( $(get_timestamp_ms) - ${PERF_METRICS[start_time]} ))
    current_memory=$(get_memory_usage)
    
    echo
    create_separator "=" "$UI_WIDTH" "$LIGHT_GREEN"
    create_centered_text "$(get_icon GEAR) PERFORMANCE REPORT" "$UI_WIDTH" "$LIGHT_GREEN$BOLD"
    create_separator "=" "$UI_WIDTH" "$LIGHT_GREEN"
    
    # System metrics
    echo -e "${WHITE}${BOLD}Thời gian hoạt động:${NC} ${LIGHT_CYAN}${uptime_ms}ms${NC}"
    echo -e "${WHITE}${BOLD}Bộ nhớ sử dụng:${NC} ${LIGHT_CYAN}${current_memory}MB${NC}"
    echo
    
    # Cache metrics
    echo -e "${WHITE}${BOLD}Cache Performance:${NC}"
    echo -e "  Cache hits: ${LIGHT_GREEN}${PERF_METRICS[cache_hits]}${NC}"
    echo -e "  Cache misses: ${LIGHT_YELLOW}${PERF_METRICS[cache_misses]}${NC}"
    
    local total_cache_requests=$((PERF_METRICS[cache_hits] + PERF_METRICS[cache_misses]))
    if [[ $total_cache_requests -gt 0 ]]; then
        local hit_rate=$((PERF_METRICS[cache_hits] * 100 / total_cache_requests))
        echo -e "  Hit rate: ${LIGHT_CYAN}${hit_rate}%${NC}"
    fi
    echo
    
    # Module loading metrics
    echo -e "${WHITE}${BOLD}Module Loading:${NC}"
    echo -e "  Modules loaded: ${LIGHT_CYAN}${PERF_METRICS[modules_loaded]}${NC}"
    echo -e "  Slow operations: ${LIGHT_RED}${PERF_METRICS[slow_operations]}${NC}"
    echo
    
    # Active counters
    if [[ ${#PERF_COUNTERS[@]} -gt 0 ]]; then
        echo -e "${WHITE}${BOLD}Active Counters:${NC}"
        for counter_name in "${!PERF_COUNTERS[@]}"; do
            echo -e "  ${counter_name}: ${LIGHT_CYAN}${PERF_COUNTERS[$counter_name]}${NC}"
        done
        echo
    fi
    
    create_separator "=" "$UI_WIDTH" "$LIGHT_GREEN"
}

# Cleanup performance system
cleanup_performance_system() {
    log_info "PERFORMANCE" "Cleaning up performance system..."
    
    # Clear all caches
    cache_clear_all
    
    # Clear timers and counters
    PERF_TIMERS=()
    PERF_COUNTERS=()
    PERF_METRICS=()
    
    # Clear lazy loading registry
    LAZY_MODULES=()
    LOADED_MODULES=()
    
    log_info "PERFORMANCE" "Performance system cleanup completed"
}

# Export performance functions
export -f init_performance_system get_timestamp_ms perf_start_timer perf_end_timer
export -f perf_increment_counter perf_get_counter cache_set cache_get cache_exists
export -f cache_clear cache_clear_all cached_command register_lazy_module
export -f load_lazy_module get_memory_usage check_memory_usage
export -f generate_performance_report cleanup_performance_system
