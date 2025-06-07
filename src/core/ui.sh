#!/bin/bash

# UI Core Module - Chứa các thành phần giao diện người dùng

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
    echo -e "${LIGHT_MAGENTA}                                           ${BOLD}Version 2.1 Pro${NC}"
    echo -e "${DARK_GRAY}                           ═══════════════════════════════════════════════════════${NC}"
    echo
}

# Function to display the enhanced menu
display_menu() {
    print_fancy_header

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_ROCKET} ${BOLD}MENU CHÍNH${NC} ${ICON_ROCKET}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_PACKAGE} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Cài đặt gói phần mềm thiết yếu${NC}"
    echo -e "      ${GRAY}${DIM}Gói hệ thống & AUR${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Cài đặt cấu hình${NC}"
    echo -e "      ${GRAY}${DIM}Thiết lập hệ thống${NC}"
    echo

    echo -e "  ${ICON_PHP} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Quản lý PHP/Composer/Laravel${NC}"
    echo -e "      ${GRAY}${DIM}Môi trường web development${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[4]${NC}  ${WHITE}Quản lý NVM/NodeJS/NPM${NC}"
    echo -e "      ${GRAY}${DIM}JavaScript runtime environment${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[5]${NC}  ${WHITE}Thoát ứng dụng${NC}"
    echo -e "      ${GRAY}${DIM}Tạm biệt!${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-5${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
}

# Function to get user input with style - using read_single_key from utils.sh
get_user_choice() {
    # Display prompt manually
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-5${DARK_GRAY}]${NC}: "

    # Get ONLY the key without any prompt handling
    choice=$(read_single_key)

    # Echo the character for visual feedback
    echo "$choice"
    echo

    return 0
}

# Function to wait for user input with style
wait_for_user() {
    echo -e "\n${DARK_GRAY}┌─────────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${DARK_GRAY}│  ${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Nhấn ${LIGHT_GREEN}${BOLD}phím bất kỳ${NC}${WHITE} để quay lại menu chính...${NC}                             ${DARK_GRAY}│${NC}"
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
    echo -e "${WHITE}                               ${ICON_STAR} ${BOLD}Cảm ơn bạn đã sử dụng Kiet's Linux Manager!${NC} ${ICON_STAR}"
    echo -e "${LIGHT_GREEN}                                    ${BOLD}Chúc một ngày tốt lành! 🌟${NC}"
    echo -e "${LIGHT_BLUE}                          ═══════════════════════════════════════════════════════${NC}"
    echo
    sleep 2
}
