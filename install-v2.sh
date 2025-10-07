#!/bin/bash

# Linux Manager V2 - Installation and Setup Script
# Installs and configures Linux Manager V2 with all dependencies
#
# @VERSION: 2.0.0
# @DESCRIPTION: Complete installation script for Linux Manager V2
# @AUTHOR: Linux Manager Team
# @LICENSE: MIT

# Installation metadata
readonly INSTALLER_VERSION="2.0.0"
readonly REQUIRED_BASH_VERSION="4.0"
readonly INSTALLATION_DIR="/opt/linux-manager"
readonly DESKTOP_FILE="/usr/share/applications/linux-manager.desktop"
readonly BINARY_LINK="/usr/local/bin/linux-manager"

# Color codes
if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly CYAN='\033[0;36m'
    readonly WHITE='\033[1;37m'
    readonly BOLD='\033[1m'
    readonly NC='\033[0m'
else
    readonly RED='' GREEN='' YELLOW='' BLUE='' CYAN='' WHITE='' BOLD='' NC=''
fi

# Installation state
INSTALL_LOCATION=""
INSTALL_AS_ROOT=false
CREATE_DESKTOP_ENTRY=true
CREATE_SYMLINKS=true
INSTALL_DEPENDENCIES=true

# Print installer header
print_installer_header() {
    clear
    cat << EOF

${CYAN}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}
${CYAN}${BOLD}║                                                              ║${NC}
${CYAN}${BOLD}║          🚀 ${WHITE}Linux Manager V2 Installer${CYAN}             ║${NC}
${CYAN}${BOLD}║                                                              ║${NC}
${CYAN}${BOLD}║              ${WHITE}Arch Linux System Manager${CYAN}                ║${NC}
${CYAN}${BOLD}║              ${WHITE}Advanced • Modern • Powerful${CYAN}             ║${NC}
${CYAN}${BOLD}║                                                              ║${NC}
${CYAN}${BOLD}║                   ${YELLOW}Version $INSTALLER_VERSION${CYAN}                   ║${NC}
${CYAN}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}

EOF
}

# Print status message
print_status() {
    local message="$1"
    local status="$2"  # loading, success, error, warning, info
    
    case "$status" in
        "loading")
            printf "${CYAN}[🔄] %s...${NC}\n" "$message"
            ;;
        "success")
            printf "${GREEN}[✅] %s${NC}\n" "$message"
            ;;
        "error")
            printf "${RED}[❌] %s${NC}\n" "$message"
            ;;
        "warning")
            printf "${YELLOW}[⚠️ ] %s${NC}\n" "$message"
            ;;
        *)
            printf "${BLUE}[ℹ️ ] %s${NC}\n" "$message"
            ;;
    esac
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        INSTALL_AS_ROOT=true
        INSTALL_LOCATION="$INSTALLATION_DIR"
        print_status "Running as root - system-wide installation" "info"
    else
        INSTALL_LOCATION="$HOME/.local/share/linux-manager"
        print_status "Running as user - user-local installation" "info"
    fi
}

# Check system requirements
check_requirements() {
    print_status "Checking system requirements" "loading"
    
    local issues=0
    
    # Check Bash version
    local bash_major="${BASH_VERSION%%.*}"
    local required_major="${REQUIRED_BASH_VERSION%%.*}"
    if [[ $bash_major -lt $required_major ]]; then
        print_status "Bash version $BASH_VERSION is too old (minimum: $REQUIRED_BASH_VERSION)" "error"
        ((issues++))
    fi
    
    # Check for Arch Linux
    if [[ ! -f "/etc/arch-release" ]] && [[ ! -f "/etc/manjaro-release" ]] && [[ ! -f "/etc/endeavouros-release" ]]; then
        print_status "System may not be fully supported (designed for Arch Linux)" "warning"
    fi
    
    # Check required commands
    local required_commands=("git" "curl" "make" "gcc" "sudo")
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            print_status "Required command not found: $cmd" "error"
            ((issues++))
        fi
    done
    
    # Check disk space (need at least 100MB)
    local available_space
    available_space=$(df "$(dirname "$INSTALL_LOCATION")" 2>/dev/null | awk 'NR==2 {print $4}' || echo 0)
    if [[ $available_space -lt 102400 ]]; then  # 100MB in KB
        print_status "Insufficient disk space (need at least 100MB)" "error"
        ((issues++))
    fi
    
    if [[ $issues -eq 0 ]]; then
        print_status "System requirements check passed" "success"
        return 0
    else
        print_status "System requirements check failed ($issues issues)" "error"
        return 1
    fi
}

# Install system dependencies
install_dependencies() {
    if [[ "$INSTALL_DEPENDENCIES" != "true" ]]; then
        return 0
    fi
    
    print_status "Installing system dependencies" "loading"
    
    # Update package database
    if command -v pacman >/dev/null 2>&1; then
        if [[ "$INSTALL_AS_ROOT" == "true" ]]; then
            pacman -Sy --noconfirm >/dev/null 2>&1
        else
            sudo pacman -Sy --noconfirm >/dev/null 2>&1
        fi
    fi
    
    # Install essential packages
    local packages=("curl" "git" "base-devel" "vim" "nano")
    local missing_packages=()
    
    for package in "${packages[@]}"; do
        if ! pacman -Qi "$package" >/dev/null 2>&1; then
            missing_packages+=("$package")
        fi
    done
    
    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        print_status "Installing missing packages: ${missing_packages[*]}" "info"
        
        if [[ "$INSTALL_AS_ROOT" == "true" ]]; then
            pacman -S --noconfirm "${missing_packages[@]}" >/dev/null 2>&1
        else
            sudo pacman -S --noconfirm "${missing_packages[@]}" >/dev/null 2>&1
        fi
        
        if [[ $? -eq 0 ]]; then
            print_status "Dependencies installed successfully" "success"
        else
            print_status "Failed to install some dependencies" "warning"
        fi
    else
        print_status "All dependencies already installed" "success"
    fi
}

# Create installation directories
create_directories() {
    print_status "Creating installation directories" "loading"
    
    local directories=(
        "$INSTALL_LOCATION"
        "$INSTALL_LOCATION/bin"
        "$INSTALL_LOCATION/src"
        "$INSTALL_LOCATION/data"
        "$INSTALL_LOCATION/logs"
        "$INSTALL_LOCATION/config"
        "$INSTALL_LOCATION/backup"
        "$INSTALL_LOCATION/.cache"
    )
    
    if [[ "$INSTALL_AS_ROOT" != "true" ]]; then
        directories+=(
            "$HOME/.config/linux-manager"
            "$HOME/.local/share/linux-manager/modules"
        )
    fi
    
    local created=0
    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            if mkdir -p "$dir" 2>/dev/null; then
                ((created++))
            else
                print_status "Failed to create directory: $dir" "error"
                return 1
            fi
        fi
    done
    
    print_status "Created $created directories" "success"
    return 0
}

# Copy application files
copy_files() {
    print_status "Copying application files" "loading"
    
    local current_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Copy main directories
    local copy_dirs=("src" "bin" "tests")
    for dir in "${copy_dirs[@]}"; do
        if [[ -d "$current_dir/$dir" ]]; then
            cp -r "$current_dir/$dir"/* "$INSTALL_LOCATION/$dir/" 2>/dev/null
        fi
    done
    
    # Copy data files
    if [[ -d "$current_dir/src/data" ]]; then
        cp -r "$current_dir/src/data"/* "$INSTALL_LOCATION/data/" 2>/dev/null
    fi
    
    # Copy important files
    local important_files=("README.md" "WARP.md" ".gitignore")
    for file in "${important_files[@]}"; do
        if [[ -f "$current_dir/$file" ]]; then
            cp "$current_dir/$file" "$INSTALL_LOCATION/" 2>/dev/null
        fi
    done
    
    # Make binaries executable
    chmod +x "$INSTALL_LOCATION/bin"/* 2>/dev/null
    
    print_status "Application files copied successfully" "success"
}

# Create symbolic links
create_symlinks() {
    if [[ "$CREATE_SYMLINKS" != "true" ]]; then
        return 0
    fi
    
    print_status "Creating symbolic links" "loading"
    
    if [[ "$INSTALL_AS_ROOT" == "true" ]]; then
        # System-wide symlinks
        ln -sf "$INSTALL_LOCATION/bin/linux-manager" "$BINARY_LINK" 2>/dev/null
        ln -sf "$INSTALL_LOCATION/bin/module-cli" "/usr/local/bin/module-cli" 2>/dev/null
        print_status "System-wide symlinks created" "success"
    else
        # User-local symlinks
        mkdir -p "$HOME/.local/bin" 2>/dev/null
        ln -sf "$INSTALL_LOCATION/bin/linux-manager" "$HOME/.local/bin/linux-manager" 2>/dev/null
        ln -sf "$INSTALL_LOCATION/bin/module-cli" "$HOME/.local/bin/module-cli" 2>/dev/null
        
        # Add to PATH if not already there
        local shell_rc=""
        if [[ "$SHELL" =~ bash ]]; then
            shell_rc="$HOME/.bashrc"
        elif [[ "$SHELL" =~ zsh ]]; then
            shell_rc="$HOME/.zshrc"
        elif [[ "$SHELL" =~ fish ]]; then
            shell_rc="$HOME/.config/fish/config.fish"
        fi
        
        if [[ -n "$shell_rc" && -f "$shell_rc" ]]; then
            if ! grep -q "$HOME/.local/bin" "$shell_rc" 2>/dev/null; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$shell_rc"
                print_status "Added ~/.local/bin to PATH in $shell_rc" "info"
            fi
        fi
        
        print_status "User-local symlinks created" "success"
    fi
}

# Create desktop entry
create_desktop_entry() {
    if [[ "$CREATE_DESKTOP_ENTRY" != "true" ]]; then
        return 0
    fi
    
    print_status "Creating desktop entry" "loading"
    
    local desktop_dir
    local icon_path
    
    if [[ "$INSTALL_AS_ROOT" == "true" ]]; then
        desktop_dir="/usr/share/applications"
        icon_path="$INSTALL_LOCATION/data/icons/linux-manager.png"
    else
        desktop_dir="$HOME/.local/share/applications"
        icon_path="$INSTALL_LOCATION/data/icons/linux-manager.png"
    fi
    
    mkdir -p "$desktop_dir" 2>/dev/null
    mkdir -p "$(dirname "$icon_path")" 2>/dev/null
    
    # Create a simple icon if it doesn't exist
    if [[ ! -f "$icon_path" ]]; then
        # Create placeholder icon (this would be a real icon in production)
        echo "# Linux Manager Icon Placeholder" > "${icon_path%.png}.txt"
        icon_path="applications-system"  # Use system icon
    fi
    
    # Create desktop file
    cat > "$desktop_dir/linux-manager.desktop" << EOF
[Desktop Entry]
Name=Linux Manager V2
Comment=Advanced Arch Linux system management tool
GenericName=System Manager
Exec=$INSTALL_LOCATION/bin/linux-manager
Icon=$icon_path
Terminal=true
Type=Application
Categories=System;Settings;PackageManager;
Keywords=arch;linux;system;packages;development;management;
StartupNotify=false
EOF
    
    # Update desktop database
    if command -v update-desktop-database >/dev/null 2>&1; then
        update-desktop-database "$desktop_dir" 2>/dev/null
    fi
    
    print_status "Desktop entry created" "success"
}

# Initialize V2 system
initialize_system() {
    print_status "Initializing Linux Manager V2 system" "loading"
    
    # Set environment variables
    export ROOT_DIR="$INSTALL_LOCATION"
    export CORE_V2_DIR="$INSTALL_LOCATION/src/core/v2"
    
    # Run system initialization if possible
    if [[ -f "$INSTALL_LOCATION/bin/linux-manager" ]]; then
        # Test run to ensure everything works
        if "$INSTALL_LOCATION/bin/linux-manager" --version >/dev/null 2>&1; then
            print_status "System initialization successful" "success"
        else
            print_status "System initialization completed with warnings" "warning"
        fi
    else
        print_status "System initialization skipped (binary not found)" "warning"
    fi
}

# Run post-installation steps
post_install() {
    print_status "Running post-installation steps" "loading"
    
    # Create initial configuration
    local config_file
    if [[ "$INSTALL_AS_ROOT" == "true" ]]; then
        config_file="/etc/linux-manager/config.conf"
        mkdir -p "$(dirname "$config_file")" 2>/dev/null
    else
        config_file="$HOME/.config/linux-manager/config.conf"
        mkdir -p "$(dirname "$config_file")" 2>/dev/null
    fi
    
    cat > "$config_file" << EOF
# Linux Manager V2 Configuration
# Generated on $(date)

# Core Settings
APP_VERSION=2.0.0
INSTALLATION_PATH=$INSTALL_LOCATION
INSTALLATION_TYPE=$(if [[ "$INSTALL_AS_ROOT" == "true" ]]; then echo "system"; else echo "user"; fi)

# UI Settings
UI_THEME=default
UI_ANIMATION_ENABLED=true
UI_LANGUAGE=vi

# Performance Settings
PERF_ENABLED=true
PERF_CACHE_ENABLED=true
CACHE_TTL=300

# Module Settings
MODULE_LAZY_LOADING=true
MODULE_HEALTH_MONITORING=true
EOF
    
    print_status "Configuration file created: $config_file" "success"
    
    # Set up logging
    local log_dir
    if [[ "$INSTALL_AS_ROOT" == "true" ]]; then
        log_dir="/var/log/linux-manager"
    else
        log_dir="$HOME/.local/share/linux-manager/logs"
    fi
    
    mkdir -p "$log_dir" 2>/dev/null
    touch "$log_dir/manager.log" 2>/dev/null
    
    print_status "Logging configured: $log_dir" "success"
}

# Show installation summary
show_summary() {
    echo
    printf "${GREEN}${BOLD}🎉 Linux Manager V2 Installation Complete! 🎉${NC}\n\n"
    
    printf "${CYAN}${BOLD}Installation Details:${NC}\n"
    printf "  Location: %s\n" "$INSTALL_LOCATION"
    printf "  Type: %s\n" "$(if [[ "$INSTALL_AS_ROOT" == "true" ]]; then echo "System-wide"; else echo "User-local"; fi)"
    printf "  Version: %s\n" "$INSTALLER_VERSION"
    
    echo
    printf "${CYAN}${BOLD}Available Commands:${NC}\n"
    
    if [[ "$INSTALL_AS_ROOT" == "true" ]]; then
        printf "  linux-manager          # Main application\n"
        printf "  module-cli             # Module management CLI\n"
    else
        printf "  ~/.local/bin/linux-manager    # Main application\n"
        printf "  ~/.local/bin/module-cli       # Module management CLI\n"
        echo
        printf "${YELLOW}Note: Make sure ~/.local/bin is in your PATH${NC}\n"
    fi
    
    echo
    printf "${CYAN}${BOLD}Quick Start:${NC}\n"
    printf "  1. Run: linux-manager\n"
    printf "  2. Or try: module-cli --help\n"
    printf "  3. Check status: module-cli health\n"
    
    echo
    printf "${CYAN}${BOLD}Configuration:${NC}\n"
    if [[ "$INSTALL_AS_ROOT" == "true" ]]; then
        printf "  Config: /etc/linux-manager/config.conf\n"
        printf "  Logs: /var/log/linux-manager/\n"
    else
        printf "  Config: ~/.config/linux-manager/config.conf\n"
        printf "  Logs: ~/.local/share/linux-manager/logs/\n"
    fi
    
    echo
    printf "${GREEN}Happy system management! 🚀${NC}\n"
    echo
}

# Interactive installation options
get_install_options() {
    echo
    printf "${WHITE}${BOLD}Installation Options:${NC}\n\n"
    
    # Ask about dependencies
    printf "${YELLOW}Install system dependencies? [Y/n]: ${NC}"
    read -r response
    case "${response,,}" in
        n|no|không) INSTALL_DEPENDENCIES=false ;;
        *) INSTALL_DEPENDENCIES=true ;;
    esac
    
    # Ask about desktop entry (only if not root)
    if [[ "$INSTALL_AS_ROOT" != "true" ]]; then
        printf "${YELLOW}Create desktop entry? [Y/n]: ${NC}"
        read -r response
        case "${response,,}" in
            n|no|không) CREATE_DESKTOP_ENTRY=false ;;
            *) CREATE_DESKTOP_ENTRY=true ;;
        esac
    fi
    
    # Ask about symlinks
    printf "${YELLOW}Create symbolic links for easy access? [Y/n]: ${NC}"
    read -r response
    case "${response,,}" in
        n|no|không) CREATE_SYMLINKS=false ;;
        *) CREATE_SYMLINKS=true ;;
    esac
    
    echo
}

# Main installation function
main() {
    print_installer_header
    
    # Check if running as root
    check_root
    
    # Get installation options
    get_install_options
    
    # Check requirements
    if ! check_requirements; then
        printf "\n${RED}Installation cannot proceed due to requirement failures.${NC}\n"
        printf "${YELLOW}Please fix the issues above and try again.${NC}\n"
        exit 1
    fi
    
    echo
    print_status "Starting Linux Manager V2 installation" "info"
    echo
    
    # Install dependencies
    if ! install_dependencies; then
        print_status "Dependency installation failed" "warning"
    fi
    
    # Create directories
    if ! create_directories; then
        printf "\n${RED}Failed to create installation directories.${NC}\n"
        exit 1
    fi
    
    # Copy files
    if ! copy_files; then
        print_status "File copy failed" "error"
        exit 1
    fi
    
    # Create symlinks
    create_symlinks
    
    # Create desktop entry
    create_desktop_entry
    
    # Initialize system
    initialize_system
    
    # Post-installation
    post_install
    
    # Show summary
    show_summary
}

# Handle command line arguments
case "${1:-}" in
    "--help"|"-h")
        echo "Linux Manager V2 Installer"
        echo "Usage: $0 [OPTIONS]"
        echo
        echo "Options:"
        echo "  --help, -h        Show this help message"
        echo "  --version         Show installer version"
        echo "  --unattended      Run unattended installation with defaults"
        echo
        exit 0
        ;;
    "--version")
        echo "Linux Manager V2 Installer v$INSTALLER_VERSION"
        exit 0
        ;;
    "--unattended")
        # Set defaults for unattended installation
        INSTALL_DEPENDENCIES=true
        CREATE_DESKTOP_ENTRY=true
        CREATE_SYMLINKS=true
        ;;
esac

# Run main installation
main "$@"
