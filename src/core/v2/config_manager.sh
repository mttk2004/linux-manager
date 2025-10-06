#!/bin/bash

# Configuration Management System - V2 Architecture
# Provides flexible configuration with validation, user overrides, and environment-specific settings

# Define stub logging functions for testing environment
if [[ "${TESTING:-false}" == "true" ]]; then
    log_debug() { [[ "${TEST_VERBOSE:-false}" == "true" ]] && echo "[DEBUG] $*" >&2 || true; }
    log_info() { echo "[INFO] $*" >&2; }
    log_warning() { echo "[WARNING] $*" >&2; }
    log_error() { echo "[ERROR] $*" >&2; }
fi

# Configuration system status
CONFIG_SYSTEM_INITIALIZED=false

# Configuration directories
CONFIG_SYSTEM_DIR="${ROOT_DIR}/config"
CONFIG_USER_DIR="${HOME}/.config/linux-manager"
CONFIG_GLOBAL_DIR="/etc/linux-manager"

# Configuration files
CONFIG_DEFAULT_FILE="${CONFIG_SYSTEM_DIR}/default.conf"
CONFIG_USER_FILE="${CONFIG_USER_DIR}/user.conf"
CONFIG_GLOBAL_FILE="${CONFIG_GLOBAL_DIR}/global.conf"
CONFIG_OVERRIDE_FILE="${CONFIG_USER_DIR}/override.conf"

# Configuration registry
declare -A CONFIG_VALUES=()
declare -A CONFIG_DEFAULTS=()
declare -A CONFIG_VALIDATORS=()
declare -A CONFIG_DESCRIPTIONS=()
declare -A CONFIG_CATEGORIES=()

# Configuration change callbacks
declare -A CONFIG_CALLBACKS=()

# Environment detection
DETECTED_ENVIRONMENT=""

# Initialize configuration management system
init_config_manager() {
    log_info "CONFIG_MANAGER" "Initializing configuration management system..."
    
    # Detect environment
    detect_environment
    
    # Create configuration directories
    create_config_directories
    
    # Load configuration schema
    load_config_schema
    
    # Load configurations in priority order
    load_configurations
    
    # Validate configuration
    validate_all_configurations
    
    CONFIG_SYSTEM_INITIALIZED=true
    log_info "CONFIG_MANAGER" "Configuration management system initialized"
    
    return 0
}

# Detect current environment
detect_environment() {
    DETECTED_ENVIRONMENT="production"
    
    # Check for development indicators
    if [[ -f "${ROOT_DIR}/.git/config" ]] || [[ -d "${ROOT_DIR}/.git" ]]; then
        DETECTED_ENVIRONMENT="development"
    fi
    
    # Check for testing indicators
    if [[ "${BASH_SOURCE[0]}" =~ test ]] || [[ -n "${TESTING:-}" ]]; then
        DETECTED_ENVIRONMENT="testing"
    fi
    
    # Allow environment override
    DETECTED_ENVIRONMENT="${ENVIRONMENT:-$DETECTED_ENVIRONMENT}"
    
    log_info "CONFIG_MANAGER" "Detected environment: $DETECTED_ENVIRONMENT"
}

# Create necessary configuration directories
create_config_directories() {
    local directories=(
        "$CONFIG_SYSTEM_DIR"
        "$CONFIG_USER_DIR"
    )
    
    # Only create global directory if running as root
    if [[ $EUID -eq 0 ]]; then
        directories+=("$CONFIG_GLOBAL_DIR")
    fi
    
    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            if mkdir -p "$dir" 2>/dev/null; then
                log_debug "CONFIG_MANAGER" "Created configuration directory: $dir"
            else
                log_warning "CONFIG_MANAGER" "Failed to create configuration directory: $dir"
            fi
        fi
    done
}

# Load configuration schema definitions
load_config_schema() {
    log_debug "CONFIG_MANAGER" "Loading configuration schema..."
    
    # Core system configuration
    register_config "APP_NAME" "Linux Manager" "string" "Application name" "core"
    register_config "APP_VERSION" "2.0.0" "version" "Application version" "core"
    register_config "DEBUG_MODE" "false" "boolean" "Enable debug mode" "core"
    register_config "VERBOSE_LOGGING" "false" "boolean" "Enable verbose logging" "core"
    register_config "LOG_LEVEL" "INFO" "enum:DEBUG,INFO,WARNING,ERROR" "Logging level" "core"
    
    # UI Configuration
    register_config "UI_THEME" "default" "enum:default,dark" "UI theme" "ui"
    register_config "UI_ANIMATION_ENABLED" "true" "boolean" "Enable UI animations" "ui"
    register_config "UI_WIDTH" "80" "integer:40,200" "Terminal width" "ui"
    register_config "UI_LANGUAGE" "vi" "enum:vi,en" "Interface language" "ui"
    
    # Performance configuration
    register_config "PERF_ENABLED" "true" "boolean" "Enable performance monitoring" "performance"
    register_config "PERF_CACHE_ENABLED" "true" "boolean" "Enable caching system" "performance"
    register_config "PERF_LAZY_LOADING" "true" "boolean" "Enable lazy loading" "performance"
    register_config "CACHE_TTL" "300" "integer:60,3600" "Cache TTL in seconds" "performance"
    register_config "CACHE_MAX_SIZE" "1000" "integer:100,10000" "Maximum cache entries" "performance"
    register_config "PERF_MEMORY_THRESHOLD" "100" "integer:50,1000" "Memory threshold in MB" "performance"
    
    # Package management configuration
    register_config "PACKAGE_CACHE_ENABLED" "true" "boolean" "Enable package caching" "packages"
    register_config "PACKAGE_CACHE_TTL" "1800" "integer:300,7200" "Package cache TTL" "packages"
    register_config "PREFERRED_AUR_HELPER" "auto" "enum:auto,yay,paru,trizen" "Preferred AUR helper" "packages"
    register_config "PACKAGE_PARALLEL_JOBS" "4" "integer:1,16" "Parallel package operations" "packages"
    
    # I/O configuration
    register_config "IO_CACHE_ENABLED" "true" "boolean" "Enable I/O caching" "io"
    register_config "IO_BUFFER_SIZE" "8192" "integer:1024,65536" "I/O buffer size" "io"
    register_config "IO_PARALLEL_ENABLED" "true" "boolean" "Enable parallel I/O" "io"
    register_config "IO_COMPRESSION_ENABLED" "false" "boolean" "Enable I/O compression" "io"
    
    # Development configuration
    register_config "PHP_DEFAULT_VERSION" "8.3" "version" "Default PHP version" "development"
    register_config "NODEJS_DEFAULT_VERSION" "lts" "enum:lts,latest,18,20,21" "Default Node.js version" "development"
    register_config "DEVELOPMENT_MODE" "false" "boolean" "Enable development features" "development"
    
    # Security configuration
    register_config "BACKUP_ENABLED" "true" "boolean" "Enable automatic backups" "security"
    register_config "BACKUP_COMPRESSION" "false" "boolean" "Compress backups" "security"
    register_config "MAX_BACKUP_AGE" "7" "integer:1,30" "Max backup age in days" "security"
    register_config "SECURE_MODE" "false" "boolean" "Enable secure mode" "security"
    
    log_debug "CONFIG_MANAGER" "Configuration schema loaded"
}

# Register a configuration option
register_config() {
    local key="$1"
    local default_value="$2"
    local validator="$3"
    local description="$4"
    local category="$5"
    local callback="${6:-}"
    
    CONFIG_DEFAULTS["$key"]="$default_value"
    CONFIG_VALIDATORS["$key"]="$validator"
    CONFIG_DESCRIPTIONS["$key"]="$description"
    CONFIG_CATEGORIES["$key"]="$category"
    
    if [[ -n "$callback" ]]; then
        CONFIG_CALLBACKS["$key"]="$callback"
    fi
    
    # Set initial value to default
    CONFIG_VALUES["$key"]="$default_value"
    
    log_debug "CONFIG_MANAGER" "Registered config: $key = $default_value"
}

# Load configurations from files in priority order
load_configurations() {
    log_debug "CONFIG_MANAGER" "Loading configurations..."
    
    # 1. Load default configuration (lowest priority)
    load_config_file "$CONFIG_DEFAULT_FILE" "default"
    
    # 2. Load global system configuration
    if [[ -f "$CONFIG_GLOBAL_FILE" ]]; then
        load_config_file "$CONFIG_GLOBAL_FILE" "global"
    fi
    
    # 3. Load user configuration
    if [[ -f "$CONFIG_USER_FILE" ]]; then
        load_config_file "$CONFIG_USER_FILE" "user"
    fi
    
    # 4. Load environment-specific configuration
    local env_config_file="${CONFIG_USER_DIR}/${DETECTED_ENVIRONMENT}.conf"
    if [[ -f "$env_config_file" ]]; then
        load_config_file "$env_config_file" "environment"
    fi
    
    # 5. Load override configuration (highest priority)
    if [[ -f "$CONFIG_OVERRIDE_FILE" ]]; then
        load_config_file "$CONFIG_OVERRIDE_FILE" "override"
    fi
    
    # 6. Load environment variables
    load_environment_variables
    
    log_info "CONFIG_MANAGER" "All configurations loaded"
}

# Load configuration from a specific file
load_config_file() {
    local config_file="$1"
    local config_type="$2"
    
    if [[ ! -f "$config_file" ]]; then
        log_debug "CONFIG_MANAGER" "Configuration file not found: $config_file"
        return 0
    fi
    
    log_debug "CONFIG_MANAGER" "Loading $config_type configuration from: $config_file"
    
    local line_number=0
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_number++))
        
        # Skip empty lines and comments
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Parse key=value pairs
        if [[ "$line" =~ ^[[:space:]]*([A-Z_][A-Z0-9_]*)[[:space:]]*=[[:space:]]*(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            
            # Remove quotes from value
            value="${value#\"}"
            value="${value%\"}"
            value="${value#\'}"
            value="${value%\'}"
            
            # Only set if key is registered
            if [[ -n "${CONFIG_DEFAULTS[$key]:-}" ]]; then
                CONFIG_VALUES["$key"]="$value"
                log_debug "CONFIG_MANAGER" "Loaded $config_type config: $key = $value"
            else
                log_warning "CONFIG_MANAGER" "Unknown configuration key in $config_file:$line_number: $key"
            fi
        else
            log_warning "CONFIG_MANAGER" "Invalid configuration line in $config_file:$line_number: $line"
        fi
    done < "$config_file"
}

# Load environment variable overrides
load_environment_variables() {
    log_debug "CONFIG_MANAGER" "Loading environment variable overrides..."
    
    for key in "${!CONFIG_DEFAULTS[@]}"; do
        # Check for environment variable with LM_ prefix
        local env_var="LM_${key}"
        local env_value="${!env_var:-}"
        
        if [[ -n "$env_value" ]]; then
            CONFIG_VALUES["$key"]="$env_value"
            log_debug "CONFIG_MANAGER" "Environment override: $key = $env_value"
        fi
    done
}

# Get configuration value
get_config() {
    local key="$1"
    local default_value="${2:-}"
    
    if [[ -n "${CONFIG_VALUES[$key]:-}" ]]; then
        echo "${CONFIG_VALUES[$key]}"
    elif [[ -n "${CONFIG_DEFAULTS[$key]:-}" ]]; then
        echo "${CONFIG_DEFAULTS[$key]}"
    elif [[ -n "$default_value" ]]; then
        echo "$default_value"
    else
        log_warning "CONFIG_MANAGER" "Configuration key not found: $key"
        return 1
    fi
}

# Set configuration value
set_config() {
    local key="$1"
    local value="$2"
    local persist="${3:-false}"
    
    if [[ -z "${CONFIG_DEFAULTS[$key]:-}" ]]; then
        log_error "CONFIG_MANAGER" "Cannot set unregistered configuration key: $key"
        return 1
    fi
    
    # Validate the value
    if ! validate_config_value "$key" "$value"; then
        log_error "CONFIG_MANAGER" "Invalid value for configuration key $key: $value"
        return 1
    fi
    
    local old_value="${CONFIG_VALUES[$key]:-}"
    CONFIG_VALUES["$key"]="$value"
    
    # Call callback if registered
    local callback="${CONFIG_CALLBACKS[$key]:-}"
    if [[ -n "$callback" ]]; then
        "$callback" "$key" "$old_value" "$value"
    fi
    
    # Persist to user configuration if requested
    if [[ "$persist" == "true" ]]; then
        save_user_config "$key" "$value"
    fi
    
    log_info "CONFIG_MANAGER" "Configuration updated: $key = $value"
    return 0
}

# Validate a configuration value
validate_config_value() {
    local key="$1"
    local value="$2"
    
    local validator="${CONFIG_VALIDATORS[$key]:-string}"
    
    case "$validator" in
        "boolean")
            [[ "$value" =~ ^(true|false)$ ]]
            ;;
        "integer")
            [[ "$value" =~ ^[0-9]+$ ]]
            ;;
        "integer:"*)
            local range="${validator#integer:}"
            local min="${range%,*}"
            local max="${range#*,}"
            [[ "$value" =~ ^[0-9]+$ ]] && [[ $value -ge $min ]] && [[ $value -le $max ]]
            ;;
        "enum:"*)
            local options="${validator#enum:}"
            IFS=',' read -ra valid_options <<< "$options"
            local valid=false
            for option in "${valid_options[@]}"; do
                if [[ "$value" == "$option" ]]; then
                    valid=true
                    break
                fi
            done
            $valid
            ;;
        "version")
            [[ "$value" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?([a-zA-Z0-9.-]+)?$ ]]
            ;;
        "string")
            true  # Any string is valid
            ;;
        *)
            log_warning "CONFIG_MANAGER" "Unknown validator for $key: $validator"
            true
            ;;
    esac
}

# Validate all configurations
validate_all_configurations() {
    log_debug "CONFIG_MANAGER" "Validating all configurations..."
    
    local validation_errors=()
    
    for key in "${!CONFIG_VALUES[@]}"; do
        local value="${CONFIG_VALUES[$key]}"
        
        if ! validate_config_value "$key" "$value"; then
            validation_errors+=("$key: '$value' (expected: ${CONFIG_VALIDATORS[$key]})")
        fi
    done
    
    if [[ ${#validation_errors[@]} -gt 0 ]]; then
        log_error "CONFIG_MANAGER" "Configuration validation errors:"
        for error in "${validation_errors[@]}"; do
            log_error "CONFIG_MANAGER" "  $error"
        done
        return 1
    fi
    
    log_info "CONFIG_MANAGER" "All configurations validated successfully"
    return 0
}

# Save user configuration
save_user_config() {
    local key="$1"
    local value="$2"
    
    # Ensure user config directory exists
    mkdir -p "$(dirname "$CONFIG_USER_FILE")" 2>/dev/null
    
    # Create or update user configuration file
    if [[ -f "$CONFIG_USER_FILE" ]]; then
        # Update existing key or append new one
        if grep -q "^${key}=" "$CONFIG_USER_FILE" 2>/dev/null; then
            sed -i "s/^${key}=.*/${key}=\"${value}\"/" "$CONFIG_USER_FILE"
        else
            echo "${key}=\"${value}\"" >> "$CONFIG_USER_FILE"
        fi
    else
        # Create new user config file
        cat > "$CONFIG_USER_FILE" << EOF
# Linux Manager User Configuration
# Generated on $(date)

${key}="${value}"
EOF
    fi
    
    log_debug "CONFIG_MANAGER" "Saved user config: $key = $value"
}

# Export configuration as environment variables
export_config_as_env() {
    log_debug "CONFIG_MANAGER" "Exporting configuration as environment variables..."
    
    for key in "${!CONFIG_VALUES[@]}"; do
        export "$key"="${CONFIG_VALUES[$key]}"
    done
    
    # Also export with LM_ prefix for external tools
    for key in "${!CONFIG_VALUES[@]}"; do
        export "LM_$key"="${CONFIG_VALUES[$key]}"
    done
}

# Get configuration by category
get_config_by_category() {
    local category="$1"
    
    declare -A category_configs=()
    
    for key in "${!CONFIG_CATEGORIES[@]}"; do
        if [[ "${CONFIG_CATEGORIES[$key]}" == "$category" ]]; then
            category_configs["$key"]="${CONFIG_VALUES[$key]}"
        fi
    done
    
    # Return as key=value pairs
    for key in "${!category_configs[@]}"; do
        echo "$key=${category_configs[$key]}"
    done
}

# Get all configuration categories
get_config_categories() {
    local categories=()
    
    for category in "${CONFIG_CATEGORIES[@]}"; do
        # Add to array if not already present
        local found=false
        for existing in "${categories[@]}"; do
            if [[ "$existing" == "$category" ]]; then
                found=true
                break
            fi
        done
        
        if [[ "$found" == "false" ]]; then
            categories+=("$category")
        fi
    done
    
    printf '%s\n' "${categories[@]}" | sort
}

# Reset configuration to defaults
reset_config() {
    local key="$1"
    local persist="${2:-false}"
    
    if [[ -z "${CONFIG_DEFAULTS[$key]:-}" ]]; then
        log_error "CONFIG_MANAGER" "Cannot reset unregistered configuration key: $key"
        return 1
    fi
    
    local default_value="${CONFIG_DEFAULTS[$key]}"
    set_config "$key" "$default_value" "$persist"
    
    log_info "CONFIG_MANAGER" "Configuration reset to default: $key = $default_value"
}

# Create default configuration file
create_default_config_file() {
    log_info "CONFIG_MANAGER" "Creating default configuration file..."
    
    mkdir -p "$(dirname "$CONFIG_DEFAULT_FILE")" 2>/dev/null
    
    cat > "$CONFIG_DEFAULT_FILE" << 'EOF'
# Linux Manager Default Configuration
# This file contains the default configuration values
# DO NOT EDIT - Use user.conf for customizations

# Core System Configuration
APP_NAME="Linux Manager"
APP_VERSION="2.0.0"
DEBUG_MODE=false
VERBOSE_LOGGING=false
LOG_LEVEL="INFO"

# UI Configuration  
UI_THEME="default"
UI_ANIMATION_ENABLED=true
UI_WIDTH=80
UI_LANGUAGE="vi"

# Performance Configuration
PERF_ENABLED=true
PERF_CACHE_ENABLED=true
PERF_LAZY_LOADING=true
CACHE_TTL=300
CACHE_MAX_SIZE=1000
PERF_MEMORY_THRESHOLD=100

# Package Management
PACKAGE_CACHE_ENABLED=true
PACKAGE_CACHE_TTL=1800
PREFERRED_AUR_HELPER="auto"
PACKAGE_PARALLEL_JOBS=4

# I/O Configuration
IO_CACHE_ENABLED=true
IO_BUFFER_SIZE=8192
IO_PARALLEL_ENABLED=true
IO_COMPRESSION_ENABLED=false

# Development Configuration
PHP_DEFAULT_VERSION="8.3"
NODEJS_DEFAULT_VERSION="lts"
DEVELOPMENT_MODE=false

# Security Configuration
BACKUP_ENABLED=true
BACKUP_COMPRESSION=false
MAX_BACKUP_AGE=7
SECURE_MODE=false
EOF
    
    log_info "CONFIG_MANAGER" "Default configuration file created: $CONFIG_DEFAULT_FILE"
}

# Export configuration management functions
export -f init_config_manager detect_environment create_config_directories
export -f load_config_schema register_config load_configurations load_config_file
export -f load_environment_variables get_config set_config validate_config_value
export -f validate_all_configurations save_user_config export_config_as_env
export -f get_config_by_category get_config_categories reset_config
export -f create_default_config_file
