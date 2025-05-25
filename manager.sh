#!/bin/bash

# Kiet's Linux Manager Script
source ./config.sh
source ./install_packages.sh
source ./utils.sh  # Add source to utils.sh

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

# Function to show loading animation - moved to utils.sh
# Using the one from utils.sh instead

# Function to display success message - replaced with utils.sh version
# Using print_boxed_message from utils.sh instead

# Function to display error message - replaced with utils.sh version
# Using print_boxed_message from utils.sh instead

# Function to display info message - replaced with utils.sh version
# Using print_boxed_message from utils.sh instead

# Function to get user input with style - using read_single_key from utils.sh
get_user_choice() {
    # Display prompt manually
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Enter your choice${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-5${DARK_GRAY}]${NC}: "

    # Get ONLY the key without any prompt handling
    choice=$(read_single_key)

    # Echo the character for visual feedback
    echo "$choice"

    # Debug output to see what character was actually captured
    echo -e "\n${YELLOW}DEBUG: Captured choice: '$choice' (length: ${#choice}) (ascii codes: $(printf "%s" "$choice" | od -An -td1))${NC}"

    echo
}

# Function to wait for user input with style - enhanced with read_single_key from utils.sh
wait_for_user() {
    echo -e "\n${DARK_GRAY}┌─────────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${DARK_GRAY}│  ${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Press ${LIGHT_GREEN}${BOLD}any key${NC}${WHITE} to return to the main menu...${NC}                             ${DARK_GRAY}│${NC}"
    echo -e "${DARK_GRAY}└─────────────────────────────────────────────────────────────────────────────────┘${NC}"

    # Use read_single_key instead of read to avoid requiring Enter
    read_single_key > /dev/null
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
                show_spinner "Initializing Package Manager" 1
                install_packages
                print_boxed_message "Operation completed successfully!" "success"
                ;;
            2)
                show_spinner "Loading Configuration Manager" 1
                print_boxed_message "Configuration manager feature coming soon!" "info"
                # install_configurations
                ;;
            3)
                show_spinner "Setting up PHP Development Environment" 1
                print_boxed_message "PHP/Composer/Laravel manager feature coming soon!" "info"
                # manage_php_composer_laravel
                ;;
            4)
                show_spinner "Initializing Node.js Environment" 1
                print_boxed_message "NVM/NodeJS/NPM manager feature coming soon!" "info"
                # manage_nvm_nodejs_npm
                ;;
            5)
                show_exit_message
                exit 0
                ;;
            *)
                print_boxed_message "Invalid choice. Please select a number between 1-5." "error"
                sleep 2
                ;;
        esac

        wait_for_user
    done
}

# Run the main function
main
