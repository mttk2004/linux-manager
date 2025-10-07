#!/bin/bash

# V1 Integration Layer for V2 System
# Provides seamless integration between V2 UI and V1 modules
#
# @VERSION: 2.0.0
# @DESCRIPTION: Integration layer for V1 modules in V2 architecture
# @AUTHOR: Linux Manager Team
# @LICENSE: MIT

# Get base directory reliably
V1_INTEGRATION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
V1_BASE_DIR="$(cd "$V1_INTEGRATION_DIR/../../.." && pwd)"

# Source V2 UI system for consistency (only if not currently loading)
if [[ ! "${UI_SYSTEM_INITIALIZED:-false}" == "true" && "${UI_INTEGRATION_LOADED:-false}" != "true" ]]; then
    if [[ -f "$V1_INTEGRATION_DIR/ui_system.sh" ]]; then
        # Prevent circular loading
        UI_INTEGRATION_LOADED=true
        source "$V1_INTEGRATION_DIR/ui_system.sh"
        init_ui_system
    fi
fi

# V1 Module paths
declare -g V1_MODULES_DIR="${ROOT_DIR:-$V1_BASE_DIR}/src/modules"
declare -g V1_DATA_DIR="${ROOT_DIR:-$V1_BASE_DIR}/src/data"
declare -g V1_CORE_DIR="${ROOT_DIR:-$V1_BASE_DIR}/src/core"

# V1 Integration status
declare -g V1_INTEGRATION_INITIALIZED=false
declare -gA V1_LOADED_MODULES=()

# Initialize V1 integration
init_v1_integration() {
    if [[ "$V1_INTEGRATION_INITIALIZED" == "true" ]]; then
        return 0
    fi
    
    log_info "V1_INTEGRATION" "Initializing V1 module integration"
    log_debug "V1_INTEGRATION" "V1 modules dir: $V1_MODULES_DIR"
    log_debug "V1_INTEGRATION" "V1 data dir: $V1_DATA_DIR"
    log_debug "V1_INTEGRATION" "V1 core dir: $V1_CORE_DIR"
    
    # Check if V1 directories exist
    if [[ ! -d "$V1_MODULES_DIR" ]]; then
        log_error "V1_INTEGRATION" "V1 modules directory not found: $V1_MODULES_DIR"
        return 1
    fi
    
    # Load V1 core modules first
    load_v1_core_modules
    
    # Load package lists
    load_v1_package_lists
    
    V1_INTEGRATION_INITIALIZED=true
    log_info "V1_INTEGRATION" "V1 integration initialized successfully"
    
    return 0
}

# Load V1 core modules
load_v1_core_modules() {
    log_debug "V1_INTEGRATION" "Loading V1 core modules"
    
    # Load V1 core modules if they exist
    local core_modules=("config.sh" "ui.sh" "utils.sh")
    
    for module in "${core_modules[@]}"; do
        local module_path="$V1_CORE_DIR/$module"
        if [[ -f "$module_path" ]]; then
            log_debug "V1_INTEGRATION" "Loading V1 core module: $module"
            # Source with error handling
            if source "$module_path" 2>/dev/null; then
                log_debug "V1_INTEGRATION" "Successfully loaded V1 core: $module"
            else
                log_warning "V1_INTEGRATION" "Failed to load V1 core: $module"
            fi
        else
            log_debug "V1_INTEGRATION" "V1 core module not found: $module_path"
        fi
    done
}

# Load V1 package lists into arrays
load_v1_package_lists() {
    log_debug "V1_INTEGRATION" "Loading V1 package lists"
    
    # Package list files
    declare -gA V1_PACKAGE_LISTS=(
        ["pacman"]="$V1_DATA_DIR/packages/pacman.list"
        ["dev"]="$V1_DATA_DIR/packages/dev.list"  
        ["multimedia"]="$V1_DATA_DIR/packages/multimedia.list"
        ["aur"]="$V1_DATA_DIR/packages/aur.list"
    )
    
    # Load each package list
    for list_name in "${!V1_PACKAGE_LISTS[@]}"; do
        local list_file="${V1_PACKAGE_LISTS[$list_name]}"
        
        if [[ -f "$list_file" ]]; then
            log_debug "V1_INTEGRATION" "Loading package list: $list_name from $list_file"
            
            # Create dynamic array name
            local array_name="V1_${list_name^^}_PACKAGES"
            declare -ga "$array_name"
            
            # Read packages into array
            local -n package_array="$array_name"
            package_array=()
            
            while IFS= read -r line; do
                # Skip empty lines and comments
                if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
                    package_array+=("$line")
                fi
            done < "$list_file"
            
            log_debug "V1_INTEGRATION" "Loaded ${#package_array[@]} packages from $list_name list"
        else
            log_warning "V1_INTEGRATION" "Package list not found: $list_file"
        fi
    done
}

# Load a V1 module
load_v1_module() {
    local module_name="$1"
    local module_category="${2:-packages}"
    
    local module_path="$V1_MODULES_DIR/$module_category/$module_name"
    
    if [[ -f "$module_path" ]]; then
        log_debug "V1_INTEGRATION" "Loading V1 module: $module_name"
        
        if source "$module_path" 2>/dev/null; then
            V1_LOADED_MODULES["$module_name"]="$module_path"
            log_debug "V1_INTEGRATION" "Successfully loaded V1 module: $module_name"
            return 0
        else
            log_error "V1_INTEGRATION" "Failed to load V1 module: $module_name"
            return 1
        fi
    else
        log_warning "V1_INTEGRATION" "V1 module not found: $module_path"
        return 1
    fi
}

# Enhanced package installation using V1 modules
install_v1_packages_with_ui() {
    local list_type="$1"
    shift
    local packages=("$@")
    
    # If no packages provided, try to load from list
    if [[ ${#packages[@]} -eq 0 ]]; then
        local array_name="V1_${list_type^^}_PACKAGES"
        if declare -n package_array="$array_name" 2>/dev/null; then
            packages=("${package_array[@]}")
        else
            show_notification "No packages found for type: $list_type" "error"
            wait_for_user
            return 1
        fi
    fi
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        show_notification "No packages to install" "warning"
        wait_for_user
        return 1
    fi
    
    display_module_header "INSTALL ${list_type^^} PACKAGES" "📦"
    
    printf "${UI_COLORS[info]}Found ${UI_COLORS[success]}${#packages[@]}${UI_COLORS[info]} packages to install:${UI_COLORS[reset]}\n"
    echo
    
    # Display packages in a nice format
    local count=0
    for package in "${packages[@]}"; do
        if [[ $count -eq 0 ]]; then
            printf "  "
        fi
        printf "${UI_COLORS[accent]}$package${UI_COLORS[reset]} "
        ((count++))
        if [[ $count -eq 4 ]]; then
            echo
            count=0
        fi
    done
    [[ $count -ne 0 ]] && echo
    
    echo
    if ui_confirm "Do you want to install these packages?"; then
        echo
        
        # Load appropriate V1 module
        case "$list_type" in
            "pacman"|"dev"|"multimedia")
                if load_v1_module "pacman.sh" "packages"; then
                    # Use V1 function with V2 UI feedback
                    install_v1_pacman_with_v2_ui "${packages[@]}"
                else
                    # Fallback to V2 implementation
                    install_packages_with_pacman "${packages[@]}"
                fi
                ;;
            "aur")
                if load_v1_module "aur.sh" "packages"; then
                    install_v1_aur_with_v2_ui "${packages[@]}"
                else
                    install_packages_with_aur "${packages[@]}"
                fi
                ;;
            *)
                show_notification "Unknown package list type: $list_type" "error"
                ;;
        esac
    else
        show_notification "Installation cancelled by user" "info"
    fi
    
    echo
    wait_for_user
}

# Install pacman packages using V1 logic with V2 UI
install_v1_pacman_with_v2_ui() {
    local packages=("$@")
    local installed_count=0
    local skipped_count=0
    local already_count=0
    
    show_progress "Checking package availability" 10
    
    for package in "${packages[@]}"; do
        # Check if already installed using V1 function if available
        local already_installed=false
        if declare -f "is_pacman_package_installed" >/dev/null 2>&1; then
            if is_pacman_package_installed "$package"; then
                already_installed=true
            fi
        else
            if pacman -Q "$package" >/dev/null 2>&1; then
                already_installed=true
            fi
        fi
        
        if [[ "$already_installed" == "true" ]]; then
            printf "${UI_COLORS[info]}  • ${UI_COLORS[dim]}$package (already installed)${UI_COLORS[reset]}\n"
            ((already_count++))
            continue
        fi
        
        show_progress "Installing $package" 50
        
        # Install using V1 logic if available, otherwise use V2
        local install_success=false
        if declare -f "install_pacman_package" >/dev/null 2>&1; then
            # Suppress V1 UI and capture result
            local old_confirm_yn
            if declare -f "confirm_yn" >/dev/null 2>&1; then
                old_confirm_yn=$(declare -f confirm_yn)
                # Override confirm_yn to always return true for batch install
                confirm_yn() { return 0; }
            fi
            
            # Redirect V1 output and capture result
            if install_pacman_package "$package" >/dev/null 2>&1; then
                install_success=true
            fi
            
            # Restore original confirm_yn if it existed
            if [[ -n "$old_confirm_yn" ]]; then
                eval "$old_confirm_yn"
            fi
        else
            # V2 fallback
            if sudo pacman -S --needed --noconfirm "$package" >/dev/null 2>&1; then
                install_success=true
            fi
        fi
        
        if [[ "$install_success" == "true" ]]; then
        printf "${UI_COLORS[success]}  ✓ ${UI_COLORS[info]}$package installed${UI_COLORS[reset]}\n"
            ((installed_count++))
        else
            printf "${UI_COLORS[error]}  ✗ ${UI_COLORS[info]}$package failed${UI_COLORS[reset]}\n"
        fi
    done
    
    show_progress "Installation completed" 100
    echo
    
    # Summary
    printf "${UI_COLORS[primary]}${UI_COLORS[bold]}Installation Summary:${UI_COLORS[reset]}\n"
    printf "${UI_COLORS[success]}  ✓ Installed: $installed_count${UI_COLORS[reset]}\n"
    if [[ $already_count -gt 0 ]]; then
        printf "${UI_COLORS[info]}  ℹ Already installed: $already_count${UI_COLORS[reset]}\n"
    fi
    if [[ $skipped_count -gt 0 ]]; then
        printf "${UI_COLORS[warning]}  ⚠ Skipped: $skipped_count${UI_COLORS[reset]}\n"
    fi
    
    if [[ $installed_count -gt 0 ]]; then
        show_notification "Successfully installed $installed_count packages" "success"
        log_info "PACKAGES" "V1 integration installed pacman packages: ${packages[*]}"
    fi
}

# Install AUR packages using V1 logic with V2 UI  
install_v1_aur_with_v2_ui() {
    local packages=("$@")
    
    # Check if AUR helper is available
    local aur_helper=""
    if command -v yay >/dev/null 2>&1; then
        aur_helper="yay"
    elif command -v paru >/dev/null 2>&1; then
        aur_helper="paru"
    else
        show_notification "No AUR helper found. Please install yay or paru first." "error"
        return 1
    fi
    
    show_progress "Installing AUR packages with $aur_helper" 30
    
    # Use V1 AUR functions if available, otherwise fallback to V2
    local install_success=false
    if declare -f "install_aur_packages" >/dev/null 2>&1; then
        # Use V1 function but suppress its UI
        if install_aur_packages "${packages[@]}" >/dev/null 2>&1; then
            install_success=true
        fi
    else
        # V2 fallback
        if "$aur_helper" -S --needed --noconfirm "${packages[@]}" >/dev/null 2>&1; then
            install_success=true
        fi
    fi
    
    show_progress "Installation completed" 100
    
    if [[ "$install_success" == "true" ]]; then
        show_notification "Successfully installed ${#packages[@]} AUR packages" "success"
        log_info "PACKAGES" "V1 integration installed AUR packages: ${packages[*]}"
    else
        show_notification "Some AUR packages failed to install" "error"
        return 1
    fi
}

# Enhanced V2 package management using V1 integration
manage_packages_v1_integrated() {
    # Initialize V1 integration
    if ! init_v1_integration; then
        log_warning "V1_INTEGRATION" "V1 integration failed, falling back to V2 only"
        handle_packages_v2
        return $?
    fi
    
    while true; do
        display_module_header "PACKAGE MANAGEMENT (V1 Enhanced)" "📦"
        
        printf "  📦 ${UI_COLORS[accent]}${UI_COLORS[bold]}[1]${UI_COLORS[reset]}  ${UI_COLORS[info]}Install Essential Packages${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Basic system packages (${#V1_PACMAN_PACKAGES[@]} available)${UI_COLORS[reset]}\n"
        echo
        
        printf "  🛠️  ${UI_COLORS[accent]}${UI_COLORS[bold]}[2]${UI_COLORS[reset]}  ${UI_COLORS[info]}Install Development Packages${UI_COLORS[reset]}\n" 
        printf "      ${UI_COLORS[dim]}Programming tools and libraries (${#V1_DEV_PACKAGES[@]} available)${UI_COLORS[reset]}\n"
        echo
        
        printf "  🎥 ${UI_COLORS[accent]}${UI_COLORS[bold]}[3]${UI_COLORS[reset]}  ${UI_COLORS[info]}Install Multimedia Packages${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Audio, video and graphics tools${UI_COLORS[reset]}\n"
        echo
        
        printf "  🏠 ${UI_COLORS[accent]}${UI_COLORS[bold]}[4]${UI_COLORS[reset]}  ${UI_COLORS[info]}Install AUR Packages${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Packages from Arch User Repository${UI_COLORS[reset]}\n"
        echo
        
        printf "  🔍 ${UI_COLORS[accent]}${UI_COLORS[bold]}[5]${UI_COLORS[reset]}  ${UI_COLORS[info]}Search Packages${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Search across all repositories${UI_COLORS[reset]}\n"
        echo
        
        printf "  ⬆️  ${UI_COLORS[accent]}${UI_COLORS[bold]}[6]${UI_COLORS[reset]}  ${UI_COLORS[info]}System Update${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Update all packages using V1 modules${UI_COLORS[reset]}\n"
        echo
        
        printf "  ${UI_ICONS[exit]} ${UI_COLORS[error]}${UI_COLORS[bold]}[0]${UI_COLORS[reset]}  ${UI_COLORS[info]}Return to Main Menu${UI_COLORS[reset]}\n"
        echo
        
        display_module_footer "Choose option [0-6]"
        
        local choice
        choice=$(read_single_key)
        echo "$choice"
        echo
        
        case "$choice" in
            1) install_v1_packages_with_ui "pacman" ;;
            2) install_v1_packages_with_ui "dev" ;;
            3) install_v1_packages_with_ui "multimedia" ;;
            4) install_v1_packages_with_ui "aur" ;;
            5) manage_package_search ;;
            6) update_system_v1_integrated ;;
            0) return 0 ;;
            *) show_notification "Invalid choice: $choice" "error"; sleep 1 ;;
        esac
    done
}

# System update using V1 modules
update_system_v1_integrated() {
    display_module_header "SYSTEM UPDATE (V1 Enhanced)" "⬆️"
    
    printf "${UI_COLORS[info]}This will update all packages using V1 module logic.${UI_COLORS[reset]}\n"
    echo
    
    if ui_confirm "Do you want to proceed with system update?"; then
        echo
        
        # Load V1 pacman module
        if load_v1_module "pacman.sh" "packages"; then
            show_progress "Updating package database" 25
            
            # Use V1 functions if available
            if declare -f "update_pacman_database" >/dev/null 2>&1; then
                if update_pacman_database >/dev/null 2>&1; then
                    show_progress "Package database updated" 50
                else
                    show_notification "Failed to update package database" "error"
                    wait_for_user
                    return 1
                fi
            else
                # V2 fallback
                if sudo pacman -Sy >/dev/null 2>&1; then
                    show_progress "Package database updated" 50
                else
                    show_notification "Failed to update package database" "error"
                    wait_for_user
                    return 1
                fi
            fi
            
            show_progress "Upgrading packages" 75
            
            # Upgrade packages
            if declare -f "upgrade_all_pacman_packages" >/dev/null 2>&1; then
                if upgrade_all_pacman_packages >/dev/null 2>&1; then
                    show_progress "System update completed" 100
                    show_notification "System updated successfully" "success"
                else
                    show_notification "System update failed" "error"
                fi
            else
                # V2 fallback
                if sudo pacman -Syu --noconfirm >/dev/null 2>&1; then
                    show_progress "System update completed" 100
                    show_notification "System updated successfully" "success"
                else
                    show_notification "System update failed" "error"
                fi
            fi
        else
            show_notification "V1 pacman module not available, using V2 fallback" "warning"
            # Direct V2 implementation
            show_progress "Updating system" 50
            if sudo pacman -Syu --noconfirm; then
                show_progress "System update completed" 100
                show_notification "System updated successfully" "success"
            else
                show_notification "System update failed" "error"
            fi
        fi
    else
        show_notification "System update cancelled" "info"
    fi
    
    echo
    wait_for_user
}

# Get V1 package list
get_v1_package_list() {
    local list_type="$1"
    local array_name="V1_${list_type^^}_PACKAGES"
    
    if declare -n package_array="$array_name" 2>/dev/null; then
        printf '%s\n' "${package_array[@]}"
        return 0
    else
        log_warning "V1_INTEGRATION" "Package list not found: $list_type"
        return 1
    fi
}

# Check if V1 module is loaded
is_v1_module_loaded() {
    local module_name="$1"
    [[ -n "${V1_LOADED_MODULES[$module_name]:-}" ]]
}

# Export V1 integration functions
export -f init_v1_integration load_v1_core_modules load_v1_package_lists
export -f load_v1_module install_v1_packages_with_ui
export -f install_v1_pacman_with_v2_ui install_v1_aur_with_v2_ui
export -f manage_packages_v1_integrated update_system_v1_integrated
export -f get_v1_package_list is_v1_module_loaded

# Initialize on load
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Script is being sourced, initialize automatically
    log_debug "V1_INTEGRATION" "V1 integration layer loaded"
fi
