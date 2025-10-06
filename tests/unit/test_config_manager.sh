#!/bin/bash

# Unit Tests for Configuration Manager - V2 Architecture

# Load the test framework
source "$(dirname "${BASH_SOURCE[0]}")/../framework/test_runner.sh"

# Load the configuration manager
source "$(dirname "${BASH_SOURCE[0]}")/../../src/core/v2/config_manager.sh"

# Test setup - runs before each test
test_setup() {
    # Create temporary test directories
    TEST_CONFIG_DIR=$(mktemp -d)
    TEST_USER_DIR=$(mktemp -d)
    
    # Override configuration directories for testing
    CONFIG_SYSTEM_DIR="$TEST_CONFIG_DIR/system"
    CONFIG_USER_DIR="$TEST_USER_DIR/user"
    CONFIG_DEFAULT_FILE="$CONFIG_SYSTEM_DIR/default.conf"
    CONFIG_USER_FILE="$CONFIG_USER_DIR/user.conf"
    
    mkdir -p "$CONFIG_SYSTEM_DIR" "$CONFIG_USER_DIR"
    
    # Reset configuration state
    CONFIG_VALUES=()
    CONFIG_DEFAULTS=()
    CONFIG_VALIDATORS=()
    CONFIG_DESCRIPTIONS=()
    CONFIG_CATEGORIES=()
    CONFIG_CALLBACKS=()
    CONFIG_SYSTEM_INITIALIZED=false
}

# Test teardown - runs after each test
test_teardown() {
    # Clean up temporary directories
    rm -rf "$TEST_CONFIG_DIR" "$TEST_USER_DIR" 2>/dev/null
}

# Test configuration schema registration
test_register_config() {
    register_config "TEST_KEY" "default_value" "string" "Test configuration" "test"
    
    assert_equals "default_value" "${CONFIG_DEFAULTS[TEST_KEY]}" "Default value should be set"
    assert_equals "string" "${CONFIG_VALIDATORS[TEST_KEY]}" "Validator should be set"
    assert_equals "Test configuration" "${CONFIG_DESCRIPTIONS[TEST_KEY]}" "Description should be set"
    assert_equals "test" "${CONFIG_CATEGORIES[TEST_KEY]}" "Category should be set"
    assert_equals "default_value" "${CONFIG_VALUES[TEST_KEY]}" "Initial value should be set to default"
}

# Test configuration value retrieval
test_get_config() {
    register_config "TEST_GET" "test_value" "string" "Test get config" "test"
    
    local value
    value=$(get_config "TEST_GET")
    assert_equals "test_value" "$value" "Should return the configured value"
    
    # Test fallback to provided default
    local missing_value
    missing_value=$(get_config "NONEXISTENT" "fallback")
    assert_equals "fallback" "$missing_value" "Should return fallback for missing key"
}

# Test configuration value setting
test_set_config() {
    register_config "TEST_SET" "original" "string" "Test set config" "test"
    
    # Test setting without persistence
    assert_command_succeeds 'set_config "TEST_SET" "new_value" false' "Should be able to set config value"
    
    local value
    value=$(get_config "TEST_SET")
    assert_equals "new_value" "$value" "Value should be updated"
    
    # Test setting invalid configuration key
    assert_command_fails 'set_config "INVALID_KEY" "value" false' "Should fail for unregistered key"
}

# Test boolean validation
test_validate_boolean() {
    register_config "BOOL_TEST" "true" "boolean" "Boolean test" "test"
    
    assert_command_succeeds 'validate_config_value "BOOL_TEST" "true"' "true should be valid boolean"
    assert_command_succeeds 'validate_config_value "BOOL_TEST" "false"' "false should be valid boolean"
    assert_command_fails 'validate_config_value "BOOL_TEST" "maybe"' "maybe should be invalid boolean"
    assert_command_fails 'validate_config_value "BOOL_TEST" "1"' "1 should be invalid boolean"
}

# Test integer validation
test_validate_integer() {
    register_config "INT_TEST" "100" "integer" "Integer test" "test"
    
    assert_command_succeeds 'validate_config_value "INT_TEST" "42"' "42 should be valid integer"
    assert_command_succeeds 'validate_config_value "INT_TEST" "0"' "0 should be valid integer"
    assert_command_fails 'validate_config_value "INT_TEST" "abc"' "abc should be invalid integer"
    assert_command_fails 'validate_config_value "INT_TEST" "3.14"' "3.14 should be invalid integer"
}

# Test integer range validation
test_validate_integer_range() {
    register_config "RANGE_TEST" "50" "integer:10,100" "Range test" "test"
    
    assert_command_succeeds 'validate_config_value "RANGE_TEST" "10"' "10 should be valid (min bound)"
    assert_command_succeeds 'validate_config_value "RANGE_TEST" "50"' "50 should be valid (middle)"
    assert_command_succeeds 'validate_config_value "RANGE_TEST" "100"' "100 should be valid (max bound)"
    assert_command_fails 'validate_config_value "RANGE_TEST" "5"' "5 should be invalid (below min)"
    assert_command_fails 'validate_config_value "RANGE_TEST" "150"' "150 should be invalid (above max)"
}

# Test enum validation
test_validate_enum() {
    register_config "ENUM_TEST" "option1" "enum:option1,option2,option3" "Enum test" "test"
    
    assert_command_succeeds 'validate_config_value "ENUM_TEST" "option1"' "option1 should be valid"
    assert_command_succeeds 'validate_config_value "ENUM_TEST" "option2"' "option2 should be valid"
    assert_command_succeeds 'validate_config_value "ENUM_TEST" "option3"' "option3 should be valid"
    assert_command_fails 'validate_config_value "ENUM_TEST" "invalid"' "invalid should be rejected"
}

# Test version validation
test_validate_version() {
    register_config "VERSION_TEST" "1.0.0" "version" "Version test" "test"
    
    assert_command_succeeds 'validate_config_value "VERSION_TEST" "1.0.0"' "1.0.0 should be valid version"
    assert_command_succeeds 'validate_config_value "VERSION_TEST" "2.1.3"' "2.1.3 should be valid version"
    assert_command_succeeds 'validate_config_value "VERSION_TEST" "1.0"' "1.0 should be valid version"
    assert_command_succeeds 'validate_config_value "VERSION_TEST" "3.2.1-beta"' "3.2.1-beta should be valid version"
    assert_command_fails 'validate_config_value "VERSION_TEST" "invalid"' "invalid should be rejected"
    assert_command_fails 'validate_config_value "VERSION_TEST" "1.a.0"' "1.a.0 should be rejected"
}

# Test environment detection
test_detect_environment() {
    # Test default production environment
    DETECTED_ENVIRONMENT=""
    detect_environment
    assert_equals "production" "$DETECTED_ENVIRONMENT" "Should default to production"
    
    # Test development environment detection (simulate .git directory)
    mkdir -p "$TEST_CONFIG_DIR/.git"
    ROOT_DIR="$TEST_CONFIG_DIR"
    DETECTED_ENVIRONMENT=""
    detect_environment
    assert_equals "development" "$DETECTED_ENVIRONMENT" "Should detect development environment"
    rm -rf "$TEST_CONFIG_DIR/.git"
    
    # Test testing environment detection
    TESTING="true"
    DETECTED_ENVIRONMENT=""
    detect_environment
    assert_equals "testing" "$DETECTED_ENVIRONMENT" "Should detect testing environment"
    
    # Test environment override
    ENVIRONMENT="custom"
    DETECTED_ENVIRONMENT=""
    detect_environment
    assert_equals "custom" "$DETECTED_ENVIRONMENT" "Should respect ENVIRONMENT override"
    unset ENVIRONMENT
}

# Test configuration file loading
test_load_config_file() {
    register_config "FILE_TEST_KEY" "default" "string" "File test" "test"
    
    # Create test configuration file
    cat > "$CONFIG_USER_FILE" << 'EOF'
# Test configuration file
FILE_TEST_KEY="loaded_value"
UNKNOWN_KEY="should_be_ignored"
EOF
    
    load_config_file "$CONFIG_USER_FILE" "user"
    
    local value
    value=$(get_config "FILE_TEST_KEY")
    assert_equals "loaded_value" "$value" "Should load value from file"
}

# Test configuration file parsing with various formats
test_config_file_parsing() {
    register_config "QUOTED_TEST" "default" "string" "Quoted test" "test"
    register_config "UNQUOTED_TEST" "default" "string" "Unquoted test" "test"
    register_config "SPACES_TEST" "default" "string" "Spaces test" "test"
    
    # Create test file with various formats
    cat > "$CONFIG_USER_FILE" << 'EOF'
# Test various configuration formats
QUOTED_TEST="quoted_value"
UNQUOTED_TEST=unquoted_value
SPACES_TEST = "value with spaces"

# This is a comment and should be ignored
# COMMENTED_KEY="should_not_load"

EOF
    
    load_config_file "$CONFIG_USER_FILE" "user"
    
    assert_equals "quoted_value" "$(get_config "QUOTED_TEST")" "Should handle quoted values"
    assert_equals "unquoted_value" "$(get_config "UNQUOTED_TEST")" "Should handle unquoted values"
    assert_equals "value with spaces" "$(get_config "SPACES_TEST")" "Should handle values with spaces"
}

# Test configuration reset functionality
test_reset_config() {
    register_config "RESET_TEST" "original" "string" "Reset test" "test"
    
    # Change the value
    set_config "RESET_TEST" "changed" false
    assert_equals "changed" "$(get_config "RESET_TEST")" "Value should be changed"
    
    # Reset to default
    assert_command_succeeds 'reset_config "RESET_TEST" false' "Should be able to reset config"
    assert_equals "original" "$(get_config "RESET_TEST")" "Value should be reset to default"
    
    # Test resetting non-existent key
    assert_command_fails 'reset_config "NONEXISTENT" false' "Should fail for non-existent key"
}

# Test configuration categories
test_get_config_by_category() {
    register_config "CAT1_KEY1" "value1" "string" "Category 1 Key 1" "category1"
    register_config "CAT1_KEY2" "value2" "string" "Category 1 Key 2" "category1"
    register_config "CAT2_KEY1" "value3" "string" "Category 2 Key 1" "category2"
    
    local cat1_configs
    cat1_configs=$(get_config_by_category "category1")
    
    assert_contains "$cat1_configs" "CAT1_KEY1=value1" "Should contain first key from category1"
    assert_contains "$cat1_configs" "CAT1_KEY2=value2" "Should contain second key from category1"
    assert_not_contains "$cat1_configs" "CAT2_KEY1=value3" "Should not contain key from category2"
}

# Test getting all categories
test_get_config_categories() {
    register_config "KEY1" "value1" "string" "Key 1" "cat_a"
    register_config "KEY2" "value2" "string" "Key 2" "cat_b"
    register_config "KEY3" "value3" "string" "Key 3" "cat_a"
    
    local categories
    categories=$(get_config_categories)
    
    assert_contains "$categories" "cat_a" "Should contain cat_a"
    assert_contains "$categories" "cat_b" "Should contain cat_b"
}

# Test environment variable overrides
test_load_environment_variables() {
    register_config "ENV_TEST" "default" "string" "Environment test" "test"
    
    # Set environment variable with LM_ prefix
    export LM_ENV_TEST="env_value"
    
    load_environment_variables
    
    local value
    value=$(get_config "ENV_TEST")
    assert_equals "env_value" "$value" "Should load value from environment variable"
    
    unset LM_ENV_TEST
}

# Test configuration persistence
test_save_user_config() {
    register_config "SAVE_TEST" "default" "string" "Save test" "test"
    
    # Save configuration
    save_user_config "SAVE_TEST" "saved_value"
    
    assert_file_exists "$CONFIG_USER_FILE" "User config file should be created"
    
    # Verify file contents
    local file_contents
    file_contents=$(cat "$CONFIG_USER_FILE")
    assert_contains "$file_contents" "SAVE_TEST=\"saved_value\"" "File should contain saved configuration"
}

# Helper function for assert_not_contains
assert_not_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-Expected '$haystack' to not contain '$needle'}"
    
    if [[ ! "$haystack" =~ $needle ]]; then
        test_pass "$message"
        return 0
    else
        test_fail "$message"
        return 1
    fi
}
