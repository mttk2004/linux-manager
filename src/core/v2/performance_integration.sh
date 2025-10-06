#!/bin/bash

# Performance Integration System - V2 Architecture
# Integrates all performance components and provides centralized management

# Integration status
PERFORMANCE_INTEGRATION_ENABLED=${PERFORMANCE_INTEGRATION_ENABLED:-true}

# Performance components
declare -A PERF_COMPONENTS=(
    [core_performance]="performance.sh"
    [package_cache]="package_cache.sh"
    [optimized_io]="optimized_io.sh"
)

declare -A PERF_COMPONENT_STATUS=()

# Initialize complete performance system
init_performance_integration() {
    if [[ "$PERFORMANCE_INTEGRATION_ENABLED" != "true" ]]; then
        log_info "PERFORMANCE_INTEGRATION" "Performance integration is disabled"
        return 0
    fi
    
    local start_time
    start_time=$(get_timestamp_ms)
    
    log_info "PERFORMANCE_INTEGRATION" "Initializing performance integration system..."
    
    # Initialize core performance system first
    if ! init_performance_system; then
        log_error "PERFORMANCE_INTEGRATION" "Failed to initialize core performance system"
        return 1
    fi
    PERF_COMPONENT_STATUS[core_performance]="initialized"
    
    # Initialize package cache system
    if ! init_package_cache; then
        log_warning "PERFORMANCE_INTEGRATION" "Failed to initialize package cache system"
        PERF_COMPONENT_STATUS[package_cache]="failed"
    else
        PERF_COMPONENT_STATUS[package_cache]="initialized"
    fi
    
    # Initialize optimized I/O system
    if ! init_optimized_io; then
        log_warning "PERFORMANCE_INTEGRATION" "Failed to initialize optimized I/O system"
        PERF_COMPONENT_STATUS[optimized_io]="failed"
    else
        PERF_COMPONENT_STATUS[optimized_io]="initialized"
    fi
    
    # Setup performance monitoring
    setup_performance_monitoring
    
    # Register cleanup handlers
    register_performance_cleanup_handlers
    
    local end_time duration
    end_time=$(get_timestamp_ms)
    duration=$((end_time - start_time))
    
    log_performance "PERFORMANCE_INTEGRATION" "Performance integration initialized" "$duration"
    log_info "PERFORMANCE_INTEGRATION" "Performance integration system ready"
    
    return 0
}

# Setup automated performance monitoring
setup_performance_monitoring() {
    log_debug "PERFORMANCE_INTEGRATION" "Setting up performance monitoring..."
    
    # Start periodic memory monitoring
    if [[ "$PERF_MONITORING_ENABLED" == "true" ]]; then
        start_memory_monitor &
        MEMORY_MONITOR_PID=$!
        log_debug "PERFORMANCE_INTEGRATION" "Memory monitor started (PID: $MEMORY_MONITOR_PID)"
    fi
    
    # Setup performance alerts
    setup_performance_alerts
}

# Memory monitoring daemon
start_memory_monitor() {
    local check_interval=${PERF_MEMORY_CHECK_INTERVAL:-30}  # seconds
    
    while true; do
        sleep "$check_interval"
        
        local current_memory
        current_memory=$(get_memory_usage)
        
        if [[ $current_memory -gt $PERF_MEMORY_THRESHOLD ]]; then
            log_warning "PERFORMANCE_INTEGRATION" "High memory usage: ${current_memory}MB"
            
            # Trigger cache cleanup if memory is too high
            if [[ $current_memory -gt $((PERF_MEMORY_THRESHOLD * 2)) ]]; then
                log_info "PERFORMANCE_INTEGRATION" "Triggering automatic cache cleanup due to high memory usage"
                cache_clear_all
            fi
        fi
        
        # Update performance metrics
        perf_increment_counter "memory_checks"
    done
}

# Setup performance alerts
setup_performance_alerts() {
    # Performance thresholds for alerts
    PERF_ALERT_SLOW_THRESHOLD=${PERF_ALERT_SLOW_THRESHOLD:-5000}  # 5 seconds
    PERF_ALERT_MEMORY_THRESHOLD=${PERF_ALERT_MEMORY_THRESHOLD:-200}  # 200MB
    PERF_ALERT_CACHE_MISS_THRESHOLD=${PERF_ALERT_CACHE_MISS_THRESHOLD:-80}  # 80% miss rate
}

# Enhanced performance reporting
generate_comprehensive_performance_report() {
    local report_level="${1:-summary}"  # summary, detailed, full
    
    if [[ "$PERF_ENABLED" != "true" ]]; then
        render_status_message "Performance monitoring is disabled" "warning"
        return 0
    fi
    
    local uptime_ms current_memory
    uptime_ms=$(( $(get_timestamp_ms) - ${PERF_METRICS[start_time]} ))
    current_memory=$(get_memory_usage)
    
    clear
    render_ascii_header "main" "LINUX MANAGER PERFORMANCE REPORT"
    
    # System overview
    render_menu_header "SYSTEM OVERVIEW" "$(get_icon GEAR)"
    
    echo -e "${WHITE}${BOLD}Uptime:${NC} ${LIGHT_CYAN}$((uptime_ms / 1000))s (${uptime_ms}ms)${NC}"
    echo -e "${WHITE}${BOLD}Memory Usage:${NC} ${LIGHT_CYAN}${current_memory}MB${NC}"
    
    local memory_status=""
    if [[ $current_memory -gt $PERF_MEMORY_THRESHOLD ]]; then
        memory_status=" ${LIGHT_RED}$(get_icon WARNING) HIGH${NC}"
    else
        memory_status=" ${LIGHT_GREEN}$(get_icon CHECK) Normal${NC}"
    fi
    echo -e "${WHITE}${BOLD}Memory Status:${NC}${memory_status}"
    
    echo
    
    # Component status
    render_menu_header "PERFORMANCE COMPONENTS" "$(get_icon CONFIG)"
    
    for component in "${!PERF_COMPONENTS[@]}"; do
        local status="${PERF_COMPONENT_STATUS[$component]:-unknown}"
        local status_icon status_color
        
        case "$status" in
            "initialized")
                status_icon="$(get_icon CHECK)"
                status_color="$LIGHT_GREEN"
                ;;
            "failed")
                status_icon="$(get_icon CROSS)"
                status_color="$LIGHT_RED"
                ;;
            *)
                status_icon="$(get_icon WARNING)"
                status_color="$LIGHT_YELLOW"
                ;;
        esac
        
        echo -e "  ${status_color}${status_icon}${NC} ${WHITE}${component}:${NC} ${status_color}${status}${NC}"
    done
    
    echo
    
    # Performance metrics
    render_menu_header "PERFORMANCE METRICS" "$(get_icon STAR)"
    
    # Cache performance
    local cache_hits=$((${PERF_METRICS[cache_hits]} + $(perf_get_counter package_search_cache_hits) + $(perf_get_counter package_info_cache_hits) + $(perf_get_counter file_read_cache_hits)))
    local cache_misses=$((${PERF_METRICS[cache_misses]} + $(perf_get_counter package_search_cache_misses) + $(perf_get_counter package_info_cache_misses) + $(perf_get_counter file_read_cache_misses)))
    local total_cache_requests=$((cache_hits + cache_misses))
    
    echo -e "${WHITE}${BOLD}Cache Performance:${NC}"
    echo -e "  Total hits: ${LIGHT_GREEN}${cache_hits}${NC}"
    echo -e "  Total misses: ${LIGHT_YELLOW}${cache_misses}${NC}"
    
    if [[ $total_cache_requests -gt 0 ]]; then
        local hit_rate=$((cache_hits * 100 / total_cache_requests))
        local hit_rate_color="$LIGHT_CYAN"
        
        if [[ $hit_rate -lt 50 ]]; then
            hit_rate_color="$LIGHT_RED"
        elif [[ $hit_rate -gt 80 ]]; then
            hit_rate_color="$LIGHT_GREEN"
        fi
        
        echo -e "  Hit rate: ${hit_rate_color}${hit_rate}%${NC}"
    fi
    
    echo
    
    # Module and operation metrics
    echo -e "${WHITE}${BOLD}Operation Metrics:${NC}"
    echo -e "  Modules loaded: ${LIGHT_CYAN}${PERF_METRICS[modules_loaded]}${NC}"
    echo -e "  Slow operations: ${LIGHT_RED}${PERF_METRICS[slow_operations]}${NC}"
    echo -e "  File operations: ${LIGHT_CYAN}$(perf_get_counter lazy_file_loads)${NC}"
    echo -e "  Batch operations: ${LIGHT_CYAN}$(perf_get_counter batch_operations)${NC}"
    
    echo
    
    if [[ "$report_level" == "detailed" || "$report_level" == "full" ]]; then
        # Detailed package cache statistics
        if [[ "${PERF_COMPONENT_STATUS[package_cache]}" == "initialized" ]]; then
            show_package_cache_stats
        fi
        
        # Detailed I/O statistics
        if [[ "${PERF_COMPONENT_STATUS[optimized_io]}" == "initialized" ]]; then
            show_io_performance_stats
        fi
    fi
    
    if [[ "$report_level" == "full" ]]; then
        # Show all active counters
        if [[ ${#PERF_COUNTERS[@]} -gt 0 ]]; then
            render_menu_header "ALL PERFORMANCE COUNTERS" "$(get_icon SEARCH)"
            
            for counter_name in "${!PERF_COUNTERS[@]}"; do
                echo -e "  ${WHITE}${counter_name}:${NC} ${LIGHT_CYAN}${PERF_COUNTERS[$counter_name]}${NC}"
            done
            echo
        fi
        
        # Show active timers
        if [[ ${#PERF_TIMERS[@]} -gt 0 ]]; then
            render_menu_header "ACTIVE TIMERS" "$(get_icon GEAR)"
            
            for timer_name in "${!PERF_TIMERS[@]}"; do
                local timer_age=$(($(get_timestamp_ms) - ${PERF_TIMERS[$timer_name]}))
                echo -e "  ${WHITE}${timer_name}:${NC} ${LIGHT_CYAN}${timer_age}ms${NC}"
            done
            echo
        fi
    fi
    
    # Performance recommendations
    generate_performance_recommendations
    
    create_separator "=" "$UI_WIDTH" "$LIGHT_GREEN"
}

# Generate performance recommendations
generate_performance_recommendations() {
    render_menu_header "PERFORMANCE RECOMMENDATIONS" "$(get_icon INFO)"
    
    local recommendations=()
    
    # Memory recommendations
    local current_memory
    current_memory=$(get_memory_usage)
    
    if [[ $current_memory -gt $PERF_MEMORY_THRESHOLD ]]; then
        recommendations+=("Bộ nhớ cao (${current_memory}MB) - Xem xét tăng PERF_MEMORY_THRESHOLD hoặc dọn dẹp cache")
    fi
    
    # Cache recommendations
    local total_cache_requests=$((${PERF_METRICS[cache_hits]} + ${PERF_METRICS[cache_misses]}))
    if [[ $total_cache_requests -gt 0 ]]; then
        local hit_rate=$((${PERF_METRICS[cache_hits]} * 100 / total_cache_requests))
        
        if [[ $hit_rate -lt 50 ]]; then
            recommendations+=("Tỷ lệ cache hit thấp (${hit_rate}%) - Xem xét tăng CACHE_TTL")
        fi
    fi
    
    # Slow operations recommendations
    if [[ ${PERF_METRICS[slow_operations]} -gt 5 ]]; then
        recommendations+=("Phát hiện ${PERF_METRICS[slow_operations]} thao tác chậm - Xem xét tối ưu hóa")
    fi
    
    # Component failure recommendations
    for component in "${!PERF_COMPONENT_STATUS[@]}"; do
        if [[ "${PERF_COMPONENT_STATUS[$component]}" == "failed" ]]; then
            recommendations+=("Component $component bị lỗi - Kiểm tra log để biết chi tiết")
        fi
    done
    
    if [[ ${#recommendations[@]} -eq 0 ]]; then
        echo -e "${LIGHT_GREEN}$(get_icon CHECK) Không có khuyến nghị cải thiện hiệu suất${NC}"
    else
        for recommendation in "${recommendations[@]}"; do
            echo -e "${LIGHT_YELLOW}$(get_icon WARNING) ${recommendation}${NC}"
        done
    fi
    
    echo
}

# Performance optimization wizard
performance_optimization_wizard() {
    clear
    render_ascii_header "main" "PERFORMANCE OPTIMIZATION WIZARD"
    
    # Analyze current performance
    render_status_message "Đang phân tích hiệu suất hệ thống..." "info"
    
    local optimization_actions=()
    local current_memory
    current_memory=$(get_memory_usage)
    
    # Check memory usage
    if [[ $current_memory -gt $PERF_MEMORY_THRESHOLD ]]; then
        optimization_actions+=("clear_cache:Dọn dẹp cache để giải phóng bộ nhớ")
    fi
    
    # Check cache performance
    local total_cache_requests=$((${PERF_METRICS[cache_hits]} + ${PERF_METRICS[cache_misses]}))
    if [[ $total_cache_requests -gt 0 ]]; then
        local hit_rate=$((${PERF_METRICS[cache_hits]} * 100 / total_cache_requests))
        
        if [[ $hit_rate -lt 40 ]]; then
            optimization_actions+=("increase_ttl:Tăng thời gian sống của cache")
        fi
    fi
    
    # Check for slow operations
    if [[ ${PERF_METRICS[slow_operations]} -gt 3 ]]; then
        optimization_actions+=("enable_lazy_loading:Bật lazy loading để tăng tốc")
    fi
    
    if [[ ${#optimization_actions[@]} -eq 0 ]]; then
        render_status_message "Hệ thống đang hoạt động tối ưu!" "success"
        return 0
    fi
    
    # Present optimization options
    render_menu_header "TÙY CHỌN TỐI ƯU HÓA" "$(get_icon GEAR)"
    
    local option_num=1
    for action_info in "${optimization_actions[@]}"; do
        local action="${action_info%%:*}"
        local description="${action_info##*:}"
        
        render_menu_option "$option_num" "$description" "" "$(get_icon ROCKET)"
        ((option_num++))
    done
    
    render_menu_option "$option_num" "Áp dụng tất cả tối ưu hóa" "Thực hiện tất cả các tối ưu hóa được đề xuất" "$(get_icon AUTO)"
    ((option_num++))
    
    render_menu_option "$option_num" "Bỏ qua" "Không thực hiện tối ưu hóa nào" "$(get_icon EXIT)"
    
    render_input_prompt "Chọn tùy chọn tối ưu hóa" "1-$option_num"
    
    local choice
    read -r choice
    
    if [[ "$choice" -eq $((option_num - 1)) ]]; then
        # Apply all optimizations
        for action_info in "${optimization_actions[@]}"; do
            local action="${action_info%%:*}"
            apply_performance_optimization "$action"
        done
        
        render_status_message "Tất cả tối ưu hóa đã được áp dụng!" "success"
        
    elif [[ "$choice" -eq $option_num ]]; then
        render_status_message "Tối ưu hóa đã bị bỏ qua" "info"
        
    elif [[ "$choice" -ge 1 && "$choice" -lt $((option_num - 1)) ]]; then
        local selected_action_info="${optimization_actions[$((choice - 1))]}"
        local selected_action="${selected_action_info%%:*}"
        
        apply_performance_optimization "$selected_action"
        render_status_message "Tối ưu hóa đã được áp dụng!" "success"
        
    else
        render_status_message "Lựa chọn không hợp lệ" "error"
    fi
}

# Apply specific performance optimization
apply_performance_optimization() {
    local optimization_type="$1"
    
    case "$optimization_type" in
        "clear_cache")
            render_status_message "Đang dọn dẹp cache..." "info"
            cache_clear_all
            clear_package_cache
            ;;
        "increase_ttl")
            render_status_message "Đang tăng thời gian sống của cache..." "info"
            export CACHE_TTL=$((CACHE_TTL * 2))
            export PACKAGE_CACHE_TTL=$((PACKAGE_CACHE_TTL * 2))
            ;;
        "enable_lazy_loading")
            render_status_message "Đang bật lazy loading..." "info"
            export PERF_LAZY_LOADING="true"
            export IO_LAZY_LOADING="true"
            ;;
        *)
            log_warning "PERFORMANCE_INTEGRATION" "Unknown optimization type: $optimization_type"
            ;;
    esac
}

# Register cleanup handlers
register_performance_cleanup_handlers() {
    # Setup trap for cleanup on exit
    trap 'cleanup_performance_integration' EXIT
}

# Comprehensive performance cleanup
cleanup_performance_integration() {
    log_info "PERFORMANCE_INTEGRATION" "Cleaning up performance integration..."
    
    # Stop memory monitor if running
    if [[ -n "${MEMORY_MONITOR_PID:-}" ]]; then
        kill "$MEMORY_MONITOR_PID" 2>/dev/null
        log_debug "PERFORMANCE_INTEGRATION" "Memory monitor stopped"
    fi
    
    # Cleanup individual components
    if [[ "${PERF_COMPONENT_STATUS[core_performance]}" == "initialized" ]]; then
        cleanup_performance_system
    fi
    
    if [[ "${PERF_COMPONENT_STATUS[package_cache]}" == "initialized" ]]; then
        clear_package_cache
    fi
    
    if [[ "${PERF_COMPONENT_STATUS[optimized_io]}" == "initialized" ]]; then
        cleanup_optimized_io
    fi
    
    # Reset component status
    PERF_COMPONENT_STATUS=()
    
    log_info "PERFORMANCE_INTEGRATION" "Performance integration cleanup completed"
}

# Export integration functions
export -f init_performance_integration setup_performance_monitoring
export -f generate_comprehensive_performance_report generate_performance_recommendations
export -f performance_optimization_wizard apply_performance_optimization
export -f cleanup_performance_integration
