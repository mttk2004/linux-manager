#!/bin/bash

# Linux Manager V2 - System Configuration Module
# Advanced system configuration and management
#
# @VERSION: 2.0.0
# @DESCRIPTION: Enhanced system configuration with automated cleanup, backups, and settings management
# @AUTHOR: Linux Manager Team

# Module initialization
init_system_module() {
    log_debug "Initializing system module v2.0.0"
    
    # Load V1 compatibility modules
    source_v1_system_modules
    
    # Initialize system cache
    init_system_cache
    
    # Subscribe to events
    subscribe_to_event "packages.installed" "on_system_packages_installed"
    subscribe_to_event "ui.theme_changed" "reload_system_ui"
    
    # Initialize system detection
    init_system_detection
    
    log_info "System module initialized successfully"
    return 0
}

# Source V1 system modules for compatibility
source_v1_system_modules() {
    local v1_system_dir="$ROOT_DIR/src/modules/system"
    
    if [[ -d "$v1_system_dir" ]]; then
        log_debug "Loading V1 system modules for compatibility"
        
        # Load system modules
        local system_modules=("cleanup.sh" "shell.sh" "systemd.sh")
        for module in "${system_modules[@]}"; do
            local module_path="$v1_system_dir/$module"
            if [[ -f "$module_path" ]]; then
                if source "$module_path" 2>/dev/null; then
                    log_debug "Loaded V1 system module: $module"
                else
                    log_warning "Failed to load V1 system module: $module"
                fi
            else
                log_debug "V1 system module not found: $module"
            fi
        done
        
        # Load terminal modules
        local terminal_dir="$v1_system_dir/terminal"
        if [[ -d "$terminal_dir" ]]; then
            local terminal_modules=("alacritty.sh")
            for module in "${terminal_modules[@]}"; do
                local module_path="$terminal_dir/$module"
                if [[ -f "$module_path" ]]; then
                    if source "$module_path" 2>/dev/null; then
                        log_debug "Loaded V1 terminal module: $module"
                    else
                        log_warning "Failed to load V1 terminal module: $module"
                    fi
                fi
            done
        fi
    else
        log_warning "V1 system modules directory not found: $v1_system_dir"
    fi
}

# Initialize system cache
init_system_cache() {
    local cache_dir="$ROOT_DIR/.cache/system"
    mkdir -p "$cache_dir"
    export SYSTEM_CACHE_DIR="$cache_dir"
    log_debug "System cache initialized: $cache_dir"
}

# Initialize system detection
init_system_detection() {
    log_debug "Detecting system configuration"
    
    # Detect shell environment
    detect_shell_environment
    
    # Detect system services
    detect_system_services
    
    # Detect cleanup tools
    detect_cleanup_tools
    
    # Detect backup tools
    detect_backup_tools
}

# Detect shell environment
detect_shell_environment() {
    local current_shell=""
    local available_shells=()
    
    # Detect current shell
    if [[ -n "$SHELL" ]]; then
        current_shell=$(basename "$SHELL")
    fi
    
    # Detect available shells
    for shell in bash zsh fish; do
        if command -v "$shell" >/dev/null 2>&1; then
            available_shells+=("$shell")
        fi
    done
    
    export CURRENT_SHELL="$current_shell"
    export AVAILABLE_SHELLS=("${available_shells[@]}")
    
    log_debug "Shell environment detected: Current=$current_shell, Available=(${available_shells[*]})"
}

# Detect system services
detect_system_services() {
    local systemd_available=false
    local networkmanager_available=false
    
    if command -v systemctl >/dev/null 2>&1; then
        systemd_available=true
    fi
    
    if systemctl is-active --quiet NetworkManager 2>/dev/null; then
        networkmanager_available=true
    fi
    
    export SYSTEMD_AVAILABLE="$systemd_available"
    export NETWORKMANAGER_AVAILABLE="$networkmanager_available"
    
    log_debug "System services detected: Systemd=$systemd_available, NetworkManager=$networkmanager_available"
}

# Detect cleanup tools
detect_cleanup_tools() {
    local paccache_available=false
    local bleachbit_available=false
    local timeshift_available=false
    
    if command -v paccache >/dev/null 2>&1; then
        paccache_available=true
    fi
    
    if command -v bleachbit >/dev/null 2>&1; then
        bleachbit_available=true
    fi
    
    if command -v timeshift >/dev/null 2>&1; then
        timeshift_available=true
    fi
    
    export PACCACHE_AVAILABLE="$paccache_available"
    export BLEACHBIT_AVAILABLE="$bleachbit_available"
    export TIMESHIFT_AVAILABLE="$timeshift_available"
    
    log_debug "Cleanup tools detected: Paccache=$paccache_available, BleachBit=$bleachbit_available, Timeshift=$timeshift_available"
}

# Detect backup tools
detect_backup_tools() {
    local rsync_available=false
    local tar_available=false
    
    if command -v rsync >/dev/null 2>&1; then
        rsync_available=true
    fi
    
    if command -v tar >/dev/null 2>&1; then
        tar_available=true
    fi
    
    export RSYNC_AVAILABLE="$rsync_available"
    export TAR_AVAILABLE="$tar_available"
    
    log_debug "Backup tools detected: Rsync=$rsync_available, Tar=$tar_available"
}

# Event handlers
on_system_packages_installed() {
    local event_data="$1"
    log_debug "System packages installed, refreshing system detection"
    init_system_detection
}

reload_system_ui() {
    log_debug "Reloading system UI for theme change"
}

# Health check function
check_system_health() {
    local health_score=100
    local issues=()
    
    # Check essential system tools
    if [[ "$SYSTEMD_AVAILABLE" != "true" ]]; then
        health_score=$((health_score - 20))
        issues+=("Systemd not available")
    fi
    
    if [[ "$TAR_AVAILABLE" != "true" ]]; then
        health_score=$((health_score - 10))
        issues+=("Tar not available")
    fi
    
    # Check cleanup tools availability
    if [[ "$PACCACHE_AVAILABLE" != "true" ]]; then
        health_score=$((health_score - 15))
        issues+=("Paccache not available")
    fi
    
    # Check backup configuration
    if get_config "system.backup_enabled" "true" == "true" && [[ "$TIMESHIFT_AVAILABLE" != "true" ]]; then
        health_score=$((health_score - 15))
        issues+=("Backup enabled but Timeshift not available")
    fi
    
    # Check cache directory
    if [[ ! -d "$SYSTEM_CACHE_DIR" ]]; then
        health_score=$((health_score - 5))
        issues+=("System cache directory missing")
    fi
    
    # Report health
    if [[ $health_score -ge 90 ]]; then
        log_debug "System module health: excellent ($health_score/100)"
        return 0
    elif [[ $health_score -ge 70 ]]; then
        log_info "System module health: good ($health_score/100) - Issues: ${issues[*]}"
        return 0
    else
        log_warning "System module health: poor ($health_score/100) - Issues: ${issues[*]}"
        return 1
    fi
}

# Display enhanced system menu
display_system_menu_v2() {
    clear
    
    # Use V2 UI system for better display
    display_module_header "SYSTEM CONFIGURATION" "⚙️"
    
    echo
    printf "  🖥️  ${GREEN}${BOLD}[1]${NC}  ${WHITE}Shell Configuration${NC}\n"
    printf "      ${GRAY}${DIM}Configure Bash, Zsh, Fish shells${NC}\n"
    echo
    
    printf "  📝 ${GREEN}${BOLD}[2]${NC}  ${WHITE}Editor Configuration${NC}\n"
    printf "      ${GRAY}${DIM}Setup Vim, Neovim, VS Code${NC}\n"
    echo
    
    printf "  🌐 ${GREEN}${BOLD}[3]${NC}  ${WHITE}Network Configuration${NC}\n"
    printf "      ${GRAY}${DIM}NetworkManager settings${NC}\n"
    echo
    
    printf "  🔧 ${GREEN}${BOLD}[4]${NC}  ${WHITE}System Services${NC}\n"
    printf "      ${GRAY}${DIM}Systemd service management${NC}\n"
    echo
    
    printf "  💾 ${GREEN}${BOLD}[5]${NC}  ${WHITE}System Backup${NC}\n"
    printf "      ${GRAY}${DIM}Create system backups with Timeshift${NC}\n"
    echo
    
    printf "  🖼️  ${GREEN}${BOLD}[6]${NC}  ${WHITE}Window Manager Setup${NC}\n"
    printf "      ${GRAY}${DIM}Configure Qtile, i3, Hyprland${NC}\n"
    echo
    
    printf "  📺 ${GREEN}${BOLD}[7]${NC}  ${WHITE}Terminal Configuration${NC}\n"
    printf "      ${GRAY}${DIM}Setup terminal emulators${NC}\n"
    echo
    
    printf "  🧹 ${GREEN}${BOLD}[8]${NC}  ${WHITE}System Cleanup${NC}\n"
    printf "      ${GRAY}${DIM}Clean orphaned packages, cache, logs${NC}\n"
    echo
    
    printf "  📊 ${GREEN}${BOLD}[9]${NC}  ${WHITE}System Information${NC}\n"
    printf "      ${GRAY}${DIM}View system status and information${NC}\n"
    echo
    
    printf "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[0]${NC}  ${WHITE}Return to Main Menu${NC}\n"
    printf "      ${GRAY}${DIM}Go back to the main menu${NC}\n"
    echo
    
    display_module_footer "Choose option [0-9]"
}

# Main system module function
manage_system_v2() {
    log_debug "Starting V2 system configuration management"
    
    while true; do
        display_system_menu_v2
        
        local choice
        choice=$(read_single_key)
        echo "$choice"
        echo
        
        case "$choice" in
            1)
                manage_shell_configuration_v2
                ;;
            2)
                manage_editor_configuration_v2
                ;;
            3)
                manage_network_configuration_v2
                ;;
            4)
                manage_system_services_v2
                ;;
            5)
                manage_system_backup_v2
                ;;
            6)
                manage_window_manager_v2
                ;;
            7)
                manage_terminal_configuration_v2
                ;;
            8)
                manage_system_cleanup_v2
                ;;
            9)
                show_system_information
                ;;
            0)
                log_debug "Exiting system module"
                return 0
                ;;
            *)
                show_notification "Invalid choice: $choice" "error"
                ;;
        esac
        
        wait_for_user
    done
}

# Shell Configuration Management V2
manage_shell_configuration_v2() {
    clear
    display_section_header "Shell Configuration" "🖥️"
    
    echo
    printf "Current shell: ${BOLD}%s${NC}\n" "$CURRENT_SHELL"
    printf "Available shells: ${BOLD}%s${NC}\n" "${AVAILABLE_SHELLS[*]}"
    echo
    
    printf "  1. Configure Bash\n"
    printf "  2. Configure Zsh (with Oh My Zsh)\n"
    printf "  3. Configure Fish\n"
    printf "  4. Change default shell\n"
    printf "  5. Install shell themes\n"
    printf "  0. Back\n"
    echo
    
    local choice
    printf "Choose shell configuration [0-5]: "
    choice=$(read_single_key)
    echo "$choice"
    echo
    
    case "$choice" in
        1)
            configure_bash_v2
            ;;
        2)
            configure_zsh_v2
            ;;
        3)
            configure_fish_v2
            ;;
        4)
            change_default_shell_v2
            ;;
        5)
            install_shell_themes_v2
            ;;
        0)
            return 0
            ;;
        *)
            show_notification "Invalid choice: $choice" "error"
            ;;
    esac
}

# Editor Configuration Management V2
manage_editor_configuration_v2() {
    clear
    display_section_header "Editor Configuration" "📝"
    
    show_notification "Editor configuration management coming soon!" "info"
    echo
    printf "Editor configuration features:\n"
    printf "  • Vim/Neovim setup and configuration\n"
    printf "  • VS Code extensions and settings\n"
    printf "  • Emacs configuration\n"
    printf "  • IDE setup and preferences\n"
    echo
}

# Network Configuration Management V2
manage_network_configuration_v2() {
    clear
    display_section_header "Network Configuration" "🌐"
    
    show_notification "Network configuration management coming soon!" "info"
    echo
    printf "Network configuration features:\n"
    printf "  • NetworkManager configuration\n"
    printf "  • WiFi profile management\n"
    printf "  • VPN setup and configuration\n"
    printf "  • Firewall rules management\n"
    echo
}

# System Services Management V2
manage_system_services_v2() {
    clear
    display_section_header "System Services Management" "🔧"
    
    if [[ "$SYSTEMD_AVAILABLE" == "true" ]]; then
        echo
        printf "  1. View running services\n"
        printf "  2. Start/stop services\n"
        printf "  3. Enable/disable services\n"
        printf "  4. Service logs\n"
        printf "  5. System status\n"
        printf "  0. Back\n"
        echo
        
        local choice
        printf "Choose service action [0-5]: "
        choice=$(read_single_key)
        echo "$choice"
        echo
        
        case "$choice" in
            1)
                view_running_services
                ;;
            2)
                manage_service_state
                ;;
            3)
                manage_service_enablement
                ;;
            4)
                view_service_logs
                ;;
            5)
                view_systemd_status
                ;;
            0)
                return 0
                ;;
            *)
                show_notification "Invalid choice: $choice" "error"
                ;;
        esac
    else
        show_notification "Systemd not available on this system" "error"
    fi
}

# System Backup Management V2
manage_system_backup_v2() {
    clear
    display_section_header "System Backup Management" "💾"
    
    if [[ "$TIMESHIFT_AVAILABLE" == "true" ]]; then
        echo
        printf "  1. Create system snapshot\n"
        printf "  2. View existing snapshots\n"
        printf "  3. Restore from snapshot\n"
        printf "  4. Configure automatic backups\n"
        printf "  5. Delete old snapshots\n"
        printf "  0. Back\n"
        echo
        
        local choice
        printf "Choose backup action [0-5]: "
        choice=$(read_single_key)
        echo "$choice"
        echo
        
        case "$choice" in
            1)
                create_system_snapshot
                ;;
            2)
                view_system_snapshots
                ;;
            3)
                restore_system_snapshot
                ;;
            4)
                configure_automatic_backups
                ;;
            5)
                delete_old_snapshots
                ;;
            0)
                return 0
                ;;
            *)
                show_notification "Invalid choice: $choice" "error"
                ;;
        esac
    else
        show_notification "Installing Timeshift for system backup..." "info"
        
        if get_config "packages.pacman.available" "true" == "true"; then
            if sudo pacman -S --noconfirm timeshift; then
                show_notification "Timeshift installed successfully" "success"
                export TIMESHIFT_AVAILABLE=true
                manage_system_backup_v2  # Recursively call after installation
            else
                show_notification "Failed to install Timeshift" "error"
            fi
        else
            show_notification "Package manager not available" "error"
        fi
    fi
}

# Window Manager Management V2
manage_window_manager_v2() {
    clear
    display_section_header "Window Manager Setup" "🖼️"
    
    echo
    printf "  1. Configure Qtile\n"
    printf "  2. Configure i3/i3-gaps\n"
    printf "  3. Configure Hyprland\n"
    printf "  4. Configure AwesomeWM\n"
    printf "  5. Configure dwm\n"
    printf "  0. Back\n"
    echo
    
    local choice
    printf "Choose window manager [0-5]: "
    choice=$(read_single_key)
    echo "$choice"
    echo
    
    case "$choice" in
        1)
            configure_qtile_v2
            ;;
        2)
            configure_i3_v2
            ;;
        3)
            configure_hyprland_v2
            ;;
        4)
            configure_awesome_v2
            ;;
        5)
            configure_dwm_v2
            ;;
        0)
            return 0
            ;;
        *)
            show_notification "Invalid choice: $choice" "error"
            ;;
    esac
}

# Terminal Configuration Management V2
manage_terminal_configuration_v2() {
    clear
    display_section_header "Terminal Configuration" "📺"
    
    show_notification "Terminal configuration management coming soon!" "info"
    echo
    printf "Terminal configuration features:\n"
    printf "  • Alacritty configuration\n"
    printf "  • Kitty terminal setup\n"
    printf "  • WezTerm configuration\n"
    printf "  • Ghostty setup\n"
    printf "  • Tmux/screen configuration\n"
    echo
}

# Enhanced System Cleanup V2
manage_system_cleanup_v2() {
    clear
    display_section_header "System Cleanup" "🧹"
    
    echo
    printf "  1. Clean orphaned packages\n"
    printf "  2. Clean package cache\n"
    printf "  3. Clean AUR cache\n"
    printf "  4. Clean system logs\n"
    printf "  5. Clean temporary files\n"
    printf "  6. Clean user cache\n"
    printf "  7. Comprehensive cleanup (safe)\n"
    printf "  8. Advanced cleanup options\n"
    printf "  0. Back\n"
    echo
    
    local choice
    printf "Choose cleanup action [0-8]: "
    choice=$(read_single_key)
    echo "$choice"
    echo
    
    case "$choice" in
        1)
            clean_orphaned_packages_v2
            ;;
        2)
            clean_package_cache_v2
            ;;
        3)
            clean_aur_cache_v2
            ;;
        4)
            clean_system_logs_v2
            ;;
        5)
            clean_temp_files_v2
            ;;
        6)
            clean_user_cache_v2
            ;;
        7)
            comprehensive_cleanup_v2
            ;;
        8)
            advanced_cleanup_options_v2
            ;;
        0)
            return 0
            ;;
        *)
            show_notification "Invalid choice: $choice" "error"
            ;;
    esac
}

# System Information Display
show_system_information() {
    clear
    display_section_header "System Information" "📊"
    
    echo
    printf "🖥️  ${BOLD}System Details:${NC}\n"
    printf "   OS: %s\n" "$(grep '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d'"' -f2 || echo "Unknown")"
    printf "   Kernel: %s\n" "$(uname -r)"
    printf "   Architecture: %s\n" "$(uname -m)"
    printf "   Uptime: %s\n" "$(uptime -p 2>/dev/null || echo "Unknown")"
    echo
    
    printf "🖥️  ${BOLD}Shell Environment:${NC}\n"
    printf "   Current shell: %s\n" "$CURRENT_SHELL"
    printf "   Available shells: %s\n" "${AVAILABLE_SHELLS[*]}"
    echo
    
    printf "🔧 ${BOLD}System Services:${NC}\n"
    printf "   Systemd: %s\n" "$([[ "$SYSTEMD_AVAILABLE" == "true" ]] && echo "${GREEN}Available${NC}" || echo "${RED}Not Available${NC}")"
    printf "   NetworkManager: %s\n" "$([[ "$NETWORKMANAGER_AVAILABLE" == "true" ]] && echo "${GREEN}Available${NC}" || echo "${RED}Not Available${NC}")"
    echo
    
    printf "🧹 ${BOLD}Cleanup Tools:${NC}\n"
    printf "   Paccache: %s\n" "$([[ "$PACCACHE_AVAILABLE" == "true" ]] && echo "${GREEN}Available${NC}" || echo "${RED}Not Available${NC}")"
    printf "   BleachBit: %s\n" "$([[ "$BLEACHBIT_AVAILABLE" == "true" ]] && echo "${GREEN}Available${NC}" || echo "${RED}Not Available${NC}")"
    echo
    
    printf "💾 ${BOLD}Backup Tools:${NC}\n"
    printf "   Timeshift: %s\n" "$([[ "$TIMESHIFT_AVAILABLE" == "true" ]] && echo "${GREEN}Available${NC}" || echo "${RED}Not Available${NC}")"
    printf "   Rsync: %s\n" "$([[ "$RSYNC_AVAILABLE" == "true" ]] && echo "${GREEN}Available${NC}" || echo "${RED}Not Available${NC}")"
    echo
}

# Shell Configuration Functions (placeholders for now)
configure_bash_v2() {
    show_notification "Bash configuration coming soon!" "info"
}

configure_zsh_v2() {
    show_notification "Zsh configuration coming soon!" "info"
}

configure_fish_v2() {
    show_notification "Fish configuration coming soon!" "info"
}

change_default_shell_v2() {
    show_notification "Shell changing functionality coming soon!" "info"
}

install_shell_themes_v2() {
    show_notification "Shell themes installation coming soon!" "info"
}

# System Services Functions (placeholders for now)
view_running_services() {
    clear
    display_section_header "Running Services" "🔧"
    echo
    systemctl list-units --type=service --state=running
    echo
}

manage_service_state() {
    show_notification "Service state management coming soon!" "info"
}

manage_service_enablement() {
    show_notification "Service enablement management coming soon!" "info"
}

view_service_logs() {
    show_notification "Service logs viewing coming soon!" "info"
}

view_systemd_status() {
    clear
    display_section_header "Systemd Status" "🔧"
    echo
    systemctl status
    echo
}

# Backup Functions (placeholders for now)
create_system_snapshot() {
    show_notification "Creating system snapshot..." "info"
    if sudo timeshift --create --comments "Created by Linux Manager V2" --tags D; then
        show_notification "System snapshot created successfully" "success"
        publish_event "system.backup_created" "{\"type\":\"snapshot\",\"timestamp\":$(date +%s)}"
    else
        show_notification "Failed to create system snapshot" "error"
    fi
}

view_system_snapshots() {
    clear
    display_section_header "System Snapshots" "💾"
    echo
    timeshift --list
    echo
}

restore_system_snapshot() {
    show_notification "Snapshot restoration coming soon!" "info"
}

configure_automatic_backups() {
    show_notification "Automatic backup configuration coming soon!" "info"
}

delete_old_snapshots() {
    show_notification "Snapshot deletion coming soon!" "info"
}

# Window Manager Configuration Functions (placeholders for now)
configure_qtile_v2() {
    if declare -f configure_qtile >/dev/null 2>&1; then
        configure_qtile
        publish_event "system.configured" "{\"type\":\"window_manager\",\"name\":\"qtile\"}"
    else
        show_notification "Qtile configuration not available" "error"
    fi
}

configure_i3_v2() {
    show_notification "i3 configuration coming soon!" "info"
}

configure_hyprland_v2() {
    show_notification "Hyprland configuration coming soon!" "info"
}

configure_awesome_v2() {
    show_notification "AwesomeWM configuration coming soon!" "info"
}

configure_dwm_v2() {
    show_notification "dwm configuration coming soon!" "info"
}

# Cleanup Functions (enhanced versions)
clean_orphaned_packages_v2() {
    show_progress "Scanning for orphaned packages" 30
    local orphans
    orphans=$(pacman -Qdtq 2>/dev/null)
    
    show_progress "Cleanup scan complete" 100
    
    if [[ -z "$orphans" ]]; then
        show_notification "No orphaned packages found" "success"
    else
        printf "Found orphaned packages:\n"
        echo "$orphans"
        echo
        
        if confirm_yn "Remove all orphaned packages?"; then
            show_progress "Removing orphaned packages" 50
            if sudo pacman -Rns $orphans --noconfirm; then
                show_progress "Cleanup complete" 100
                show_notification "Orphaned packages removed successfully" "success"
                publish_event "system.cleaned" "{\"type\":\"orphaned_packages\",\"count\":$(echo "$orphans" | wc -l)}"
            else
                show_notification "Failed to remove some orphaned packages" "error"
            fi
        fi
    fi
}

clean_package_cache_v2() {
    if [[ "$PACCACHE_AVAILABLE" == "true" ]]; then
        show_progress "Cleaning package cache" 50
        if sudo paccache -r; then
            show_progress "Cache cleanup complete" 100
            show_notification "Package cache cleaned successfully" "success"
            publish_event "system.cleaned" "{\"type\":\"package_cache\"}"
        else
            show_notification "Failed to clean package cache" "error"
        fi
    else
        show_notification "paccache not available. Install pacman-contrib package" "error"
    fi
}

clean_aur_cache_v2() {
    show_notification "AUR cache cleanup coming soon!" "info"
}

clean_system_logs_v2() {
    show_progress "Cleaning system logs" 50
    if sudo journalctl --vacuum-time=30d; then
        show_progress "Log cleanup complete" 100
        show_notification "System logs cleaned (kept last 30 days)" "success"
        publish_event "system.cleaned" "{\"type\":\"system_logs\"}"
    else
        show_notification "Failed to clean system logs" "error"
    fi
}

clean_temp_files_v2() {
    show_progress "Cleaning temporary files" 50
    local temp_dirs=("/tmp" "/var/tmp" "$HOME/.cache/thumbnails")
    local cleaned=0
    
    for dir in "${temp_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            local old_files
            old_files=$(find "$dir" -type f -mtime +7 2>/dev/null | wc -l)
            if [[ $old_files -gt 0 ]]; then
                find "$dir" -type f -mtime +7 -delete 2>/dev/null && ((cleaned += old_files))
            fi
        fi
    done
    
    show_progress "Temp file cleanup complete" 100
    show_notification "Cleaned $cleaned temporary files (older than 7 days)" "success"
    publish_event "system.cleaned" "{\"type\":\"temp_files\",\"count\":$cleaned}"
}

clean_user_cache_v2() {
    show_progress "Cleaning user cache" 50
    local cache_size=0
    
    if [[ -d "$HOME/.cache" ]]; then
        cache_size=$(du -sh "$HOME/.cache" 2>/dev/null | cut -f1 || echo "0")
        # Clean old cache files (keep recent ones)
        find "$HOME/.cache" -type f -mtime +30 -delete 2>/dev/null
        show_progress "User cache cleanup complete" 100
        show_notification "User cache cleaned (was $cache_size)" "success"
        publish_event "system.cleaned" "{\"type\":\"user_cache\",\"size\":\"$cache_size\"}"
    else
        show_notification "No user cache directory found" "info"
    fi
}

comprehensive_cleanup_v2() {
    show_notification "Starting comprehensive system cleanup..." "info"
    
    # Run all safe cleanup operations
    clean_orphaned_packages_v2
    clean_package_cache_v2
    clean_system_logs_v2
    clean_temp_files_v2
    clean_user_cache_v2
    
    show_notification "Comprehensive cleanup completed" "success"
    publish_event "system.cleaned" "{\"type\":\"comprehensive\"}"
}

advanced_cleanup_options_v2() {
    show_notification "Advanced cleanup options coming soon!" "info"
}

# Module cleanup
cleanup_system_module() {
    log_debug "Cleaning up system module"
    
    # Clear any temporary files
    [[ -d "/tmp/linux-manager-system" ]] && rm -rf "/tmp/linux-manager-system"
    
    # Unsubscribe from events
    unsubscribe_from_event "packages.installed" "on_system_packages_installed"
    unsubscribe_from_event "ui.theme_changed" "reload_system_ui"
    
    log_debug "System module cleanup complete"
}

# Export main functions for V2 compatibility
manage_system_configurations() {
    manage_system_v2
}

install_configurations() {
    manage_system_v2
}
