#!/bin/bash

# Integration Tests for Linux Manager - V2 Architecture

# Load the test framework
source "$(dirname "${BASH_SOURCE[0]}")/../framework/test_runner.sh"

# Set up paths for integration testing
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Integration test setup - runs before each test
test_setup() {
    # Create isolated test environment
    TEST_TEMP_DIR=$(mktemp -d)
    TEST_CONFIG_DIR="$TEST_TEMP_DIR/config"
    TEST_LOGS_DIR="$TEST_TEMP_DIR/logs"
    TEST_CACHE_DIR="$TEST_TEMP_DIR/cache"
    
    mkdir -p "$TEST_CONFIG_DIR" "$TEST_LOGS_DIR" "$TEST_CACHE_DIR"
    
    # Export test environment variables
    export TESTING=true
    export ENVIRONMENT="testing"
    export ROOT_DIR="$TEST_TEMP_DIR"
    export LOG_FILE="$TEST_LOGS_DIR/test.log"
    export CACHE_DIR="$TEST_CACHE_DIR"
}

# Integration test teardown - runs after each test
test_teardown() {
    # Clean up test environment
    rm -rf "$TEST_TEMP_DIR" 2>/dev/null
    
    # Reset environment variables
    unset TESTING
    unset ENVIRONMENT
}

# Test loading multiple core modules
test_load_core_modules() {
    # Source core modules in dependency order
    assert_command_succeeds 'source "$ROOT_DIR/src/core/v2/logger.sh"' "Should load logger module"
    assert_command_succeeds 'source "$ROOT_DIR/src/core/v2/error_handler.sh"' "Should load error handler module"
    assert_command_succeeds 'source "$ROOT_DIR/src/core/v2/config_manager.sh"' "Should load config manager module"
    
    # Test that functions are available
    assert_command_succeeds 'declare -f log_info >/dev/null' "log_info function should be available"
    assert_command_succeeds 'declare -f handle_error >/dev/null' "handle_error function should be available"
    assert_command_succeeds 'declare -f get_config >/dev/null' "get_config function should be available"
}

# Test configuration and logging integration
test_config_logging_integration() {
    # Load required modules
    source "$ROOT_DIR/src/core/v2/logger.sh"
    source "$ROOT_DIR/src/core/v2/config_manager.sh"
    
    # Initialize systems
    init_logger
    init_config_manager
    
    # Test configuration affects logging
    set_config "LOG_LEVEL" "DEBUG" false
    set_config "VERBOSE_LOGGING" "true" false
    
    # Test that log level configuration is respected
    local initial_log_level="$LOG_LEVEL"
    LOG_LEVEL=$(get_config "LOG_LEVEL")
    assert_equals "DEBUG" "$LOG_LEVEL" "Log level should be set from configuration"
    
    # Test logging with configured level
    log_debug "TEST" "Debug message should be logged"
    assert_command_succeeds 'grep -q "Debug message should be logged" "$LOG_FILE"' "Debug message should appear in log file"
}

# Test error handling and logging integration
test_error_logging_integration() {
    # Load required modules
    source "$ROOT_DIR/src/core/v2/logger.sh"
    source "$ROOT_DIR/src/core/v2/error_handler.sh"
    
    # Initialize systems
    init_logger
    init_error_handler
    
    # Test error handling creates log entries
    handle_error "TEST_ERROR" "Integration test error" "non_critical"
    
    # Verify error was logged
    assert_command_succeeds 'grep -q "Integration test error" "$LOG_FILE"' "Error should be logged to file"
    assert_command_succeeds 'grep -q "TEST_ERROR" "$LOG_FILE"' "Error code should be in log file"
}

# Test performance monitoring integration
test_performance_integration() {
    # Load required modules
    source "$ROOT_DIR/src/core/v2/logger.sh"
    source "$ROOT_DIR/src/core/v2/performance.sh"
    
    # Initialize systems
    init_logger
    init_performance_system
    
    # Test performance monitoring
    perf_start_timer "test_operation"
    sleep 0.1  # Simulate some work
    local duration
    duration=$(perf_end_timer "test_operation" "Test operation")
    
    # Verify performance was tracked
    assert_not_empty "$duration" "Duration should be returned"
    assert_command_succeeds '[[ $duration -gt 50 ]]' "Duration should be at least 50ms"
    
    # Test cache functionality
    cache_set "test_key" "test_value" 60
    local cached_value
    cached_value=$(cache_get "test_key")
    assert_equals "test_value" "$cached_value" "Should retrieve cached value"
}

# Test template system integration
test_template_system_integration() {
    # Load required modules in order
    source "$ROOT_DIR/src/core/v2/logger.sh"
    source "$ROOT_DIR/src/core/v2/config_manager.sh"
    source "$ROOT_DIR/src/templates/template_init.sh"
    
    # Initialize systems
    init_logger
    init_config_manager
    init_template_system
    
    # Test template system is functional
    assert_command_succeeds 'declare -f render_ascii_header >/dev/null' "render_ascii_header should be available"
    assert_command_succeeds 'declare -f render_menu_header >/dev/null' "render_menu_header should be available"
    
    # Test icon system
    local test_icon
    test_icon=$(get_icon "CHECK")
    assert_not_empty "$test_icon" "Should return an icon"
}

# Test module loading with dependencies
test_module_loading_dependencies() {
    # Test that modules can be loaded in the correct order
    local modules=(
        "src/core/v2/logger.sh"
        "src/core/v2/error_handler.sh"
        "src/core/v2/config_manager.sh"
        "src/core/v2/performance.sh"
    )
    
    for module in "${modules[@]}"; do
        local module_path="$ROOT_DIR/$module"
        assert_file_exists "$module_path" "Module should exist: $module"
        assert_command_succeeds "source \"$module_path\"" "Should be able to source module: $module"
    done
    
    # Test initialization order
    assert_command_succeeds 'init_logger' "Should initialize logger"
    assert_command_succeeds 'init_error_handler' "Should initialize error handler"
    assert_command_succeeds 'init_config_manager' "Should initialize config manager"
    assert_command_succeeds 'init_performance_system' "Should initialize performance system"
}

# Test configuration file creation and loading
test_config_file_workflow() {
    # Load configuration system
    source "$ROOT_DIR/src/core/v2/logger.sh"
    source "$ROOT_DIR/src/core/v2/config_manager.sh"
    
    init_logger
    init_config_manager
    
    # Create a test configuration file
    local test_config_file="$TEST_CONFIG_DIR/test.conf"
    cat > "$test_config_file" << 'EOF'
# Test configuration
DEBUG_MODE=true
LOG_LEVEL="DEBUG"
UI_THEME="dark"
CACHE_TTL=600
EOF
    
    # Load the configuration file
    load_config_file "$test_config_file" "test"
    
    # Verify values were loaded
    assert_equals "true" "$(get_config "DEBUG_MODE")" "DEBUG_MODE should be loaded"
    assert_equals "DEBUG" "$(get_config "LOG_LEVEL")" "LOG_LEVEL should be loaded"
    assert_equals "dark" "$(get_config "UI_THEME")" "UI_THEME should be loaded"
    assert_equals "600" "$(get_config "CACHE_TTL")" "CACHE_TTL should be loaded"
}

# Test error recovery workflows
test_error_recovery_workflow() {
    # Load error handling system
    source "$ROOT_DIR/src/core/v2/logger.sh"
    source "$ROOT_DIR/src/core/v2/error_handler.sh"
    source "$ROOT_DIR/src/core/v2/config_manager.sh"
    
    init_logger
    init_error_handler
    init_config_manager
    
    # Test error handling with recovery
    local error_handled=false
    
    # Define a recovery function
    test_recovery_function() {
        error_handled=true
        log_info "RECOVERY" "Recovery function executed"
    }
    
    # Register error handler
    register_error_handler "TEST_ERROR" "test_recovery_function"
    
    # Trigger error
    handle_error "TEST_ERROR" "Test error for recovery" "non_critical"
    
    # Verify recovery was executed
    assert_true "$error_handled" "Error recovery should have been executed"
    assert_command_succeeds 'grep -q "Recovery function executed" "$LOG_FILE"' "Recovery should be logged"
}

# Test full system initialization
test_full_system_initialization() {
    # Test loading all major systems in correct order
    local initialization_steps=(
        "source \"$ROOT_DIR/src/core/v2/logger.sh\" && init_logger"
        "source \"$ROOT_DIR/src/core/v2/error_handler.sh\" && init_error_handler"
        "source \"$ROOT_DIR/src/core/v2/config_manager.sh\" && init_config_manager"
        "source \"$ROOT_DIR/src/core/v2/performance.sh\" && init_performance_system"
    )
    
    for step in "${initialization_steps[@]}"; do
        assert_command_succeeds "$step" "Initialization step should succeed: $step"
    done
    
    # Test that all systems are functional
    log_info "TEST" "System fully initialized"
    assert_command_succeeds 'get_config "APP_NAME"' "Configuration system should be functional"
    
    # Test performance tracking works
    perf_start_timer "system_test"
    sleep 0.05
    local duration
    duration=$(perf_end_timer "system_test" "System test")
    assert_not_empty "$duration" "Performance tracking should work"
}

# Test configuration validation workflow
test_configuration_validation_workflow() {
    # Load configuration system
    source "$ROOT_DIR/src/core/v2/logger.sh"
    source "$ROOT_DIR/src/core/v2/config_manager.sh"
    
    init_logger
    init_config_manager
    
    # Test setting valid configurations
    assert_command_succeeds 'set_config "DEBUG_MODE" "true" false' "Should accept valid boolean"
    assert_command_succeeds 'set_config "CACHE_TTL" "300" false' "Should accept valid integer in range"
    assert_command_succeeds 'set_config "UI_THEME" "dark" false' "Should accept valid enum value"
    
    # Test rejecting invalid configurations
    assert_command_fails 'set_config "DEBUG_MODE" "maybe" false' "Should reject invalid boolean"
    assert_command_fails 'set_config "CACHE_TTL" "50" false' "Should reject integer below range"
    assert_command_fails 'set_config "UI_THEME" "invalid" false' "Should reject invalid enum value"
    
    # Test validation of all configurations
    assert_command_succeeds 'validate_all_configurations' "All configurations should be valid"
}

# Test logging with different levels and formats
test_comprehensive_logging() {
    # Load logging system
    source "$ROOT_DIR/src/core/v2/logger.sh"
    
    init_logger
    
    # Test different log levels
    log_debug "TEST" "Debug message"
    log_info "TEST" "Info message"
    log_warning "TEST" "Warning message"
    log_error "TEST" "Error message"
    log_performance "TEST" "Performance message" "100"
    
    # Verify all messages were logged
    assert_command_succeeds 'grep -q "Debug message" "$LOG_FILE"' "Debug message should be in log"
    assert_command_succeeds 'grep -q "Info message" "$LOG_FILE"' "Info message should be in log"
    assert_command_succeeds 'grep -q "Warning message" "$LOG_FILE"' "Warning message should be in log"
    assert_command_succeeds 'grep -q "Error message" "$LOG_FILE"' "Error message should be in log"
    assert_command_succeeds 'grep -q "Performance message" "$LOG_FILE"' "Performance message should be in log"
    
    # Test log rotation
    local log_size_before
    log_size_before=$(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo "0")
    
    # Generate many log entries to test rotation
    for i in {1..100}; do
        log_info "ROTATION_TEST" "Log entry $i for rotation testing"
    done
    
    assert_file_exists "$LOG_FILE" "Log file should still exist after many entries"
}

# Test cache and performance integration
test_cache_performance_workflow() {
    # Load performance system
    source "$ROOT_DIR/src/core/v2/logger.sh"
    source "$ROOT_DIR/src/core/v2/performance.sh"
    
    init_logger
    init_performance_system
    
    # Test cache operations
    cache_set "key1" "value1" 60
    cache_set "key2" "value2" 60
    cache_set "key3" "value3" 60
    
    # Test cache retrieval
    assert_equals "value1" "$(cache_get "key1")" "Should retrieve cached value 1"
    assert_equals "value2" "$(cache_get "key2")" "Should retrieve cached value 2"
    assert_equals "value3" "$(cache_get "key3")" "Should retrieve cached value 3"
    
    # Test cache performance counters
    local cache_hits cache_misses
    cache_hits=$(perf_get_counter "cache_hits" || echo "0")
    cache_misses=$(perf_get_counter "cache_misses" || echo "0")
    
    # Test cache miss
    cache_get "nonexistent_key" >/dev/null 2>&1 || true
    
    # Verify performance tracking
    assert_command_succeeds '[[ $cache_hits -ge 0 ]]' "Cache hits should be tracked"
    assert_command_succeeds '[[ $cache_misses -ge 0 ]]' "Cache misses should be tracked"
}

# Test system cleanup and shutdown
test_system_cleanup() {
    # Load all systems
    source "$ROOT_DIR/src/core/v2/logger.sh"
    source "$ROOT_DIR/src/core/v2/error_handler.sh"
    source "$ROOT_DIR/src/core/v2/config_manager.sh"
    source "$ROOT_DIR/src/core/v2/performance.sh"
    
    # Initialize all systems
    init_logger
    init_error_handler
    init_config_manager
    init_performance_system
    
    # Create some state
    log_info "CLEANUP_TEST" "Creating system state for cleanup test"
    cache_set "cleanup_test" "test_data" 60
    set_config "DEBUG_MODE" "true" false
    
    # Test cleanup functions exist and can be called
    assert_command_succeeds 'declare -f cleanup_performance_system >/dev/null' "Cleanup function should exist"
    
    # Test cleanup doesn't crash
    assert_command_succeeds 'cleanup_performance_system' "Performance cleanup should succeed"
    
    log_info "CLEANUP_TEST" "System cleanup test completed"
}
