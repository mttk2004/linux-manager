#!/bin/bash

# Module Management CLI - V2 Architecture  
# Command-line interface for managing modules (list, enable, disable, reload, status)
#
# Features:
# - Interactive and non-interactive modes
# - Comprehensive module listing and filtering
# - Module loading, unloading, and reloading
# - Health checks and diagnostics
# - Performance monitoring and statistics
# - Registry management
# - Communication system management
# - Colored output and progress indicators

# Define stub logging functions for testing environment
if [[ "${TESTING:-false}" == "true" ]]; then
    log_debug() { [[ "${TEST_VERBOSE:-false}" == "true" ]] && echo "[DEBUG] $*" >&2 || true; }
    log_info() { echo "[INFO] $*" >&2; }
    log_warning() { echo "[WARNING] $*" >&2; }
    log_error() { echo "[ERROR] $*" >&2; }
fi

# CLI configuration
declare -g CLI_INITIALIZED=false
declare -g CLI_INTERACTIVE=${CLI_INTERACTIVE:-false}
declare -g CLI_COLORED_OUTPUT=${CLI_COLORED_OUTPUT:-true}
declare -g CLI_VERBOSE=${CLI_VERBOSE:-false}
declare -g CLI_JSON_OUTPUT=${CLI_JSON_OUTPUT:-false}

# Color codes for CLI output
if [[ -t 1 && "$CLI_COLORED_OUTPUT" == "true" ]]; then
    CLI_RED='\033[0;31m'
    CLI_GREEN='\033[0;32m'
    CLI_YELLOW='\033[1;33m'
    CLI_BLUE='\033[0;34m'
    CLI_CYAN='\033[0;36m'
    CLI_WHITE='\033[1;37m'
    CLI_BOLD='\033[1m'
    CLI_DIM='\033[0;37m'
    CLI_NC='\033[0m'
else
    CLI_RED=''
    CLI_GREEN=''
    CLI_YELLOW=''
    CLI_BLUE=''
    CLI_CYAN=''
    CLI_WHITE=''
    CLI_BOLD=''
    CLI_DIM=''
    CLI_NC=''
fi

# Status icons
CLI_ICON_SUCCESS="✅"
CLI_ICON_ERROR="❌"
CLI_ICON_WARNING="⚠️"
CLI_ICON_INFO="ℹ️"
CLI_ICON_LOADING="🔄"

# Initialize the module CLI
init_module_cli() {
    log_debug "MODULE_CLI" "Initializing module management CLI..."
    
    # Load required modules
    if ! load_cli_dependencies; then
        echo "Failed to load CLI dependencies" >&2
        return 1
    fi
    
    CLI_INITIALIZED=true
    log_debug "MODULE_CLI" "Module CLI initialized"
    return 0
}

# Load CLI dependencies
load_cli_dependencies() {
    local required_modules=(
        "module_loader"
        "module_registry"  
        "module_communication"
    )
    
    for module in "${required_modules[@]}"; do
        if declare -f "init_${module}" >/dev/null 2>&1; then
            continue  # Already loaded
        fi
        
        # Try to load the module
        local module_file="${CORE_V2_DIR}/${module}.sh"
        if [[ -f "$module_file" ]]; then
            source "$module_file"
        else
            echo "Required module not found: $module" >&2
            return 1
        fi
    done
    
    return 0
}

# Main CLI entry point
module_cli_main() {
    local command="${1:-help}"
    shift
    
    # Initialize if not already done
    if [[ "$CLI_INITIALIZED" != "true" ]]; then
        init_module_cli || return 1
    fi
    
    # Handle global options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --verbose|-v)
                CLI_VERBOSE=true
                shift
                ;;
            --json|-j)
                CLI_JSON_OUTPUT=true
                CLI_COLORED_OUTPUT=false
                shift
                ;;
            --no-color)
                CLI_COLORED_OUTPUT=false
                shift
                ;;
            --interactive|-i)
                CLI_INTERACTIVE=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Execute command
    case "$command" in
        "help"|"-h"|"--help")
            show_help
            ;;
        "list"|"ls")
            cmd_list_modules "$@"
            ;;
        "info"|"show")
            cmd_show_module_info "$@"
            ;;
        "load"|"enable")
            cmd_load_module "$@"
            ;;
        "unload"|"disable")  
            cmd_unload_module "$@"
            ;;
        "reload")
            cmd_reload_module "$@"
            ;;
        "status")
            cmd_show_status "$@"
            ;;
        "health"|"check")
            cmd_health_check "$@"
            ;;
        "stats"|"statistics")
            cmd_show_statistics "$@"
            ;;
        "search")
            cmd_search_modules "$@"
            ;;
        "registry")
            cmd_registry_management "$@"
            ;;
        "communication"|"comm")
            cmd_communication_management "$@"
            ;;
        "interactive")
            start_interactive_mode
            ;;
        "init")
            cmd_initialize_systems "$@"
            ;;
        *)
            print_error "Unknown command: $command"
            echo "Use 'module-cli help' for usage information"
            return 1
            ;;
    esac
}

# Show help information
show_help() {
    cat << EOF
${CLI_BOLD}${CLI_BLUE}Linux Manager Module CLI - V2 Architecture${CLI_NC}

${CLI_BOLD}USAGE:${CLI_NC}
    module-cli [OPTIONS] COMMAND [ARGS...]

${CLI_BOLD}GLOBAL OPTIONS:${CLI_NC}
    -v, --verbose       Enable verbose output
    -j, --json          Output in JSON format
    -i, --interactive   Start interactive mode
    --no-color          Disable colored output
    -h, --help          Show this help message

${CLI_BOLD}COMMANDS:${CLI_NC}

${CLI_BOLD}Module Management:${CLI_NC}
    list, ls [FILTER]           List modules (all, loaded, unloaded, error, active)
    info, show MODULE           Show detailed module information
    load, enable MODULE         Load/enable a module
    unload, disable MODULE      Unload/disable a module
    reload MODULE               Reload a module
    status [MODULE]             Show module status
    search KEYWORD              Search modules by keyword

${CLI_BOLD}System Management:${CLI_NC}
    health, check [MODULE]      Run health checks
    stats, statistics           Show system statistics
    init                        Initialize all module systems
    interactive                 Start interactive mode

${CLI_BOLD}Registry Management:${CLI_NC}
    registry list               List registered modules
    registry info MODULE        Show registry information
    registry validate           Validate registry integrity
    registry backup             Create registry backup
    registry cleanup            Clean old backups

${CLI_BOLD}Communication Management:${CLI_NC}
    comm stats                  Show communication statistics
    comm subscribers [TOPIC]    List topic subscribers
    comm history [LIMIT]        Show message history
    comm cleanup [AGE]          Clean old messages
    comm health                 Communication health check

${CLI_BOLD}EXAMPLES:${CLI_NC}
    module-cli list loaded              # List all loaded modules
    module-cli info config_manager      # Show config manager details
    module-cli load performance         # Load performance module
    module-cli --json stats             # Show statistics in JSON format
    module-cli interactive              # Start interactive mode
    module-cli registry validate        # Validate module registry

EOF
}

# List modules command
cmd_list_modules() {
    local filter="${1:-all}"
    local format="table"
    
    if [[ "$CLI_JSON_OUTPUT" == "true" ]]; then
        format="json"
    fi
    
    print_header "Module List - Filter: $filter"
    
    # Get module list from enhanced loader
    local module_list
    if declare -f "list_modules_enhanced" >/dev/null 2>&1; then
        module_list=$(list_modules_enhanced "$filter")
    else
        print_error "Enhanced module loader not available"
        return 1
    fi
    
    if [[ -z "$module_list" ]]; then
        print_info "No modules found matching filter: $filter"
        return 0
    fi
    
    case "$format" in
        "json")
            print_module_list_json "$module_list"
            ;;
        *)
            print_module_list_table "$module_list"
            ;;
    esac
}

# Print module list in table format
print_module_list_table() {
    local module_list="$1"
    
    printf "${CLI_BOLD}%-20s %-12s %-15s %s${CLI_NC}\n" "MODULE" "STATUS" "TYPE" "LOAD TIME"
    printf "%-20s %-12s %-15s %s\n" "────────────────────" "────────────" "───────────────" "─────────"
    
    while IFS=':' read -r name status type; do
        local load_time=""
        if declare -f "get_module_info_enhanced" >/dev/null 2>&1; then
            local info
            info=$(get_module_info_enhanced "$name" 2>/dev/null)
            if [[ $? -eq 0 ]]; then
                load_time=$(echo "$info" | grep -o "load_time:[^,]*" | cut -d: -f2 || echo "N/A")
            fi
        fi
        
        # Colorize status
        local status_colored
        case "$status" in
            "active") status_colored="${CLI_GREEN}$status${CLI_NC}" ;;
            "loaded") status_colored="${CLI_BLUE}$status${CLI_NC}" ;;
            "error") status_colored="${CLI_RED}$status${CLI_NC}" ;;
            "disabled") status_colored="${CLI_DIM}$status${CLI_NC}" ;;
            *) status_colored="$status" ;;
        esac
        
        printf "%-30s %-22s %-15s %s\n" "$name" "$status_colored" "$type" "${load_time:-N/A}"
    done <<< "$module_list"
}

# Print module list in JSON format
print_module_list_json() {
    local module_list="$1"
    local first=true
    
    echo "{"
    echo "  \"modules\": ["
    
    while IFS=':' read -r name status type; do
        [[ "$first" == "true" ]] && first=false || echo ","
        
        local info=""
        if declare -f "get_module_info_enhanced" >/dev/null 2>&1; then
            info=$(get_module_info_enhanced "$name" 2>/dev/null || echo "")
        fi
        
        echo "    {"
        echo "      \"name\": \"$name\","
        echo "      \"status\": \"$status\","
        echo "      \"type\": \"$type\","
        echo "      \"info\": \"$info\""
        echo -n "    }"
    done <<< "$module_list"
    
    echo ""
    echo "  ]"
    echo "}"
}

# Show module information command
cmd_show_module_info() {
    local module_name="$1"
    
    if [[ -z "$module_name" ]]; then
        print_error "Module name required"
        return 1
    fi
    
    print_header "Module Information: $module_name"
    
    # Get enhanced module info
    if declare -f "get_module_info_enhanced" >/dev/null 2>&1; then
        local info
        info=$(get_module_info_enhanced "$module_name")
        if [[ $? -eq 0 ]]; then
            print_module_info_detailed "$info"
        else
            print_error "Module not found: $module_name"
            return 1
        fi
    else
        print_error "Enhanced module loader not available"
        return 1
    fi
    
    # Show registry information if available
    if declare -f "get_module_from_registry" >/dev/null 2>&1; then
        local registry_info
        registry_info=$(get_module_from_registry "$module_name" 2>/dev/null)
        if [[ $? -eq 0 ]]; then
            echo
            print_subheader "Registry Information"
            print_key_value_pairs "$registry_info"
        fi
    fi
    
    # Show dependencies
    if declare -f "get_module_dependencies" >/dev/null 2>&1; then
        local dependencies
        dependencies=$(get_module_dependencies "$module_name")
        if [[ -n "$dependencies" ]]; then
            echo
            print_subheader "Dependencies"
            echo "$dependencies" | tr ',' '\n' | sed 's/^/  - /'
        fi
    fi
    
    # Show dependents
    if declare -f "get_dependent_modules" >/dev/null 2>&1; then
        local dependents
        dependents=$(get_dependent_modules "$module_name")
        if [[ -n "$dependents" ]]; then
            echo
            print_subheader "Dependent Modules"
            echo "$dependents" | sed 's/^/  - /'
        fi
    fi
}

# Print detailed module information
print_module_info_detailed() {
    local info="$1"
    
    if [[ "$CLI_JSON_OUTPUT" == "true" ]]; then
        echo "{\"module_info\": \"$info\"}"
        return
    fi
    
    print_key_value_pairs "$info"
}

# Print key-value pairs from colon-separated string
print_key_value_pairs() {
    local data="$1"
    
    IFS=',' read -ra pairs <<< "$data"
    for pair in "${pairs[@]}"; do
        if [[ "$pair" =~ ^([^:]+):(.*)$ ]]; then
            local key="${BASH_REMATCH[1]}"
            local value="${BASH_REMATCH[2]}"
            printf "  ${CLI_BOLD}%-15s${CLI_NC} %s\n" "$key:" "$value"
        fi
    done
}

# Load module command
cmd_load_module() {
    local module_name="$1"
    local force="${2:-false}"
    
    if [[ -z "$module_name" ]]; then
        print_error "Module name required"
        return 1
    fi
    
    print_info "Loading module: $module_name"
    
    if declare -f "load_module_enhanced" >/dev/null 2>&1; then
        if load_module_enhanced "$module_name" "$force"; then
            print_success "Module loaded successfully: $module_name"
        else
            print_error "Failed to load module: $module_name"
            return 1
        fi
    else
        print_error "Enhanced module loader not available"
        return 1
    fi
}

# Unload module command
cmd_unload_module() {
    local module_name="$1"
    
    if [[ -z "$module_name" ]]; then
        print_error "Module name required"
        return 1
    fi
    
    print_info "Unloading module: $module_name"
    
    if declare -f "unload_module_enhanced" >/dev/null 2>&1; then
        if unload_module_enhanced "$module_name"; then
            print_success "Module unloaded successfully: $module_name"
        else
            print_error "Failed to unload module: $module_name"
            return 1
        fi
    else
        print_error "Enhanced module loader not available"
        return 1
    fi
}

# Reload module command
cmd_reload_module() {
    local module_name="$1"
    
    if [[ -z "$module_name" ]]; then
        print_error "Module name required"
        return 1
    fi
    
    print_info "Reloading module: $module_name"
    
    if declare -f "reload_module_enhanced" >/dev/null 2>&1; then
        if reload_module_enhanced "$module_name"; then
            print_success "Module reloaded successfully: $module_name"
        else
            print_error "Failed to reload module: $module_name"
            return 1
        fi
    else
        print_error "Enhanced module loader not available"
        return 1
    fi
}

# Show status command
cmd_show_status() {
    local module_name="$1"
    
    if [[ -n "$module_name" ]]; then
        # Show specific module status
        print_header "Module Status: $module_name"
        
        if declare -f "get_module_status_enhanced" >/dev/null 2>&1; then
            local status
            status=$(get_module_status_enhanced "$module_name")
            print_key_value "Status" "$status"
            
            # Show health if available
            if declare -f "check_module_health" >/dev/null 2>&1; then
                local health
                health=$(check_module_health "$module_name" 2>/dev/null || echo "unknown")
                print_key_value "Health" "$health"
            fi
        else
            print_error "Enhanced module loader not available"
            return 1
        fi
    else
        # Show system overview
        print_header "System Status Overview"
        
        # Module counts
        local total_modules=0
        local loaded_modules=0
        local error_modules=0
        
        if declare -f "list_modules_enhanced" >/dev/null 2>&1; then
            total_modules=$(list_modules_enhanced "all" | wc -l)
            loaded_modules=$(list_modules_enhanced "loaded" | wc -l)
            error_modules=$(list_modules_enhanced "error" | wc -l)
        fi
        
        print_key_value "Total Modules" "$total_modules"
        print_key_value "Loaded Modules" "$loaded_modules"
        print_key_value "Error Modules" "$error_modules"
        
        # Communication stats if available
        if declare -f "get_message_statistics" >/dev/null 2>&1; then
            echo
            print_subheader "Communication Statistics"
            local stats
            stats=$(get_message_statistics "all")
            print_key_value_pairs "$stats"
        fi
    fi
}

# Health check command
cmd_health_check() {
    local module_name="$1"
    
    print_header "Health Check"
    
    if [[ -n "$module_name" ]]; then
        # Check specific module
        print_info "Checking module: $module_name"
        
        if declare -f "check_module_health" >/dev/null 2>&1; then
            local health
            health=$(check_module_health "$module_name")
            case "$health" in
                "healthy")
                    print_success "Module is healthy: $module_name"
                    ;;
                "degraded")
                    print_warning "Module is degraded: $module_name"
                    ;;
                "error"|"missing_file")
                    print_error "Module has issues: $module_name ($health)"
                    ;;
                *)
                    print_info "Module health unknown: $module_name"
                    ;;
            esac
        else
            print_error "Health check not available"
            return 1
        fi
    else
        # System-wide health check
        print_info "Running system-wide health check..."
        
        local issues=0
        
        # Check module loader
        if declare -f "module_loader_health_check" >/dev/null 2>&1; then
            if ! module_loader_health_check >/dev/null 2>&1; then
                print_error "Module loader health check failed"
                ((issues++))
            else
                print_success "Module loader: OK"
            fi
        fi
        
        # Check registry
        if declare -f "validate_registry" >/dev/null 2>&1; then
            if ! validate_registry >/dev/null 2>&1; then
                print_warning "Registry validation issues found"
                ((issues++))
            else
                print_success "Registry: OK"
            fi
        fi
        
        # Check communication
        if declare -f "communication_health_check" >/dev/null 2>&1; then
            if ! communication_health_check >/dev/null 2>&1; then
                print_error "Communication system health check failed"
                ((issues++))
            else
                print_success "Communication system: OK"
            fi
        fi
        
        echo
        if [[ $issues -eq 0 ]]; then
            print_success "Overall system health: GOOD"
        else
            print_warning "Overall system health: $issues issue(s) found"
        fi
    fi
}

# Show statistics command
cmd_show_statistics() {
    print_header "System Statistics"
    
    if [[ "$CLI_JSON_OUTPUT" == "true" ]]; then
        echo "{"
        echo "  \"timestamp\": \"$(date -Iseconds)\","
        echo "  \"statistics\": {"
        # Add JSON statistics here
        echo "    \"modules\": $(list_modules_enhanced "all" | wc -l),"
        echo "    \"loaded_modules\": $(list_modules_enhanced "loaded" | wc -l)"
        echo "  }"
        echo "}"
    else
        # Module statistics
        print_subheader "Module Statistics"
        print_key_value "Total Modules" "$(list_modules_enhanced "all" | wc -l)"
        print_key_value "Loaded Modules" "$(list_modules_enhanced "loaded" | wc -l)"
        print_key_value "Active Modules" "$(list_modules_enhanced "active" | wc -l)"
        print_key_value "Error Modules" "$(list_modules_enhanced "error" | wc -l)"
        
        # Communication statistics
        if declare -f "get_message_statistics" >/dev/null 2>&1; then
            echo
            print_subheader "Communication Statistics"
            local stats
            stats=$(get_message_statistics "all")
            print_key_value_pairs "$stats"
        fi
    fi
}

# Search modules command
cmd_search_modules() {
    local keyword="$1"
    
    if [[ -z "$keyword" ]]; then
        print_error "Search keyword required"
        return 1
    fi
    
    print_header "Search Results for: $keyword"
    
    if declare -f "search_modules" >/dev/null 2>&1; then
        local results
        results=$(search_modules "$keyword")
        
        if [[ -n "$results" ]]; then
            echo "$results" | while read -r module_name; do
                printf "  ${CLI_CYAN}%s${CLI_NC}\n" "$module_name"
            done
        else
            print_info "No modules found matching: $keyword"
        fi
    else
        print_error "Search functionality not available"
        return 1
    fi
}

# Registry management command
cmd_registry_management() {
    local subcommand="$1"
    shift
    
    case "$subcommand" in
        "list")
            cmd_registry_list "$@"
            ;;
        "info")
            cmd_registry_info "$@"
            ;;
        "validate")
            cmd_registry_validate "$@"
            ;;
        "backup")
            cmd_registry_backup "$@"
            ;;
        "cleanup")
            cmd_registry_cleanup "$@"
            ;;
        *)
            print_error "Unknown registry command: $subcommand"
            echo "Available: list, info, validate, backup, cleanup"
            return 1
            ;;
    esac
}

# Registry list subcommand
cmd_registry_list() {
    local filter="${1:-all}"
    local format="simple"
    
    if [[ "$CLI_JSON_OUTPUT" == "true" ]]; then
        format="json"
    fi
    
    print_header "Registry Modules"
    
    if declare -f "list_registered_modules" >/dev/null 2>&1; then
        list_registered_modules "$filter" "$format"
    else
        print_error "Registry functionality not available"
        return 1
    fi
}

# Communication management command  
cmd_communication_management() {
    local subcommand="$1"
    shift
    
    case "$subcommand" in
        "stats")
            if declare -f "get_message_statistics" >/dev/null 2>&1; then
                print_header "Communication Statistics"
                local stats
                stats=$(get_message_statistics "all")
                print_key_value_pairs "$stats"
            else
                print_error "Communication system not available"
                return 1
            fi
            ;;
        "subscribers")
            local topic="${1:-all}"
            if declare -f "list_subscribers" >/dev/null 2>&1; then
                print_header "Topic Subscribers"
                list_subscribers "$topic"
            else
                print_error "Communication system not available"
                return 1
            fi
            ;;
        "health")
            if declare -f "communication_health_check" >/dev/null 2>&1; then
                communication_health_check
            else
                print_error "Communication system not available"
                return 1
            fi
            ;;
        *)
            print_error "Unknown communication command: $subcommand"
            echo "Available: stats, subscribers, health"
            return 1
            ;;
    esac
}

# Initialize systems command
cmd_initialize_systems() {
    print_header "Initializing Module Systems"
    
    local systems=(
        "init_module_loader:Module Loader"
        "init_module_registry:Module Registry"  
        "init_module_communication:Inter-Module Communication"
    )
    
    for system in "${systems[@]}"; do
        local func_name="${system%%:*}"
        local display_name="${system##*:}"
        
        print_info "Initializing $display_name..."
        
        if declare -f "$func_name" >/dev/null 2>&1; then
            if "$func_name" >/dev/null 2>&1; then
                print_success "$display_name: Initialized"
            else
                print_error "$display_name: Failed to initialize"
            fi
        else
            print_warning "$display_name: Not available"
        fi
    done
}

# Start interactive mode
start_interactive_mode() {
    print_header "Interactive Module Management"
    print_info "Type 'help' for commands, 'quit' to exit"
    echo
    
    while true; do
        printf "${CLI_BOLD}module-cli>${CLI_NC} "
        read -r input
        
        case "$input" in
            "quit"|"exit"|"q")
                print_info "Goodbye!"
                break
                ;;
            "help"|"h")
                show_help
                ;;
            "")
                continue
                ;;
            *)
                # Execute the command
                eval "module_cli_main $input"
                ;;
        esac
        echo
    done
}

# Print formatting functions
print_header() {
    local title="$1"
    echo
    printf "${CLI_BOLD}${CLI_BLUE}=== %s ===${CLI_NC}\n" "$title"
    echo
}

print_subheader() {
    local title="$1"
    printf "${CLI_BOLD}%s:${CLI_NC}\n" "$title"
}

print_success() {
    local message="$1"
    printf "${CLI_GREEN}%s %s${CLI_NC}\n" "$CLI_ICON_SUCCESS" "$message"
}

print_error() {
    local message="$1"
    printf "${CLI_RED}%s %s${CLI_NC}\n" "$CLI_ICON_ERROR" "$message" >&2
}

print_warning() {
    local message="$1"
    printf "${CLI_YELLOW}%s %s${CLI_NC}\n" "$CLI_ICON_WARNING" "$message"
}

print_info() {
    local message="$1"
    printf "${CLI_CYAN}%s %s${CLI_NC}\n" "$CLI_ICON_INFO" "$message"
}

print_key_value() {
    local key="$1"
    local value="$2"
    printf "  ${CLI_BOLD}%-15s${CLI_NC} %s\n" "$key:" "$value"
}

# Export CLI functions
export -f init_module_cli module_cli_main show_help
export -f cmd_list_modules cmd_show_module_info cmd_load_module cmd_unload_module
export -f cmd_reload_module cmd_show_status cmd_health_check cmd_show_statistics
export -f cmd_search_modules cmd_registry_management cmd_communication_management
export -f cmd_initialize_systems start_interactive_mode

# Main execution if run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    module_cli_main "$@"
fi
