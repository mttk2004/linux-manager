#!/bin/bash

# Kiet's Linux Manager Script
source ./config.sh
source ./install_packages.sh

# Enhanced Colors and Styles
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
DARK_GRAY='\033[1;30m'
LIGHT_BLUE='\033[1;34m'
LIGHT_GREEN='\033[1;32m'
LIGHT_RED='\033[1;31m'
LIGHT_YELLOW='\033[1;33m'
LIGHT_MAGENTA='\033[1;35m'
LIGHT_CYAN='\033[1;36m'
BOLD='\033[1m'
DIM='\033[2m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
REVERSE='\033[7m'
NC='\033[0m' # No Color

# Enhanced Icons and Symbols
ICON_PACKAGE="📦"
ICON_CONFIG="⚙️ "
ICON_PHP="🐘"
ICON_NODE="🟢"
ICON_EXIT="🚪"
ICON_ARROW="➤"
ICON_CHECK="✓"
ICON_CROSS="✗"
ICON_INFO="ℹ"
ICON_WARNING="⚠"
ICON_STAR="★"
ICON_GEAR="⚙"
ICON_ROCKET="🚀"

# Animation function
animate_text() {
    local text="$1"
    local delay="${2:-0.03}"
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo
}

# Function to print a fancy header
print_fancy_header() {
    clear
    echo -e "${LIGHT_CYAN}"
    echo "    ██╗  ██╗██╗███████╗████████╗███████╗    ██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗"
    echo "    ██║ ██╔╝██║██╔════╝╚══██╔══╝██╔════╝    ██║     ██║████╗  ██║██║   ██║╚██╗██╔╝"
    echo "    █████╔╝ ██║█████╗     ██║   ███████╗    ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝ "
    echo "    ██╔═██╗ ██║██╔══╝     ██║   ╚════██║    ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗ "
    echo "    ██║  ██╗██║███████╗   ██║   ███████║    ███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗"
    echo "    ╚═╝  ╚═╝╚═╝╚══════╝   ╚═╝   ╚══════╝    ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${DARK_GRAY}                           ═══════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}                                    ${ICON_ROCKET} ${BOLD}PROFESSIONAL SYSTEM MANAGER${NC} ${ICON_ROCKET}"
    echo -e "${LIGHT_MAGENTA}                                           ${BOLD}Version 2.0 Pro${NC}"
    echo -e "${DARK_GRAY}                           ═══════════════════════════════════════════════════════${NC}"
    echo
}

# Function to display the enhanced menu
display_menu() {
    print_fancy_header

    echo -e "${LIGHT_BLUE}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${LIGHT_BLUE}║                                  ${WHITE}${BOLD}MAIN MENU${NC}${LIGHT_BLUE}                                     ║${NC}"
    echo -e "${LIGHT_BLUE}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${LIGHT_BLUE}║                                                                                ║${NC}"
    echo -e "${LIGHT_BLUE}║  ${ICON_PACKAGE} ${GREEN}${BOLD}[1]${NC} ${WHITE}Install Essential Packages${NC}                ${GRAY}${DIM}System packages & AUR tools${NC}  ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║                                                                                ║${NC}"
    echo -e "${LIGHT_BLUE}║  ${ICON_CONFIG} ${GREEN}${BOLD}[2]${NC} ${WHITE}Install Configurations${NC}                           ${GRAY}${DIM}Setup system configs${NC}  ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║                                                                                ║${NC}"
    echo -e "${LIGHT_BLUE}║  ${ICON_PHP} ${GREEN}${BOLD}[3]${NC} ${WHITE}Manage PHP/Composer/Laravel${NC}                     ${GRAY}${DIM}Web development stack${NC}  ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║                                                                                ║${NC}"
    echo -e "${LIGHT_BLUE}║  ${ICON_NODE} ${GREEN}${BOLD}[4]${NC} ${WHITE}Manage NVM/NodeJS/NPM${NC}                          ${GRAY}${DIM}JavaScript runtime env${NC}  ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║                                                                                ║${NC}"
    echo -e "${LIGHT_BLUE}║  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[5]${NC} ${WHITE}Exit Application${NC}                                             ${GRAY}${DIM}Goodbye!${NC}  ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║                                                                                ║${NC}"
    echo -e "${LIGHT_BLUE}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${DARK_GRAY}               ┌──────────────────────────────────────────────────┐${NC}"
    echo -e "${DARK_GRAY}               │  ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Choose an option and press Enter to continue${NC}${DARK_GRAY}  │${NC}"
    echo -e "${DARK_GRAY}               └──────────────────────────────────────────────────┘${NC}"
    echo
}

# Function to show loading animation
show_loading() {
    local message="$1"
    local duration="${2:-2}"

    echo -e "${LIGHT_YELLOW}${ICON_GEAR} ${message}${NC}"

    # Spinning wheel animation
    local spinner=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local count=0
    local total_iterations=$((duration * 10))

    while [ $count -lt $total_iterations ]; do
        for i in "${spinner[@]}"; do
            echo -ne "\r${LIGHT_CYAN}${i} ${WHITE}Processing...${NC}"
            sleep 0.1
            ((count++))
            [ $count -ge $total_iterations ] && break
        done
    done
    echo -e "\r${GREEN}${ICON_CHECK} ${WHITE}Ready!${NC}                    "
    sleep 0.5
}

# Function to display success message
show_success() {
    echo -e "\n${GREEN}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ${ICON_CHECK} ${WHITE}${BOLD}SUCCESS!${NC} ${GREEN}Operation completed successfully!${NC}                             ${GREEN}║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
}

# Function to display error message
show_error() {
    local error_msg="$1"
    echo -e "\n${LIGHT_RED}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${LIGHT_RED}║  ${ICON_CROSS} ${WHITE}${BOLD}ERROR!${NC} ${LIGHT_RED}$error_msg${NC}                                                 ${LIGHT_RED}║${NC}"
    echo -e "${LIGHT_RED}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
}

# Function to display info message
show_info() {
    local info_msg="$1"
    echo -e "\n${LIGHT_BLUE}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${LIGHT_BLUE}║  ${ICON_INFO} ${WHITE}${BOLD}INFO:${NC} ${LIGHT_BLUE}$info_msg${NC}                                                  ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
}

# Function to get user input with style
get_user_choice() {
    echo -e "${LIGHT_CYAN}${ICON_ARROW}  ${WHITE}${BOLD}Enter your choice${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-5${DARK_GRAY}]${NC}: \c"
    read choice
    echo
}

# Function to wait for user input with style
wait_for_user() {
    echo -e "\n${DARK_GRAY}┌─────────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${DARK_GRAY}│  ${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Press ${LIGHT_GREEN}${BOLD}[ENTER]${NC}${WHITE} to return to the main menu...${NC}                           ${DARK_GRAY}│${NC}"
    echo -e "${DARK_GRAY}└─────────────────────────────────────────────────────────────────────────────────┘${NC}"
    read
}

# Function to show exit message
show_exit_message() {
    clear
    echo -e "${LIGHT_MAGENTA}"
    echo "    ████████╗██╗  ██╗ █████╗ ███╗   ██╗██╗  ██╗    ██╗   ██╗ ██████╗ ██╗   ██╗██╗"
    echo "    ╚══██╔══╝██║  ██║██╔══██╗████╗  ██║██║ ██╔╝    ╚██╗ ██╔╝██╔═══██╗██║   ██║██║"
    echo "       ██║   ███████║███████║██╔██╗ ██║█████╔╝      ╚████╔╝ ██║   ██║██║   ██║██║"
    echo "       ██║   ██╔══██║██╔══██║██║╚██╗██║██╔═██╗       ╚██╔╝  ██║   ██║██║   ██║╚═╝"
    echo "       ██║   ██║  ██║██║  ██║██║ ╚████║██║  ██╗       ██║   ╚██████╔╝╚██████╔╝██╗"
    echo "       ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝       ╚═╝    ╚═════╝  ╚═════╝ ╚═╝"
    echo -e "${NC}"
    echo -e "${LIGHT_BLUE}                          ═══════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}                               ${ICON_STAR} ${BOLD}Thank you for using Kiet's Linux Manager!${NC} ${ICON_STAR}"
    echo -e "${LIGHT_GREEN}                                    ${BOLD}Have a great day! 🌟${NC}"
    echo -e "${LIGHT_BLUE}                          ═══════════════════════════════════════════════════════${NC}"
    echo
    sleep 2
}

# Main function
main() {
    while true; do
        display_menu
        get_user_choice

        case $choice in
            1)
                show_loading "Initializing Package Manager" 1
                install_packages
                show_success
                ;;
            2)
                show_loading "Loading Configuration Manager" 1
                show_info "Configuration manager feature coming soon!"
                # install_configurations
                ;;
            3)
                show_loading "Setting up PHP Development Environment" 1
                show_info "PHP/Composer/Laravel manager feature coming soon!"
                # manage_php_composer_laravel
                ;;
            4)
                show_loading "Initializing Node.js Environment" 1
                show_info "NVM/NodeJS/NPM manager feature coming soon!"
                # manage_nvm_nodejs_npm
                ;;
            5)
                show_exit_message
                exit 0
                ;;
            *)
                show_error "Invalid choice. Please select a number between 1-5."
                sleep 2
                ;;
        esac

        wait_for_user
    done
}

# Run the main function
main
