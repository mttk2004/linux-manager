#!/bin/bash

# Kiet's Linux Manager Script
source ./config.sh
source ./install_packages.sh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Icons
ICON_PACKAGE="📦"
ICON_CONFIG="⚙️"
ICON_PHP="🐘"
ICON_NODE="🟢"
ICON_EXIT="🚪"

# Function to display the menu
display_menu() {
    clear
    echo -e "${BOLD}${BLUE}╔═══════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║       ${MAGENTA}K I E T ' S  L I N U X          ${BLUE}║${NC}"
    echo -e "${BOLD}${BLUE}║       ${CYAN}M A N A G E R  ${GREEN}v1.0             ${BLUE}║${NC}"
    echo -e "${BOLD}${BLUE}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}${ICON_PACKAGE} ${GREEN}1.${NC} ${BOLD}Install essential packages${NC}"
    echo -e "${YELLOW}${ICON_CONFIG}  ${GREEN}2.${NC} ${BOLD}Install configurations${NC}"
    echo -e "${YELLOW}${ICON_PHP} ${GREEN}3.${NC} ${BOLD}Manage PHP/Composer/Laravel${NC}"
    echo -e "${YELLOW}${ICON_NODE} ${GREEN}4.${NC} ${BOLD}Manage NVM/NodeJS/NPM${NC}"
    echo -e "${YELLOW}${ICON_EXIT} ${GREEN}5.${NC} ${BOLD}Exit${NC}"
    echo ""
    echo -e "${BLUE}═════════════════════════════════════════${NC}"
}

# Main function
main() {
    while true; do
        display_menu
        echo -ne "${CYAN}Enter your choice [1-5]:${NC} "
        read choice
        case $choice in
            1) echo -e "\n${GREEN}Loading package manager...${NC}"; sleep 1; install_packages ;;
            2) echo -e "\n${GREEN}Loading configuration manager...${NC}"; sleep 1; install_configurations ;;
            3) echo -e "\n${GREEN}Loading PHP tools...${NC}"; sleep 1; manage_php_composer_laravel ;;
            4) echo -e "\n${GREEN}Loading Node.js tools...${NC}"; sleep 1; manage_nvm_nodejs_npm ;;
            5) echo -e "\n${YELLOW}Thank you for using Kiet's Linux Manager!${NC}"; sleep 1; exit 0 ;;
            *) echo -e "\n${RED}Invalid choice. Please try again.${NC}"; sleep 1 ;;
        esac

        echo -e "\n${BOLD}${BLUE}Press Enter to return to the main menu...${NC}"
        read
    done
}

# Run the main function
main
