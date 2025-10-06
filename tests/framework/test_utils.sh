#!/bin/bash

# Test Utilities - V2 Architecture
# Provides helper functions and utilities for testing

# Test utility functions
create_test_config_file() {
    local config_file="$1"
    local config_content="$2"
    
    mkdir -p "$(dirname "$config_file")" 2>/dev/null
    echo "$config_content" > "$config_file"
}

create_test_log_file() {
    local log_file="$1"
    local log_content="${2:-Test log content}"
    
    mkdir -p "$(dirname "$log_file")" 2>/dev/null
    echo "$log_content" > "$log_file"
}

create_temp_test_dir() {
    local prefix="${1:-linux_manager_test}"
    mktemp -d -t "${prefix}.XXXXXX"
}

cleanup_temp_test_dir() {
    local test_dir="$1"
    [[ -n "$test_dir" && "$test_dir" =~ /tmp/ ]] && rm -rf "$test_dir" 2>/dev/null
}

mock_command() {
    local command_name="$1"
    local mock_output="$2"
    local mock_exit_code="${3:-0}"
    
    # Create mock function
    eval "${command_name}() { echo '$mock_output'; return $mock_exit_code; }"
    export -f "$command_name"
}

unmock_command() {
    local command_name="$1"
    unset -f "$command_name" 2>/dev/null
}

wait_for_condition() {
    local condition="$1"
    local timeout="${2:-10}"
    local interval="${3:-0.1}"
    
    local elapsed=0
    while ! eval "$condition"; do
        sleep "$interval"
        elapsed=$(echo "$elapsed + $interval" | bc 2>/dev/null || awk "BEGIN{print $elapsed + $interval}")
        
        if (( $(echo "$elapsed >= $timeout" | bc -l) )); then
            return 1
        fi
    done
    
    return 0
}

# Test data generators
generate_test_config_data() {
    cat << 'EOF'
# Test Configuration Data
APP_NAME="Test Linux Manager"
DEBUG_MODE=true
LOG_LEVEL="DEBUG"
UI_THEME="dark"
CACHE_TTL=300
PERF_ENABLED=true
EOF
}

generate_test_log_data() {
    local component="${1:-TEST}"
    cat << EOF
$(date '+%Y-%m-%d %H:%M:%S') [INFO] [$component] Test log entry 1
$(date '+%Y-%m-%d %H:%M:%S') [DEBUG] [$component] Test debug message
$(date '+%Y-%m-%d %H:%M:%S') [WARNING] [$component] Test warning message
$(date '+%Y-%m-%d %H:%M:%S') [ERROR] [$component] Test error message
EOF
}

generate_test_performance_data() {
    cat << 'EOF'
{
  "timestamp": "2024-01-01T12:00:00Z",
  "stats": {
    "total": 10,
    "passed": 8,
    "failed": 2,
    "skipped": 0
  },
  "results": {
    "test_function_1": {"result": "PASSED", "duration": 150},
    "test_function_2": {"result": "FAILED", "duration": 200}
  }
}
EOF
}

# File and directory assertions
assert_directory_exists() {
    local dir_path="$1"
    local message="${2:-Expected directory to exist: $dir_path}"
    
    if [[ -d "$dir_path" ]]; then
        test_pass "$message"
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_directory_not_exists() {
    local dir_path="$1"
    local message="${2:-Expected directory to not exist: $dir_path}"
    
    if [[ ! -d "$dir_path" ]]; then
        test_pass "$message"
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_file_contains() {
    local file_path="$1"
    local expected_content="$2"
    local message="${3:-Expected file to contain: $expected_content}"
    
    if [[ -f "$file_path" ]] && grep -q "$expected_content" "$file_path"; then
        test_pass "$message"
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_file_not_contains() {
    local file_path="$1"
    local unexpected_content="$2"
    local message="${3:-Expected file to not contain: $unexpected_content}"
    
    if [[ -f "$file_path" ]] && grep -q "$unexpected_content" "$file_path"; then
        test_fail "$message"
        return 1
    else
        test_pass "$message"
        return 0
    fi
}

assert_file_empty() {
    local file_path="$1"
    local message="${2:-Expected file to be empty: $file_path}"
    
    if [[ -f "$file_path" ]] && [[ ! -s "$file_path" ]]; then
        test_pass "$message"
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_file_not_empty() {
    local file_path="$1"
    local message="${2:-Expected file to not be empty: $file_path}"
    
    if [[ -f "$file_path" ]] && [[ -s "$file_path" ]]; then
        test_pass "$message"
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_file_size() {
    local file_path="$1"
    local expected_size="$2"
    local message="${3:-Expected file size to be $expected_size bytes: $file_path}"
    
    if [[ -f "$file_path" ]]; then
        local actual_size
        actual_size=$(stat -f%z "$file_path" 2>/dev/null || stat -c%s "$file_path" 2>/dev/null || echo "0")
        
        if [[ "$actual_size" -eq "$expected_size" ]]; then
            test_pass "$message"
            return 0
        else
            test_fail "$message (actual size: $actual_size)"
            return 1
        fi
    else
        test_fail "$message (file does not exist)"
        return 1
    fi
}

# Process and system assertions
assert_process_running() {
    local process_name="$1"
    local message="${2:-Expected process to be running: $process_name}"
    
    if pgrep "$process_name" >/dev/null 2>&1; then
        test_pass "$message"
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_process_not_running() {
    local process_name="$1"
    local message="${2:-Expected process to not be running: $process_name}"
    
    if ! pgrep "$process_name" >/dev/null 2>&1; then
        test_pass "$message"
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_env_var_set() {
    local var_name="$1"
    local expected_value="${2:-}"
    local message="${3:-Expected environment variable to be set: $var_name}"
    
    local actual_value="${!var_name:-}"
    
    if [[ -n "$actual_value" ]]; then
        if [[ -n "$expected_value" ]]; then
            assert_equals "$expected_value" "$actual_value" "$message (value check)"
        else
            test_pass "$message"
        fi
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

assert_env_var_unset() {
    local var_name="$1"
    local message="${2:-Expected environment variable to be unset: $var_name}"
    
    if [[ -z "${!var_name:-}" ]]; then
        test_pass "$message"
        return 0
    else
        test_fail "$message"
        return 1
    fi
}

# Network and connectivity assertions
assert_port_open() {
    local host="${1:-localhost}"
    local port="$2"
    local message="${3:-Expected port to be open: $host:$port}"
    
    if command -v nc >/dev/null 2>&1; then
        if nc -z "$host" "$port" 2>/dev/null; then
            test_pass "$message"
            return 0
        fi
    elif command -v telnet >/dev/null 2>&1; then
        if echo "" | telnet "$host" "$port" 2>/dev/null | grep -q "Connected"; then
            test_pass "$message"
            return 0
        fi
    fi
    
    test_fail "$message"
    return 1
}

assert_url_accessible() {
    local url="$1"
    local expected_status="${2:-200}"
    local message="${3:-Expected URL to be accessible: $url}"
    
    if command -v curl >/dev/null 2>&1; then
        local actual_status
        actual_status=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
        
        if [[ "$actual_status" == "$expected_status" ]]; then
            test_pass "$message"
            return 0
        else
            test_fail "$message (got status: $actual_status)"
            return 1
        fi
    else
        test_skip "$message (curl not available)"
        return 0
    fi
}

# Performance and timing assertions
assert_execution_time() {
    local command="$1"
    local max_seconds="$2"
    local message="${3:-Expected command to execute within $max_seconds seconds: $command}"
    
    local start_time
    start_time=$(date +%s)
    
    if eval "$command" >/dev/null 2>&1; then
        local end_time duration
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        
        if [[ $duration -le $max_seconds ]]; then
            test_pass "$message (took ${duration}s)"
            return 0
        else
            test_fail "$message (took ${duration}s, expected ≤${max_seconds}s)"
            return 1
        fi
    else
        test_fail "$message (command failed)"
        return 1
    fi
}

assert_memory_usage() {
    local max_memory_mb="$1"
    local message="${2:-Expected memory usage to be under $max_memory_mb MB}"
    
    local current_memory
    if command -v ps >/dev/null 2>&1; then
        current_memory=$(ps -o rss= -p $$ 2>/dev/null | awk '{print int($1/1024)}' || echo "0")
        
        if [[ $current_memory -le $max_memory_mb ]]; then
            test_pass "$message (using ${current_memory}MB)"
            return 0
        else
            test_fail "$message (using ${current_memory}MB, expected ≤${max_memory_mb}MB)"
            return 1
        fi
    else
        test_skip "$message (ps command not available)"
        return 0
    fi
}

# String and pattern matching utilities
assert_string_matches_pattern() {
    local string="$1"
    local pattern="$2"
    local message="${3:-Expected string to match pattern: $pattern}"
    
    if [[ "$string" =~ $pattern ]]; then
        test_pass "$message"
        return 0
    else
        test_fail "$message (string: $string)"
        return 1
    fi
}

assert_string_length() {
    local string="$1"
    local expected_length="$2"
    local message="${3:-Expected string length to be $expected_length}"
    
    local actual_length=${#string}
    
    if [[ $actual_length -eq $expected_length ]]; then
        test_pass "$message"
        return 0
    else
        test_fail "$message (actual length: $actual_length)"
        return 1
    fi
}

assert_string_starts_with() {
    local string="$1"
    local prefix="$2"
    local message="${3:-Expected string to start with: $prefix}"
    
    if [[ "$string" == "$prefix"* ]]; then
        test_pass "$message"
        return 0
    else
        test_fail "$message (string: $string)"
        return 1
    fi
}

assert_string_ends_with() {
    local string="$1"
    local suffix="$2"
    local message="${3:-Expected string to end with: $suffix}"
    
    if [[ "$string" == *"$suffix" ]]; then
        test_pass "$message"
        return 0
    else
        test_fail "$message (string: $string)"
        return 1
    fi
}

# Array utilities
assert_array_length() {
    local array_name="$1"
    local expected_length="$2"
    local message="${3:-Expected array length to be $expected_length}"
    
    declare -n arr_ref="$array_name"
    local actual_length=${#arr_ref[@]}
    
    if [[ $actual_length -eq $expected_length ]]; then
        test_pass "$message"
        return 0
    else
        test_fail "$message (actual length: $actual_length)"
        return 1
    fi
}

assert_array_contains() {
    local array_name="$1"
    local expected_value="$2"
    local message="${3:-Expected array to contain: $expected_value}"
    
    declare -n arr_ref="$array_name"
    
    for value in "${arr_ref[@]}"; do
        if [[ "$value" == "$expected_value" ]]; then
            test_pass "$message"
            return 0
        fi
    done
    
    test_fail "$message"
    return 1
}

# Configuration test helpers
setup_test_config() {
    local test_name="$1"
    local config_dir="${TEST_CONFIG_DIR:-$(mktemp -d)}"
    
    mkdir -p "$config_dir"
    
    # Create test configuration
    cat > "$config_dir/test.conf" << EOF
# Test Configuration for $test_name
DEBUG_MODE=true
LOG_LEVEL="DEBUG"
TESTING=true
TEST_NAME="$test_name"
EOF
    
    echo "$config_dir/test.conf"
}

setup_test_logging() {
    local test_name="$1"
    local log_dir="${TEST_LOGS_DIR:-$(mktemp -d)}"
    
    mkdir -p "$log_dir"
    
    export LOG_FILE="$log_dir/${test_name}.log"
    export LOG_LEVEL="DEBUG"
    export VERBOSE_LOGGING=true
    
    echo "$LOG_FILE"
}

# Test result helpers
print_test_summary() {
    local test_name="$1"
    local total_tests="$2"
    local passed_tests="$3"
    local failed_tests="$4"
    
    echo
    echo "========================================="
    echo "Test Summary: $test_name"
    echo "========================================="
    echo "Total Tests:  $total_tests"
    echo "Passed:       $passed_tests"
    echo "Failed:       $failed_tests"
    
    local success_rate=0
    if [[ $total_tests -gt 0 ]]; then
        success_rate=$((passed_tests * 100 / total_tests))
    fi
    
    echo "Success Rate: ${success_rate}%"
    echo "========================================="
}

# Export utility functions
export -f create_test_config_file create_test_log_file create_temp_test_dir cleanup_temp_test_dir
export -f mock_command unmock_command wait_for_condition
export -f generate_test_config_data generate_test_log_data generate_test_performance_data
export -f assert_directory_exists assert_directory_not_exists assert_file_contains assert_file_not_contains
export -f assert_file_empty assert_file_not_empty assert_file_size
export -f assert_process_running assert_process_not_running assert_env_var_set assert_env_var_unset
export -f assert_port_open assert_url_accessible assert_execution_time assert_memory_usage
export -f assert_string_matches_pattern assert_string_length assert_string_starts_with assert_string_ends_with
export -f assert_array_length assert_array_contains setup_test_config setup_test_logging print_test_summary
