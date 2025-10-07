#!/bin/bash

# Linux Manager V2 - Packages Module Manager
# Advanced package management for Pacman, AUR, and Flatpak
#
# @VERSION: 2.0.0
# @DESCRIPTION: Enhanced package management with caching, events, and performance optimizations
# @AUTHOR: Linux Manager Team

# Module initialization
init_packages_module() {
    log_debug "Initializing packages module v2.0.0"
    
    # Load V1 compatibility layer
    source_v1_modules
    
    # Initialize caching system
    init_package_cache
    
    # Subscribe to events
    subscribe_to_event "perf.cache_clear" "clear_package_cache"
    subscribe_to_event "ui.theme_changed" "reload_package_ui"
    
    # Initialize package managers
    init_package_managers
    
    log_info "Packages module initialized successfully"
    return 0
}

# Source V1 modules for compatibility
source_v1_modules() {
    local v1_modules_dir="$ROOT_DIR/src/modules/packages"
    
    if [[ -d "$v1_modules_dir" ]]; then
        log_debug "Loading V1 package modules for compatibility"
        
        # Source V1 modules with error handling
        local modules=("pacman.sh" "aur.sh" "flatpak.sh")
        for module in "${modules[@]}"; do
            local module_path="$v1_modules_dir/$module"
            if [[ -f "$module_path" ]]; then
                if source "$module_path" 2>/dev/null; then
                    log_debug "Loaded V1 module: $module"
                else
                    log_warning "Failed to load V1 module: $module"
                fi
            else
                log_warning "V1 module not found: $module"
            fi
        done
    else
        log_warning "V1 modules directory not found: $v1_modules_dir"
    fi
}

# Initialize package cache system
init_package_cache() {
    if get_config "PACKAGE_CACHE_ENABLED" "true" == "true"; then
        local cache_dir="$ROOT_DIR/.cache/packages"
        mkdir -p "$cache_dir"
        export PACKAGES_CACHE_DIR="$cache_dir"
        export PACKAGES_CACHE_TTL=$(get_config "PACKAGE_CACHE_TTL" "300")
        log_debug "Package cache initialized: $cache_dir (TTL: ${PACKAGES_CACHE_TTL}s)"
    else
        log_debug "Package cache disabled by configuration"
    fi
}

# Initialize package managers
init_package_managers() {
    log_debug "Detecting package managers"
    
    # Check Pacman
    if command -v pacman >/dev/null 2>&1; then
        export PACMAN_AVAILABLE=true
        log_debug "Pacman detected and available"
    else
        export PACMAN_AVAILABLE=false
        log_warning "Pacman not available"
    fi
    
    # Check AUR helpers
    detect_aur_helper
    
    # Check Flatpak
    if command -v flatpak >/dev/null 2>&1; then
        export FLATPAK_AVAILABLE=true
        log_debug "Flatpak detected and available"
    else
        export FLATPAK_AVAILABLE=false
        log_debug "Flatpak not available"
    fi
}

# Detect AUR helper
detect_aur_helper() {
    local aur_preference=$(get_config "PREFERRED_AUR_HELPER" "auto")
    
    case "$aur_preference" in
        "auto")
            if command -v yay >/dev/null 2>&1; then
                export AUR_HELPER="yay"
                export AUR_AVAILABLE=true
            elif command -v paru >/dev/null 2>&1; then
                export AUR_HELPER="paru"
                export AUR_AVAILABLE=true
            else
                export AUR_HELPER=""
                export AUR_AVAILABLE=false
            fi
            ;;
        "yay"|"paru")
            if command -v "$aur_preference" >/dev/null 2>&1; then
                export AUR_HELPER="$aur_preference"
                export AUR_AVAILABLE=true
            else
                export AUR_HELPER=""
                export AUR_AVAILABLE=false
                log_warning "Preferred AUR helper '$aur_preference' not found"
            fi
            ;;
        *)
            export AUR_HELPER=""
            export AUR_AVAILABLE=false
            log_warning "Invalid AUR helper preference: $aur_preference"
            ;;
    esac
    
    if [[ "$AUR_AVAILABLE" == "true" ]]; then
        log_debug "AUR helper detected: $AUR_HELPER"
    else
        log_debug "No AUR helper available"
    fi
}

# Clear package cache
clear_package_cache() {
    if [[ -n "$PACKAGES_CACHE_DIR" && -d "$PACKAGES_CACHE_DIR" ]]; then
        log_info "Clearing package cache"
        rm -rf "$PACKAGES_CACHE_DIR"/*
        mkdir -p "$PACKAGES_CACHE_DIR"
        show_notification "Package cache cleared" "info"
    fi
}

# Reload package UI (for theme changes)
reload_package_ui() {
    log_debug "Reloading package UI for theme change"
    # UI reload logic would go here
}

# Health check function
check_packages_health() {
    local health_score=100
    local issues=()
    
    # Check Pacman health
    if [[ "$PACMAN_AVAILABLE" != "true" ]]; then
        health_score=$((health_score - 50))
        issues+=("Pacman not available")
    fi
    
    # Check AUR helper health
    if [[ "$AUR_AVAILABLE" != "true" ]] && get_config "PREFERRED_AUR_HELPER" "auto" != "disabled"; then
        health_score=$((health_score - 20))
        issues+=("AUR helper not available")
    fi
    
    # Check Flatpak health
    # Note: No specific Flatpak enabled config registered, using default check
    if [[ "$FLATPAK_AVAILABLE" != "true" ]]; then
        health_score=$((health_score - 10))
        issues+=("Flatpak not available but enabled")
    fi
    
    # Check cache directory
    if [[ -n "$PACKAGES_CACHE_DIR" && ! -d "$PACKAGES_CACHE_DIR" ]]; then
        health_score=$((health_score - 10))
        issues+=("Cache directory missing")
    fi
    
    # Report health
    if [[ $health_score -ge 90 ]]; then
        log_debug "Packages module health: excellent ($health_score/100)"
        return 0
    elif [[ $health_score -ge 70 ]]; then
        log_info "Packages module health: good ($health_score/100) - Issues: ${issues[*]}"
        return 0
    else
        log_warning "Packages module health: poor ($health_score/100) - Issues: ${issues[*]}"
        return 1
    fi
}

# Enhanced package installation with events and caching
install_packages_enhanced() {
    local package_manager="$1"
    shift
    local packages=("$@")
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        log_error "No packages specified for installation"
        return 1
    fi
    
    log_info "Installing ${#packages[@]} packages via $package_manager"
    publish_event "packages.install_started" "{\"manager\":\"$package_manager\",\"count\":${#packages[@]}}"
    
    # Show progress
    show_progress "Installing packages" 0
    
    local success=0
    local failed=0
    
    case "$package_manager" in
        "pacman")
            if install_pacman_packages "${packages[@]}"; then
                success=${#packages[@]}
            else
                failed=${#packages[@]}
            fi
            ;;
        "aur")
            if install_aur_packages "${packages[@]}"; then
                success=${#packages[@]}
            else
                failed=${#packages[@]}
            fi
            ;;
        "flatpak")
            if install_flatpak_apps "${packages[@]}"; then
                success=${#packages[@]}
            else
                failed=${#packages[@]}
            fi
            ;;
        *)
            log_error "Unknown package manager: $package_manager"
            failed=${#packages[@]}
            ;;
    esac
    
    show_progress "Installation complete" 100
    
    # Publish completion event
    publish_event "packages.installed" "{\"manager\":\"$package_manager\",\"success\":$success,\"failed\":$failed}"
    
    if [[ $success -gt 0 ]]; then
        show_notification "$success packages installed successfully" "success"
        log_info "Successfully installed $success packages"
    fi
    
    if [[ $failed -gt 0 ]]; then
        show_notification "$failed packages failed to install" "error"
        log_error "Failed to install $failed packages"
        return 1
    fi
    
    return 0
}

# Enhanced package search with caching
search_packages_enhanced() {
    local query="$1"
    local package_manager="${2:-all}"
    
    if [[ -z "$query" ]]; then
        log_error "Search query is required"
        return 1
    fi
    
    log_info "Searching packages: $query (manager: $package_manager)"
    
    # Check cache first
    local cache_file="$PACKAGES_CACHE_DIR/search_${package_manager}_$(echo "$query" | md5sum | cut -d' ' -f1)"
    local use_cache=false
    
    if [[ -f "$cache_file" ]] && get_config "PACKAGE_CACHE_ENABLED" "true" == "true"; then
        local cache_age=$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0)))
        if [[ $cache_age -lt $PACKAGES_CACHE_TTL ]]; then
            use_cache=true
            log_debug "Using cached search results (age: ${cache_age}s)"
        fi
    fi
    
    if [[ "$use_cache" == "true" ]]; then
        cat "$cache_file"
        return 0
    fi
    
    # Perform search
    show_progress "Searching packages" 30
    
    local results=""
    case "$package_manager" in
        "pacman")
            results=$(search_pacman_package "$query" 2>/dev/null || echo "")
            ;;
        "aur")
            results=$(search_aur_package "$query" 2>/dev/null || echo "")
            ;;
        "flatpak")
            results=$(search_flatpak_app "$query" 2>/dev/null || echo "")
            ;;
        "all")
            {
                echo "=== Pacman Results ==="
                search_pacman_package "$query" 2>/dev/null || echo "No results"
                echo
                echo "=== AUR Results ==="
                search_aur_package "$query" 2>/dev/null || echo "No results"
                echo
                echo "=== Flatpak Results ==="
                search_flatpak_app "$query" 2>/dev/null || echo "No results"
            } > /tmp/search_results.tmp
            results=$(cat /tmp/search_results.tmp)
            rm -f /tmp/search_results.tmp
            ;;
        *)
            log_error "Unknown package manager for search: $package_manager"
            return 1
            ;;
    esac
    
    show_progress "Search complete" 100
    
    # Cache results
    if [[ -n "$PACKAGES_CACHE_DIR" ]]; then
        echo "$results" > "$cache_file"
        log_debug "Cached search results: $cache_file"
    fi
    
    echo "$results"
    return 0
}

# Enhanced system update with progress tracking
update_system_enhanced() {
    log_info "Starting enhanced system update"
    publish_event "packages.update_started" "{\"timestamp\":$(date +%s)}"
    
    show_progress "Updating package databases" 10
    
    local total_updated=0
    local update_errors=0
    
    # Update Pacman
    if [[ "$PACMAN_AVAILABLE" == "true" ]]; then
        show_progress "Updating Pacman packages" 30
        if update_pacman_database && upgrade_all_pacman_packages; then
            local pacman_updated=$(pacman -Qu 2>/dev/null | wc -l || echo "0")
            total_updated=$((total_updated + pacman_updated))
            log_info "Updated $pacman_updated Pacman packages"
        else
            ((update_errors++))
            log_error "Failed to update Pacman packages"
        fi
    fi
    
    # Update AUR
    if [[ "$AUR_AVAILABLE" == "true" ]]; then
        show_progress "Updating AUR packages" 60
        if upgrade_all_aur_packages; then
            log_info "Updated AUR packages"
            ((total_updated++))  # AUR doesn't provide exact count easily
        else
            ((update_errors++))
            log_error "Failed to update AUR packages"
        fi
    fi
    
    # Update Flatpak
    if [[ "$FLATPAK_AVAILABLE" == "true" ]]; then
        show_progress "Updating Flatpak applications" 90
        if update_flatpak_apps; then
            log_info "Updated Flatpak applications"
            ((total_updated++))  # Flatpak doesn't provide exact count easily
        else
            ((update_errors++))
            log_error "Failed to update Flatpak applications"
        fi
    fi
    
    show_progress "System update complete" 100
    
    # Publish completion event
    publish_event "packages.updated" "{\"total_updated\":$total_updated,\"errors\":$update_errors}"
    
    if [[ $update_errors -eq 0 ]]; then
        show_notification "System updated successfully" "success"
        log_info "System update completed successfully ($total_updated updates)"
        return 0
    else
        show_notification "System update completed with $update_errors errors" "warning"
        log_warning "System update completed with $update_errors errors"
        return 1
    fi
}

# Display enhanced packages menu
display_packages_menu_v2() {
    clear
    
    # Use V2 UI system for better display
    display_module_header "PACKAGES" "📦"
    
    echo
    printf "  📦 ${GREEN}${BOLD}[1]${NC}  ${WHITE}Install Packages${NC}\n"
    printf "      ${GRAY}${DIM}Install from Pacman, AUR, or Flatpak${NC}\n"
    echo
    
    printf "  🔍 ${GREEN}${BOLD}[2]${NC}  ${WHITE}Search Packages${NC}\n"
    printf "      ${GRAY}${DIM}Search across all package managers${NC}\n"
    echo
    
    printf "  ⬆️  ${GREEN}${BOLD}[3]${NC}  ${WHITE}Update System${NC}\n"
    printf "      ${GRAY}${DIM}Update all packages and applications${NC}\n"
    echo
    
    printf "  ❌ ${GREEN}${BOLD}[4]${NC}  ${WHITE}Remove Packages${NC}\n"
    printf "      ${GRAY}${DIM}Uninstall packages and dependencies${NC}\n"
    echo
    
    printf "  📊 ${GREEN}${BOLD}[5]${NC}  ${WHITE}Package Statistics${NC}\n"
    printf "      ${GRAY}${DIM}View system package information${NC}\n"
    echo
    
    printf "  🔧 ${GREEN}${BOLD}[6]${NC}  ${WHITE}Package Manager Settings${NC}\n"
    printf "      ${GRAY}${DIM}Configure package management options${NC}\n"
    echo
    
    printf "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[0]${NC}  ${WHITE}Return to Main Menu${NC}\n"
    printf "      ${GRAY}${DIM}Go back to the main menu${NC}\n"
    echo
    
    display_module_footer "Choose option [0-6]"
}

# Main packages module function
manage_packages_v2() {
    log_debug "Starting V2 packages management"
    
    while true; do
        display_packages_menu_v2
        
        local choice
        choice=$(read_single_key)
        echo "$choice"
        echo
        
        case "$choice" in
            1)
                manage_package_installation
                ;;
            2)
                manage_package_search
                ;;
            3)
                update_system_enhanced
                ;;
            4)
                manage_package_removal
                ;;
            5)
                show_package_statistics
                ;;
            6)
                manage_package_settings
                ;;
            0)
                log_debug "Exiting packages module"
                return 0
                ;;
            *)
                show_notification "Invalid choice: $choice" "error"
                ;;
        esac
        
        wait_for_user
    done
}

# Package installation submenu
manage_package_installation() {
    clear
    display_section_header "Package Installation" "📦"
    
    echo
    printf "  1. Pacman packages (official repositories)\n"
    printf "  2. AUR packages (Arch User Repository)\n"
    printf "  3. Flatpak applications\n"
    printf "  4. Custom package lists\n"
    printf "  0. Back\n"
    echo
    
    local choice
    printf "Choose installation method [0-4]: "
    choice=$(read_single_key)
    echo "$choice"
    echo
    
    case "$choice" in
        1)
            if [[ "$PACMAN_AVAILABLE" == "true" ]]; then
                install_pacman_interactive
            else
                show_notification "Pacman not available" "error"
            fi
            ;;
        2)
            if [[ "$AUR_AVAILABLE" == "true" ]]; then
                install_aur_interactive
            else
                show_notification "AUR helper not available" "error"
            fi
            ;;
        3)
            if [[ "$FLATPAK_AVAILABLE" == "true" ]]; then
                install_flatpak_interactive
            else
                show_notification "Flatpak not available" "error"
            fi
            ;;
        4)
            install_package_lists
            ;;
        0)
            return 0
            ;;
        *)
            show_notification "Invalid choice: $choice" "error"
            ;;
    esac
}

# Interactive Pacman installation
install_pacman_interactive() {
    printf "Enter package names (space-separated): "
    read -r packages
    
    if [[ -n "$packages" ]]; then
        # Convert string to array
        local pkg_array=()
        read -ra pkg_array <<< "$packages"
        install_packages_enhanced "pacman" "${pkg_array[@]}"
    else
        show_notification "No packages specified" "warning"
    fi
}

# Interactive AUR installation
install_aur_interactive() {
    printf "Enter AUR package names (space-separated): "
    read -r packages
    
    if [[ -n "$packages" ]]; then
        # Convert string to array
        local pkg_array=()
        read -ra pkg_array <<< "$packages"
        install_packages_enhanced "aur" "${pkg_array[@]}"
    else
        show_notification "No packages specified" "warning"
    fi
}

# Interactive Flatpak installation
install_flatpak_interactive() {
    printf "Enter Flatpak application IDs (space-separated): "
    read -r packages
    
    if [[ -n "$packages" ]]; then
        # Convert string to array
        local pkg_array=()
        read -ra pkg_array <<< "$packages"
        install_packages_enhanced "flatpak" "${pkg_array[@]}"
    else
        show_notification "No applications specified" "warning"
    fi
}

# Package search submenu
manage_package_search() {
    printf "Enter search query: "
    read -r query
    
    if [[ -n "$query" ]]; then
        clear
        display_section_header "Search Results: $query" "🔍"
        echo
        search_packages_enhanced "$query" "all"
    else
        show_notification "No search query provided" "warning"
    fi
}

# Package removal (placeholder - would implement similar to install)
manage_package_removal() {
    show_notification "Package removal feature coming soon!" "info"
}

# Package statistics
show_package_statistics() {
    clear
    display_section_header "Package Statistics" "📊"
    
    echo
    if [[ "$PACMAN_AVAILABLE" == "true" ]]; then
        local installed_count=$(pacman -Q | wc -l)
        local explicit_count=$(pacman -Qe | wc -l)
        local orphan_count=$(pacman -Qdtq | wc -l 2>/dev/null || echo "0")
        
        printf "📦 Pacman Packages:\n"
        printf "   Total installed: %d\n" "$installed_count"
        printf "   Explicitly installed: %d\n" "$explicit_count"
        printf "   Orphaned packages: %d\n" "$orphan_count"
        echo
    fi
    
    if [[ "$FLATPAK_AVAILABLE" == "true" ]]; then
        local flatpak_count=$(flatpak list --app 2>/dev/null | wc -l || echo "0")
        printf "📱 Flatpak Applications: %d\n" "$flatpak_count"
        echo
    fi
    
    if [[ -n "$AUR_HELPER" ]]; then
        printf "🏗️  AUR Helper: %s\n" "$AUR_HELPER"
        echo
    fi
}

# Package settings
manage_package_settings() {
    show_notification "Package settings feature coming soon!" "info"
}

# Install predefined package lists
install_package_lists() {
    clear
    display_section_header "Install Package Lists" "📋"
    
    # Load V1 package lists if available
    local data_dir="$ROOT_DIR/src/data/packages"
    if [[ -d "$data_dir" ]]; then
        echo
        printf "Available package lists:\n"
        printf "  1. Essential packages (pacman.list)\n"
        printf "  2. Development packages (dev.list)\n"
        printf "  3. Multimedia packages (multimedia.list)\n"
        printf "  4. AUR packages (aur.list)\n"
        printf "  0. Back\n"
        echo
        
        local choice
        printf "Choose package list [0-4]: "
        choice=$(read_single_key)
        echo "$choice"
        echo
        
        case "$choice" in
            1)
                install_package_list "$data_dir/pacman.list" "pacman"
                ;;
            2)
                install_package_list "$data_dir/dev.list" "pacman"
                ;;
            3)
                install_package_list "$data_dir/multimedia.list" "pacman"
                ;;
            4)
                install_package_list "$data_dir/aur.list" "aur"
                ;;
            0)
                return 0
                ;;
            *)
                show_notification "Invalid choice: $choice" "error"
                ;;
        esac
    else
        show_notification "Package lists not found" "error"
    fi
}

# Install packages from a list file
install_package_list() {
    local list_file="$1"
    local manager="$2"
    
    if [[ ! -f "$list_file" ]]; then
        show_notification "Package list not found: $list_file" "error"
        return 1
    fi
    
    # Read packages from file (skip comments and empty lines)
    local packages=()
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        packages+=("$line")
    done < "$list_file"
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        show_notification "No packages found in list" "warning"
        return 1
    fi
    
    log_info "Installing ${#packages[@]} packages from $(basename "$list_file")"
    install_packages_enhanced "$manager" "${packages[@]}"
}

# Module cleanup
cleanup_packages_module() {
    log_debug "Cleaning up packages module"
    
    # Clear any temporary files
    [[ -d "/tmp/linux-manager-packages" ]] && rm -rf "/tmp/linux-manager-packages"
    
    # Unsubscribe from events
    unsubscribe_from_event "perf.cache_clear" "clear_package_cache"
    unsubscribe_from_event "ui.theme_changed" "reload_package_ui"
    
    log_debug "Packages module cleanup complete"
}

# Export main function for V2 compatibility
manage_packages_environment() {
    manage_packages_v2
}
