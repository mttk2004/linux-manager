#!/bin/bash

# Module Registry System - V2 Architecture
# Centralized registry for all system modules with metadata, versioning, and status tracking
#
# Features:
# - Centralized module metadata storage
# - Version compatibility checking
# - Module dependency mapping
# - Status tracking and history
# - Performance metrics collection
# - Module capability registration
# - Search and filtering capabilities

# Define stub logging functions for testing environment
if [[ "${TESTING:-false}" == "true" ]]; then
    log_debug() { [[ "${TEST_VERBOSE:-false}" == "true" ]] && echo "[DEBUG] $*" >&2 || true; }
    log_info() { echo "[INFO] $*" >&2; }
    log_warning() { echo "[WARNING] $*" >&2; }
    log_error() { echo "[ERROR] $*" >&2; }
fi

# Registry configuration
declare -g REGISTRY_INITIALIZED=false
declare -g REGISTRY_VERSION="2.0.0"
declare -g REGISTRY_DATA_DIR="${ROOT_DIR}/data/registry"
declare -g REGISTRY_CACHE_DIR="${ROOT_DIR}/.cache/registry"
declare -g REGISTRY_BACKUP_DIR="${ROOT_DIR}/backup/registry"

# Registry storage
declare -gA MODULE_REGISTRY_DB=()
declare -gA MODULE_CAPABILITIES=()
declare -gA MODULE_PERFORMANCE_METRICS=()
declare -gA MODULE_STATUS_HISTORY=()
declare -gA MODULE_VERSION_COMPATIBILITY=()
declare -gA MODULE_TAGS=()
declare -gA MODULE_SEARCH_INDEX=()

# Registry file paths
declare -g REGISTRY_MAIN_FILE="${REGISTRY_DATA_DIR}/modules.registry"
declare -g REGISTRY_CAPABILITIES_FILE="${REGISTRY_DATA_DIR}/capabilities.registry"
declare -g REGISTRY_METRICS_FILE="${REGISTRY_DATA_DIR}/metrics.registry"
declare -g REGISTRY_HISTORY_FILE="${REGISTRY_DATA_DIR}/history.registry"

# Initialize the module registry
init_module_registry() {
    log_info "MODULE_REGISTRY" "Initializing module registry system..."
    
    # Create registry directories
    create_registry_directories
    
    # Load existing registry data
    load_registry_data
    
    # Initialize search index
    build_search_index
    
    REGISTRY_INITIALIZED=true
    log_info "MODULE_REGISTRY" "Module registry system initialized"
    
    return 0
}

# Create necessary registry directories
create_registry_directories() {
    local directories=(
        "$REGISTRY_DATA_DIR"
        "$REGISTRY_CACHE_DIR"
        "$REGISTRY_BACKUP_DIR"
    )
    
    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            if mkdir -p "$dir" 2>/dev/null; then
                log_debug "MODULE_REGISTRY" "Created registry directory: $dir"
            else
                log_warning "MODULE_REGISTRY" "Failed to create registry directory: $dir"
            fi
        fi
    done
}

# Load existing registry data from files
load_registry_data() {
    log_debug "MODULE_REGISTRY" "Loading registry data..."
    
    # Load main registry
    if [[ -f "$REGISTRY_MAIN_FILE" ]]; then
        load_registry_file "$REGISTRY_MAIN_FILE" "MODULE_REGISTRY_DB"
    fi
    
    # Load capabilities
    if [[ -f "$REGISTRY_CAPABILITIES_FILE" ]]; then
        load_registry_file "$REGISTRY_CAPABILITIES_FILE" "MODULE_CAPABILITIES"
    fi
    
    # Load metrics
    if [[ -f "$REGISTRY_METRICS_FILE" ]]; then
        load_registry_file "$REGISTRY_METRICS_FILE" "MODULE_PERFORMANCE_METRICS"
    fi
    
    # Load history
    if [[ -f "$REGISTRY_HISTORY_FILE" ]]; then
        load_registry_file "$REGISTRY_HISTORY_FILE" "MODULE_STATUS_HISTORY"
    fi
    
    log_info "MODULE_REGISTRY" "Registry data loaded"
}

# Load registry data from a specific file
load_registry_file() {
    local file_path="$1"
    local array_name="$2"
    local line_count=0
    
    while IFS='=' read -r key value || [[ -n "$key" ]]; do
        ((line_count++))
        
        # Skip empty lines and comments
        [[ -z "${key// }" ]] && continue
        [[ "$key" =~ ^[[:space:]]*# ]] && continue
        
        # Store in the specified associative array
        case "$array_name" in
            "MODULE_REGISTRY_DB")
                MODULE_REGISTRY_DB["$key"]="$value"
                ;;
            "MODULE_CAPABILITIES")
                MODULE_CAPABILITIES["$key"]="$value"
                ;;
            "MODULE_PERFORMANCE_METRICS")
                MODULE_PERFORMANCE_METRICS["$key"]="$value"
                ;;
            "MODULE_STATUS_HISTORY")
                MODULE_STATUS_HISTORY["$key"]="$value"
                ;;
        esac
    done < "$file_path"
    
    log_debug "MODULE_REGISTRY" "Loaded $line_count entries from $(basename "$file_path")"
}

# Register a new module in the registry
register_module_in_registry() {
    local module_name="$1"
    local module_data="$2"  # Serialized module information
    
    log_debug "MODULE_REGISTRY" "Registering module in registry: $module_name"
    
    # Parse module data
    local entry_point version description author license dependencies tags
    while IFS=',' read -ra data_parts; do
        for part in "${data_parts[@]}"; do
            case "$part" in
                entry_point:*)
                    entry_point="${part#entry_point:}"
                    ;;
                version:*)
                    version="${part#version:}"
                    ;;
                description:*)
                    description="${part#description:}"
                    ;;
                author:*)
                    author="${part#author:}"
                    ;;
                license:*)
                    license="${part#license:}"
                    ;;
                dependencies:*)
                    dependencies="${part#dependencies:}"
                    ;;
                tags:*)
                    tags="${part#tags:}"
                    ;;
            esac
        done
    done <<< "$module_data"
    
    # Create registry entry
    local timestamp=$(date -Iseconds)
    local registry_entry="entry_point:$entry_point,version:$version,description:$description,author:$author,license:$license,dependencies:$dependencies,registered:$timestamp,status:registered"
    
    MODULE_REGISTRY_DB["$module_name"]="$registry_entry"
    
    # Store tags for searching
    if [[ -n "$tags" ]]; then
        MODULE_TAGS["$module_name"]="$tags"
    fi
    
    # Add to search index
    add_to_search_index "$module_name" "$description" "$tags"
    
    # Record registration in history
    record_module_status_change "$module_name" "registered" "Module registered in registry"
    
    log_info "MODULE_REGISTRY" "Module registered: $module_name (v$version)"
    return 0
}

# Update module information in registry
update_module_in_registry() {
    local module_name="$1"
    local field="$2"
    local new_value="$3"
    
    if [[ -z "${MODULE_REGISTRY_DB[$module_name]:-}" ]]; then
        log_error "MODULE_REGISTRY" "Module not found in registry: $module_name"
        return 1
    fi
    
    log_debug "MODULE_REGISTRY" "Updating module registry: $module_name.$field = $new_value"
    
    # Parse current data
    local current_data="${MODULE_REGISTRY_DB[$module_name]}"
    local updated_data=""
    local found_field=false
    
    # Update the specific field
    IFS=',' read -ra data_parts <<< "$current_data"
    for part in "${data_parts[@]}"; do
        if [[ "$part" =~ ^$field: ]]; then
            updated_data="${updated_data}${field}:${new_value},"
            found_field=true
        else
            updated_data="${updated_data}${part},"
        fi
    done
    
    # Add field if it didn't exist
    if [[ "$found_field" == "false" ]]; then
        updated_data="${updated_data}${field}:${new_value},"
    fi
    
    # Remove trailing comma
    updated_data="${updated_data%,}"
    
    MODULE_REGISTRY_DB["$module_name"]="$updated_data"
    
    # Record change in history
    record_module_status_change "$module_name" "updated" "Updated $field to $new_value"
    
    log_info "MODULE_REGISTRY" "Module registry updated: $module_name.$field"
    return 0
}

# Get module information from registry
get_module_from_registry() {
    local module_name="$1"
    local field="${2:-all}"
    
    if [[ -z "${MODULE_REGISTRY_DB[$module_name]:-}" ]]; then
        return 1
    fi
    
    local registry_data="${MODULE_REGISTRY_DB[$module_name]}"
    
    if [[ "$field" == "all" ]]; then
        echo "$registry_data"
        return 0
    fi
    
    # Extract specific field
    local field_value=""
    IFS=',' read -ra data_parts <<< "$registry_data"
    for part in "${data_parts[@]}"; do
        if [[ "$part" =~ ^$field: ]]; then
            field_value="${part#$field:}"
            break
        fi
    done
    
    echo "$field_value"
}

# Register module capabilities
register_module_capabilities() {
    local module_name="$1"
    local capabilities="$2"  # Comma-separated list of capabilities
    
    log_debug "MODULE_REGISTRY" "Registering capabilities for $module_name: $capabilities"
    
    MODULE_CAPABILITIES["$module_name"]="$capabilities"
    
    # Update search index with capabilities
    add_to_search_index "$module_name" "$capabilities" ""
    
    log_debug "MODULE_REGISTRY" "Capabilities registered for: $module_name"
    return 0
}

# Get modules by capability
get_modules_by_capability() {
    local capability="$1"
    local matching_modules=()
    
    for module_name in "${!MODULE_CAPABILITIES[@]}"; do
        local module_capabilities="${MODULE_CAPABILITIES[$module_name]}"
        if [[ ",$module_capabilities," =~ ,$capability, ]]; then
            matching_modules+=("$module_name")
        fi
    done
    
    printf '%s\n' "${matching_modules[@]}" | sort
}

# Record performance metrics
record_module_metrics() {
    local module_name="$1"
    local load_time="$2"
    local memory_usage="$3"
    local cpu_usage="$4"
    
    local timestamp=$(date +%s)
    local metrics="timestamp:$timestamp,load_time:$load_time,memory:$memory_usage,cpu:$cpu_usage"
    
    # Store current metrics
    MODULE_PERFORMANCE_METRICS["$module_name"]="$metrics"
    
    log_debug "MODULE_REGISTRY" "Performance metrics recorded for: $module_name"
}

# Get module performance metrics
get_module_metrics() {
    local module_name="$1"
    local metric_type="${2:-all}"
    
    local metrics="${MODULE_PERFORMANCE_METRICS[$module_name]:-}"
    if [[ -z "$metrics" ]]; then
        return 1
    fi
    
    if [[ "$metric_type" == "all" ]]; then
        echo "$metrics"
        return 0
    fi
    
    # Extract specific metric
    local metric_value=""
    IFS=',' read -ra metric_parts <<< "$metrics"
    for part in "${metric_parts[@]}"; do
        if [[ "$part" =~ ^$metric_type: ]]; then
            metric_value="${part#$metric_type:}"
            break
        fi
    done
    
    echo "$metric_value"
}

# Record module status change in history
record_module_status_change() {
    local module_name="$1"
    local status="$2"
    local message="$3"
    
    local timestamp=$(date -Iseconds)
    local history_entry="timestamp:$timestamp,status:$status,message:$message"
    
    # Append to existing history
    local current_history="${MODULE_STATUS_HISTORY[$module_name]:-}"
    if [[ -n "$current_history" ]]; then
        MODULE_STATUS_HISTORY["$module_name"]="$current_history|$history_entry"
    else
        MODULE_STATUS_HISTORY["$module_name"]="$history_entry"
    fi
    
    log_debug "MODULE_REGISTRY" "Status change recorded for $module_name: $status"
}

# Get module status history
get_module_history() {
    local module_name="$1"
    local limit="${2:-10}"  # Number of recent entries to return
    
    local history="${MODULE_STATUS_HISTORY[$module_name]:-}"
    if [[ -z "$history" ]]; then
        return 1
    fi
    
    # Split history entries and return most recent
    IFS='|' read -ra history_entries <<< "$history"
    local count=0
    
    # Return entries in reverse order (most recent first)
    for ((i=${#history_entries[@]}-1; i>=0 && count<limit; i--)); do
        echo "${history_entries[i]}"
        ((count++))
    done
}

# Build search index for modules
build_search_index() {
    log_debug "MODULE_REGISTRY" "Building search index..."
    
    MODULE_SEARCH_INDEX=()
    
    for module_name in "${!MODULE_REGISTRY_DB[@]}"; do
        local registry_data="${MODULE_REGISTRY_DB[$module_name]}"
        local description=""
        local tags="${MODULE_TAGS[$module_name]:-}"
        
        # Extract description
        IFS=',' read -ra data_parts <<< "$registry_data"
        for part in "${data_parts[@]}"; do
            if [[ "$part" =~ ^description: ]]; then
                description="${part#description:}"
                break
            fi
        done
        
        add_to_search_index "$module_name" "$description" "$tags"
    done
    
    log_debug "MODULE_REGISTRY" "Search index built"
}

# Add module to search index
add_to_search_index() {
    local module_name="$1"
    local description="$2"
    local tags="$3"
    
    # Create searchable text
    local searchable_text="$module_name $description $tags"
    searchable_text=$(echo "$searchable_text" | tr '[:upper:]' '[:lower:]')
    
    MODULE_SEARCH_INDEX["$module_name"]="$searchable_text"
}

# Search modules by keyword
search_modules() {
    local keyword="$1"
    local matching_modules=()
    
    keyword=$(echo "$keyword" | tr '[:upper:]' '[:lower:]')
    
    for module_name in "${!MODULE_SEARCH_INDEX[@]}"; do
        local searchable_text="${MODULE_SEARCH_INDEX[$module_name]}"
        if [[ "$searchable_text" =~ $keyword ]]; then
            matching_modules+=("$module_name")
        fi
    done
    
    printf '%s\n' "${matching_modules[@]}" | sort
}

# List all registered modules
list_registered_modules() {
    local filter="${1:-all}"  # all, registered, active, error
    local format="${2:-simple}"  # simple, detailed, json
    
    case "$format" in
        "json")
            echo "{"
            echo "  \"registry_version\": \"$REGISTRY_VERSION\","
            echo "  \"modules\": ["
            ;;
        "detailed")
            echo "=== Module Registry ==="
            echo "Registry Version: $REGISTRY_VERSION"
            echo "Total Modules: ${#MODULE_REGISTRY_DB[@]}"
            echo ""
            ;;
    esac
    
    local first=true
    for module_name in "${!MODULE_REGISTRY_DB[@]}" | sort; do
        local registry_data="${MODULE_REGISTRY_DB[$module_name]}"
        local status=""
        
        # Extract status
        IFS=',' read -ra data_parts <<< "$registry_data"
        for part in "${data_parts[@]}"; do
            if [[ "$part" =~ ^status: ]]; then
                status="${part#status:}"
                break
            fi
        done
        
        # Apply filter
        case "$filter" in
            "all")
                ;;
            *)
                if [[ "$status" != "$filter" ]]; then
                    continue
                fi
                ;;
        esac
        
        # Format output
        case "$format" in
            "json")
                [[ "$first" == "true" ]] && first=false || echo ","
                echo "    {"
                echo "      \"name\": \"$module_name\","
                echo "      \"status\": \"$status\","
                echo "      \"data\": \"$registry_data\""
                echo -n "    }"
                ;;
            "detailed")
                echo "Module: $module_name"
                echo "  Status: $status"
                echo "  Data: $registry_data"
                echo ""
                ;;
            *)
                echo "$module_name:$status"
                ;;
        esac
    done
    
    if [[ "$format" == "json" ]]; then
        echo ""
        echo "  ]"
        echo "}"
    fi
}

# Save registry data to files
save_registry_data() {
    log_info "MODULE_REGISTRY" "Saving registry data..."
    
    # Create backup first
    create_registry_backup
    
    # Save main registry
    save_registry_file "$REGISTRY_MAIN_FILE" "MODULE_REGISTRY_DB"
    
    # Save capabilities
    save_registry_file "$REGISTRY_CAPABILITIES_FILE" "MODULE_CAPABILITIES"
    
    # Save metrics
    save_registry_file "$REGISTRY_METRICS_FILE" "MODULE_PERFORMANCE_METRICS"
    
    # Save history
    save_registry_file "$REGISTRY_HISTORY_FILE" "MODULE_STATUS_HISTORY"
    
    log_info "MODULE_REGISTRY" "Registry data saved"
}

# Save registry data to a specific file
save_registry_file() {
    local file_path="$1"
    local array_name="$2"
    
    {
        echo "# Module Registry Data - Generated on $(date)"
        echo "# Format: key=value"
        echo ""
        
        case "$array_name" in
            "MODULE_REGISTRY_DB")
                for key in "${!MODULE_REGISTRY_DB[@]}"; do
                    echo "$key=${MODULE_REGISTRY_DB[$key]}"
                done
                ;;
            "MODULE_CAPABILITIES")
                for key in "${!MODULE_CAPABILITIES[@]}"; do
                    echo "$key=${MODULE_CAPABILITIES[$key]}"
                done
                ;;
            "MODULE_PERFORMANCE_METRICS")
                for key in "${!MODULE_PERFORMANCE_METRICS[@]}"; do
                    echo "$key=${MODULE_PERFORMANCE_METRICS[$key]}"
                done
                ;;
            "MODULE_STATUS_HISTORY")
                for key in "${!MODULE_STATUS_HISTORY[@]}"; do
                    echo "$key=${MODULE_STATUS_HISTORY[$key]}"
                done
                ;;
        esac
    } > "$file_path"
    
    log_debug "MODULE_REGISTRY" "Saved registry data to $(basename "$file_path")"
}

# Create backup of registry data
create_registry_backup() {
    local backup_timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="$REGISTRY_BACKUP_DIR/$backup_timestamp"
    
    if mkdir -p "$backup_dir" 2>/dev/null; then
        # Copy existing registry files
        if [[ -f "$REGISTRY_MAIN_FILE" ]]; then
            cp "$REGISTRY_MAIN_FILE" "$backup_dir/"
        fi
        if [[ -f "$REGISTRY_CAPABILITIES_FILE" ]]; then
            cp "$REGISTRY_CAPABILITIES_FILE" "$backup_dir/"
        fi
        if [[ -f "$REGISTRY_METRICS_FILE" ]]; then
            cp "$REGISTRY_METRICS_FILE" "$backup_dir/"
        fi
        if [[ -f "$REGISTRY_HISTORY_FILE" ]]; then
            cp "$REGISTRY_HISTORY_FILE" "$backup_dir/"
        fi
        
        log_debug "MODULE_REGISTRY" "Registry backup created: $backup_dir"
    else
        log_warning "MODULE_REGISTRY" "Failed to create registry backup directory"
    fi
}

# Clean old backups
cleanup_old_backups() {
    local max_age_days="${1:-7}"  # Keep backups for 7 days by default
    
    if [[ ! -d "$REGISTRY_BACKUP_DIR" ]]; then
        return 0
    fi
    
    log_debug "MODULE_REGISTRY" "Cleaning backups older than $max_age_days days..."
    
    find "$REGISTRY_BACKUP_DIR" -type d -name "20*" -mtime +"$max_age_days" -exec rm -rf {} \; 2>/dev/null
    
    log_debug "MODULE_REGISTRY" "Old backups cleaned"
}

# Validate registry integrity
validate_registry() {
    log_info "MODULE_REGISTRY" "Validating registry integrity..."
    
    local issues=0
    
    # Check for orphaned entries
    for module_name in "${!MODULE_REGISTRY_DB[@]}"; do
        local registry_data="${MODULE_REGISTRY_DB[$module_name]}"
        
        # Extract entry point
        local entry_point=""
        IFS=',' read -ra data_parts <<< "$registry_data"
        for part in "${data_parts[@]}"; do
            if [[ "$part" =~ ^entry_point: ]]; then
                entry_point="${part#entry_point:}"
                break
            fi
        done
        
        # Check if file exists
        if [[ -n "$entry_point" && ! -f "$entry_point" ]]; then
            log_warning "MODULE_REGISTRY" "Module file not found: $module_name -> $entry_point"
            ((issues++))
        fi
    done
    
    if [[ $issues -eq 0 ]]; then
        log_info "MODULE_REGISTRY" "Registry validation passed"
        return 0
    else
        log_warning "MODULE_REGISTRY" "Registry validation found $issues issues"
        return 1
    fi
}

# Export registry functions
export -f init_module_registry create_registry_directories load_registry_data
export -f register_module_in_registry update_module_in_registry get_module_from_registry
export -f register_module_capabilities get_modules_by_capability record_module_metrics
export -f get_module_metrics record_module_status_change get_module_history
export -f build_search_index search_modules list_registered_modules save_registry_data
export -f create_registry_backup cleanup_old_backups validate_registry
