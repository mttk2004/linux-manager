#!/bin/bash

# Linux Manager V2 - Development Environments Module
# Enhanced development environment management
#
# @VERSION: 2.0.0
# @DESCRIPTION: Advanced development tools management with version control, caching, and events
# @AUTHOR: Linux Manager Team

# Module initialization
init_development_module() {
    log_debug "Initializing development module v2.0.0"
    
    # Load V1 compatibility modules
    source_v1_dev_modules
    
    # Initialize development cache
    init_dev_cache
    
    # Subscribe to events
    subscribe_to_event "packages.installed" "on_dev_packages_installed"
    subscribe_to_event "ui.theme_changed" "reload_dev_ui"
    
    # Initialize development environments
    init_dev_environments
    
    log_info "Development module initialized successfully"
    return 0
}

# Source V1 development modules for compatibility
source_v1_dev_modules() {
    local v1_dev_dir="$ROOT_DIR/src/modules/dev"
    
    if [[ -d "$v1_dev_dir" ]]; then
        log_debug "Loading V1 development modules for compatibility"
        
        # Load PHP modules
        local php_dir="$v1_dev_dir/php"
        if [[ -d "$php_dir" ]]; then
            local php_modules=("build_php.sh" "switch_php.sh" "remove_php.sh" "install_composer.sh" "install_laravel.sh")
            for module in "${php_modules[@]}"; do
                local module_path="$php_dir/$module"
                if [[ -f "$module_path" ]]; then
                    if source "$module_path" 2>/dev/null; then
                        log_debug "Loaded V1 PHP module: $module"
                    else
                        log_warning "Failed to load V1 PHP module: $module"
                    fi
                fi
            done
        fi
        
        # Load Node.js modules
        local nodejs_dir="$v1_dev_dir/nodejs"
        if [[ -d "$nodejs_dir" ]]; then
            local nodejs_modules=("utils.sh" "nvm_installer.sh" "nodejs_installer.sh" "npm_installer.sh")
            for module in "${nodejs_modules[@]}"; do
                local module_path="$nodejs_dir/$module"
                if [[ -f "$module_path" ]]; then
                    if source "$module_path" 2>/dev/null; then
                        log_debug "Loaded V1 Node.js module: $module"
                    else
                        log_warning "Failed to load V1 Node.js module: $module"
                    fi
                fi
            done
        fi
    else
        log_warning "V1 development modules directory not found: $v1_dev_dir"
    fi
}

# Initialize development cache
init_dev_cache() {
    if get_config "DEVELOPMENT_MODE" "false" == "true"; then
        local cache_dir="$ROOT_DIR/.cache/development"
        mkdir -p "$cache_dir"
        export DEV_CACHE_DIR="$cache_dir"
        log_debug "Development cache initialized: $cache_dir"
    else
        log_debug "Development cache disabled by configuration"
    fi
}

# Initialize development environments
init_dev_environments() {
    log_debug "Detecting development environments"
    
    # Detect PHP
    detect_php_environment
    
    # Detect Node.js
    detect_nodejs_environment
    
    # Detect Python
    detect_python_environment
    
    # Detect other tools
    detect_dev_tools
}

# Detect PHP environment
detect_php_environment() {
    local php_versions=()
    local composer_available=false
    
    # Check for PHP installations
    for php_cmd in php php7.4 php8.0 php8.1 php8.2 php8.3; do
        if command -v "$php_cmd" >/dev/null 2>&1; then
            local version=$($php_cmd -v 2>/dev/null | head -n1 | cut -d' ' -f2 | cut -d'.' -f1,2)
            if [[ -n "$version" ]]; then
                php_versions+=("$version")
            fi
        fi
    done
    
    # Check Composer
    if command -v composer >/dev/null 2>&1; then
        composer_available=true
    fi
    
    export PHP_VERSIONS=("${php_versions[@]}")
    export PHP_AVAILABLE=$([[ ${#php_versions[@]} -gt 0 ]] && echo "true" || echo "false")
    export COMPOSER_AVAILABLE="$composer_available"
    
    log_debug "PHP environment detected: Available=$PHP_AVAILABLE, Versions=(${php_versions[*]}), Composer=$composer_available"
}

# Detect Node.js environment
detect_nodejs_environment() {
    local node_available=false
    local npm_available=false
    local nvm_available=false
    local node_version=""
    
    if command -v node >/dev/null 2>&1; then
        node_available=true
        node_version=$(node -v 2>/dev/null | sed 's/^v//')
    fi
    
    if command -v npm >/dev/null 2>&1; then
        npm_available=true
    fi
    
    if [[ -s "$HOME/.nvm/nvm.sh" ]] || command -v nvm >/dev/null 2>&1; then
        nvm_available=true
    fi
    
    export NODE_AVAILABLE="$node_available"
    export NPM_AVAILABLE="$npm_available"
    export NVM_AVAILABLE="$nvm_available"
    export NODE_VERSION="$node_version"
    
    log_debug "Node.js environment detected: Node=$node_available ($node_version), NPM=$npm_available, NVM=$nvm_available"
}

# Detect Python environment
detect_python_environment() {
    local python_available=false
    local pip_available=false
    local venv_available=false
    local python_version=""
    
    if command -v python3 >/dev/null 2>&1; then
        python_available=true
        python_version=$(python3 -V 2>&1 | cut -d' ' -f2)
    fi
    
    if command -v pip3 >/dev/null 2>&1; then
        pip_available=true
    fi
    
    if python3 -m venv --help >/dev/null 2>&1; then
        venv_available=true
    fi
    
    export PYTHON_AVAILABLE="$python_available"
    export PIP_AVAILABLE="$pip_available"
    export PYTHON_VENV_AVAILABLE="$venv_available"
    export PYTHON_VERSION="$python_version"
    
    log_debug "Python environment detected: Python=$python_available ($python_version), Pip=$pip_available, Venv=$venv_available"
}

# Detect development tools
detect_dev_tools() {
    local git_available=false
    local docker_available=false
    local make_available=false
    
    if command -v git >/dev/null 2>&1; then
        git_available=true
    fi
    
    if command -v docker >/dev/null 2>&1; then
        docker_available=true
    fi
    
    if command -v make >/dev/null 2>&1; then
        make_available=true
    fi
    
    export GIT_AVAILABLE="$git_available"
    export DOCKER_AVAILABLE="$docker_available"
    export MAKE_AVAILABLE="$make_available"
    
    log_debug "Development tools detected: Git=$git_available, Docker=$docker_available, Make=$make_available"
}

# Event handler for package installation
on_dev_packages_installed() {
    local event_data="$1"
    log_debug "Development packages installed, refreshing environment detection"
    init_dev_environments
}

# Reload development UI (for theme changes)
reload_dev_ui() {
    log_debug "Reloading development UI for theme change"
    # UI reload logic would go here
}

# Health check function
check_development_health() {
    local health_score=100
    local issues=()
    
    # Check essential development tools
    if [[ "$GIT_AVAILABLE" != "true" ]]; then
        health_score=$((health_score - 20))
        issues+=("Git not available")
    fi
    
    if [[ "$MAKE_AVAILABLE" != "true" ]]; then
        health_score=$((health_score - 10))
        issues+=("Make not available")
    fi
    
    # Check language environments
    if [[ "$PHP_AVAILABLE" != "true" ]] && get_config "PHP_DEFAULT_VERSION" "" != ""; then
        health_score=$((health_score - 15))
        issues+=("PHP not available but configured")
    fi
    
    if [[ "$NODE_AVAILABLE" != "true" ]] && get_config "NODEJS_DEFAULT_VERSION" "" != ""; then
        health_score=$((health_score - 15))
        issues+=("Node.js not available but configured")
    fi
    
    # Check cache directory
    if [[ -n "$DEV_CACHE_DIR" && ! -d "$DEV_CACHE_DIR" ]]; then
        health_score=$((health_score - 5))
        issues+=("Development cache directory missing")
    fi
    
    # Report health
    if [[ $health_score -ge 90 ]]; then
        log_debug "Development module health: excellent ($health_score/100)"
        return 0
    elif [[ $health_score -ge 70 ]]; then
        log_info "Development module health: good ($health_score/100) - Issues: ${issues[*]}"
        return 0
    else
        log_warning "Development module health: poor ($health_score/100) - Issues: ${issues[*]}"
        return 1
    fi
}

# Display enhanced development menu
display_development_menu_v2() {
    clear
    
    # Use V2 UI system for better display
    display_module_header "DEVELOPMENT ENVIRONMENTS" "💻"
    
    echo
    printf "  🐘 ${GREEN}${BOLD}[1]${NC}  ${WHITE}PHP Environment${NC}\n"
    printf "      ${GRAY}${DIM}PHP versions, Composer, Laravel${NC}\n"
    echo
    
    printf "  🟢 ${GREEN}${BOLD}[2]${NC}  ${WHITE}Node.js Environment${NC}\n"
    printf "      ${GRAY}${DIM}Node.js, NPM, NVM management${NC}\n"
    echo
    
    printf "  🐍 ${GREEN}${BOLD}[3]${NC}  ${WHITE}Python Environment${NC}\n"
    printf "      ${GRAY}${DIM}Python, pip, virtual environments${NC}\n"
    echo
    
    printf "  🛠️  ${GREEN}${BOLD}[4]${NC}  ${WHITE}Development Tools${NC}\n"
    printf "      ${GRAY}${DIM}Git, Docker, build tools${NC}\n"
    echo
    
    printf "  📊 ${GREEN}${BOLD}[5]${NC}  ${WHITE}Environment Status${NC}\n"
    printf "      ${GRAY}${DIM}View installed development environments${NC}\n"
    echo
    
    printf "  🔧 ${GREEN}${BOLD}[6]${NC}  ${WHITE}Development Settings${NC}\n"
    printf "      ${GRAY}${DIM}Configure development preferences${NC}\n"
    echo
    
    printf "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[0]${NC}  ${WHITE}Return to Main Menu${NC}\n"
    printf "      ${GRAY}${DIM}Go back to the main menu${NC}\n"
    echo
    
    display_module_footer "Choose option [0-6]"
}

# Main development module function
manage_development_v2() {
    log_debug "Starting V2 development environments management"
    
    while true; do
        display_development_menu_v2
        
        local choice
        choice=$(read_single_key)
        echo "$choice"
        echo
        
        case "$choice" in
            1)
                manage_php_environment_v2
                ;;
            2)
                manage_nodejs_environment_v2
                ;;
            3)
                manage_python_environment_v2
                ;;
            4)
                manage_dev_tools_v2
                ;;
            5)
                show_development_status
                ;;
            6)
                manage_development_settings
                ;;
            0)
                log_debug "Exiting development module"
                return 0
                ;;
            *)
                show_notification "Invalid choice: $choice" "error"
                ;;
        esac
        
        wait_for_user
    done
}

# PHP Environment Management V2
manage_php_environment_v2() {
    clear
    display_section_header "PHP Environment Management" "🐘"
    
    echo
    printf "  1. Install/Build PHP from source\n"
    printf "  2. Switch PHP version\n"
    printf "  3. Remove PHP version\n"
    printf "  4. Install/Update Composer\n"
    printf "  5. Install Laravel\n"
    printf "  6. PHP Extensions\n"
    printf "  7. PHP Configuration\n"
    printf "  0. Back\n"
    echo
    
    local choice
    printf "Choose PHP action [0-7]: "
    choice=$(read_single_key)
    echo "$choice"
    echo
    
    case "$choice" in
        1)
            if declare -f build_php_from_source >/dev/null 2>&1; then
                build_php_from_source
                publish_event "dev.tool_installed" "{\"type\":\"php\",\"action\":\"build\"}"
            else
                show_notification "PHP build function not available" "error"
            fi
            ;;
        2)
            if declare -f switch_php_version >/dev/null 2>&1; then
                switch_php_version
                publish_event "dev.version_switched" "{\"type\":\"php\",\"action\":\"switch\"}"
            else
                show_notification "PHP switch function not available" "error"
            fi
            ;;
        3)
            if declare -f remove_php_version >/dev/null 2>&1; then
                remove_php_version
                publish_event "dev.environment_changed" "{\"type\":\"php\",\"action\":\"remove\"}"
            else
                show_notification "PHP removal function not available" "error"
            fi
            ;;
        4)
            if declare -f install_composer >/dev/null 2>&1; then
                install_composer
                publish_event "dev.tool_installed" "{\"type\":\"composer\",\"action\":\"install\"}"
            else
                show_notification "Composer install function not available" "error"
            fi
            ;;
        5)
            if declare -f install_laravel >/dev/null 2>&1; then
                install_laravel
                publish_event "dev.tool_installed" "{\"type\":\"laravel\",\"action\":\"install\"}"
            else
                show_notification "Laravel install function not available" "error"
            fi
            ;;
        6)
            manage_php_extensions
            ;;
        7)
            manage_php_configuration
            ;;
        0)
            return 0
            ;;
        *)
            show_notification "Invalid choice: $choice" "error"
            ;;
    esac
}

# Node.js Environment Management V2
manage_nodejs_environment_v2() {
    clear
    display_section_header "Node.js Environment Management" "🟢"
    
    echo
    printf "  1. Install NVM\n"
    printf "  2. Install Node.js\n"
    printf "  3. Manage Node.js versions\n"
    printf "  4. Install global NPM packages\n"
    printf "  5. Update global packages\n"
    printf "  6. Node.js information\n"
    printf "  0. Back\n"
    echo
    
    local choice
    printf "Choose Node.js action [0-6]: "
    choice=$(read_single_key)
    echo "$choice"
    echo
    
    case "$choice" in
        1)
            if declare -f install_nvm >/dev/null 2>&1; then
                install_nvm
                publish_event "dev.tool_installed" "{\"type\":\"nvm\",\"action\":\"install\"}"
            else
                show_notification "NVM install function not available" "error"
            fi
            ;;
        2)
            if declare -f install_nodejs >/dev/null 2>&1; then
                install_nodejs
                publish_event "dev.tool_installed" "{\"type\":\"nodejs\",\"action\":\"install\"}"
            else
                show_notification "Node.js install function not available" "error"
            fi
            ;;
        3)
            if declare -f manage_nodejs_versions >/dev/null 2>&1; then
                manage_nodejs_versions
                publish_event "dev.version_switched" "{\"type\":\"nodejs\",\"action\":\"manage\"}"
            else
                show_notification "Node.js version management not available" "error"
            fi
            ;;
        4)
            if declare -f install_global_npm_packages >/dev/null 2>&1; then
                install_global_npm_packages
                publish_event "dev.tool_installed" "{\"type\":\"npm_global\",\"action\":\"install\"}"
            else
                show_notification "NPM package install function not available" "error"
            fi
            ;;
        5)
            if declare -f update_global_npm_packages >/dev/null 2>&1; then
                update_global_npm_packages
                publish_event "dev.environment_changed" "{\"type\":\"npm_global\",\"action\":\"update\"}"
            else
                show_notification "NPM package update function not available" "error"
            fi
            ;;
        6)
            if declare -f show_nodejs_info >/dev/null 2>&1; then
                show_nodejs_info
            else
                show_nodejs_info_v2
            fi
            ;;
        0)
            return 0
            ;;
        *)
            show_notification "Invalid choice: $choice" "error"
            ;;
    esac
}

# Python Environment Management V2
manage_python_environment_v2() {
    clear
    display_section_header "Python Environment Management" "🐍"
    
    show_notification "Python environment management coming soon!" "info"
    echo
    printf "Python environment features:\n"
    printf "  • Python version management\n"
    printf "  • Virtual environment management\n"
    printf "  • Package management with pip\n"
    printf "  • Poetry and pipenv support\n"
    echo
}

# Development Tools Management V2
manage_dev_tools_v2() {
    clear
    display_section_header "Development Tools Management" "🛠️"
    
    show_notification "Development tools management coming soon!" "info"
    echo
    printf "Development tools features:\n"
    printf "  • Git configuration and setup\n"
    printf "  • Docker environment management\n"
    printf "  • Build tools (Make, CMake, etc.)\n"
    printf "  • IDE and editor setup\n"
    echo
}

# Show development environment status
show_development_status() {
    clear
    display_section_header "Development Environment Status" "📊"
    
    echo
    printf "🐘 ${BOLD}PHP Environment:${NC}\n"
    if [[ "$PHP_AVAILABLE" == "true" ]]; then
        printf "   Status: ${GREEN}Available${NC}\n"
        printf "   Versions: %s\n" "${PHP_VERSIONS[*]}"
        printf "   Composer: %s\n" "$([[ "$COMPOSER_AVAILABLE" == "true" ]] && echo "${GREEN}Available${NC}" || echo "${RED}Not Available${NC}")"
    else
        printf "   Status: ${RED}Not Available${NC}\n"
    fi
    echo
    
    printf "🟢 ${BOLD}Node.js Environment:${NC}\n"
    if [[ "$NODE_AVAILABLE" == "true" ]]; then
        printf "   Status: ${GREEN}Available${NC}\n"
        printf "   Version: %s\n" "$NODE_VERSION"
        printf "   NPM: %s\n" "$([[ "$NPM_AVAILABLE" == "true" ]] && echo "${GREEN}Available${NC}" || echo "${RED}Not Available${NC}")"
        printf "   NVM: %s\n" "$([[ "$NVM_AVAILABLE" == "true" ]] && echo "${GREEN}Available${NC}" || echo "${RED}Not Available${NC}")"
    else
        printf "   Status: ${RED}Not Available${NC}\n"
    fi
    echo
    
    printf "🐍 ${BOLD}Python Environment:${NC}\n"
    if [[ "$PYTHON_AVAILABLE" == "true" ]]; then
        printf "   Status: ${GREEN}Available${NC}\n"
        printf "   Version: %s\n" "$PYTHON_VERSION"
        printf "   Pip: %s\n" "$([[ "$PIP_AVAILABLE" == "true" ]] && echo "${GREEN}Available${NC}" || echo "${RED}Not Available${NC}")"
        printf "   Venv: %s\n" "$([[ "$PYTHON_VENV_AVAILABLE" == "true" ]] && echo "${GREEN}Available${NC}" || echo "${RED}Not Available${NC}")"
    else
        printf "   Status: ${RED}Not Available${NC}\n"
    fi
    echo
    
    printf "🛠️  ${BOLD}Development Tools:${NC}\n"
    printf "   Git: %s\n" "$([[ "$GIT_AVAILABLE" == "true" ]] && echo "${GREEN}Available${NC}" || echo "${RED}Not Available${NC}")"
    printf "   Docker: %s\n" "$([[ "$DOCKER_AVAILABLE" == "true" ]] && echo "${GREEN}Available${NC}" || echo "${RED}Not Available${NC}")"
    printf "   Make: %s\n" "$([[ "$MAKE_AVAILABLE" == "true" ]] && echo "${GREEN}Available${NC}" || echo "${RED}Not Available${NC}")"
    echo
}

# Development settings management
manage_development_settings() {
    show_notification "Development settings management coming soon!" "info"
}

# PHP Extensions management
manage_php_extensions() {
    show_notification "PHP extensions management coming soon!" "info"
}

# PHP Configuration management
manage_php_configuration() {
    show_notification "PHP configuration management coming soon!" "info"
}

# Enhanced Node.js info display
show_nodejs_info_v2() {
    clear
    display_section_header "Node.js Environment Information" "🟢"
    
    echo
    if [[ "$NODE_AVAILABLE" == "true" ]]; then
        printf "Node.js Version: %s\n" "$NODE_VERSION"
        printf "Node.js Path: %s\n" "$(command -v node)"
        
        if [[ "$NPM_AVAILABLE" == "true" ]]; then
            local npm_version=$(npm -v 2>/dev/null || echo "Unknown")
            printf "NPM Version: %s\n" "$npm_version"
            printf "NPM Path: %s\n" "$(command -v npm)"
            
            printf "\nGlobal NPM packages:\n"
            npm list -g --depth=0 2>/dev/null || echo "Unable to list global packages"
        fi
        
        if [[ "$NVM_AVAILABLE" == "true" ]]; then
            printf "\nNVM Status: Available\n"
            if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
                source "$HOME/.nvm/nvm.sh"
                printf "NVM Version: %s\n" "$(nvm --version 2>/dev/null || echo "Unknown")"
                printf "Available Node versions:\n"
                nvm list 2>/dev/null || echo "Unable to list NVM versions"
            fi
        fi
    else
        printf "Node.js is not installed on this system.\n"
        printf "\nTo install Node.js:\n"
        printf "  1. Install NVM first\n"
        printf "  2. Use NVM to install Node.js\n"
        printf "  3. Or install directly from packages\n"
    fi
    echo
}

# Module cleanup
cleanup_development_module() {
    log_debug "Cleaning up development module"
    
    # Clear any temporary files
    [[ -d "/tmp/linux-manager-dev" ]] && rm -rf "/tmp/linux-manager-dev"
    
    # Unsubscribe from events
    unsubscribe_from_event "packages.installed" "on_dev_packages_installed"
    unsubscribe_from_event "ui.theme_changed" "reload_dev_ui"
    
    log_debug "Development module cleanup complete"
}

# Export main functions for V2 compatibility
manage_php_environment() {
    manage_php_environment_v2
}

manage_nodejs_environment() {
    manage_nodejs_environment_v2
}

manage_development_environment() {
    manage_development_v2
}
