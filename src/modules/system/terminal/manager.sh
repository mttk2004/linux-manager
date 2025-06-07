#!/bin/bash

# Module quản lý cấu hình terminal emulator

# Tải các module chức năng
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/wezterm.sh"
source "${SCRIPT_DIR}/ghostty.sh"
source "${SCRIPT_DIR}/alacritty.sh"

# Hiển thị menu cấu hình terminal emulator
display_terminal_menu() {
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_CONFIG} ${BOLD}LỰA CHỌN TERMINAL EMULATOR${NC} ${ICON_CONFIG}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[1]${NC}  ${WHITE}WezTerm${NC}"
    echo -e "      ${GRAY}${DIM}Terminal emulator hiện đại với lua${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Ghostty${NC}"
    echo -e "      ${GRAY}${DIM}Terminal emulator tối giản, nhanh${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Alacritty${NC}"
    echo -e "      ${GRAY}${DIM}Terminal emulator dùng GPU${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[4]${NC}  ${WHITE}Quay lại${NC}"
    echo -e "      ${GRAY}${DIM}Menu trước${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-4${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
}

# Hàm chính để cấu hình terminal emulator
configure_terminal() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Cấu hình Terminal Emulator...${NC}"

    # Hiển thị menu terminal
    display_terminal_menu

    # Lấy lựa chọn từ người dùng
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-4${DARK_GRAY}]${NC}: "
    read -n 1 terminal_choice
    echo

    case $terminal_choice in
        1)
            # Cấu hình WezTerm
            configure_wezterm
            ;;
        2)
            # Cấu hình Ghostty
            configure_ghostty
            ;;
        3)
            # Cấu hình Alacritty
            configure_alacritty
            ;;
        4)
            # Quay lại
            return 0
            ;;
        *)
            print_boxed_message "Lựa chọn không hợp lệ" "error"
            ;;
    esac

    return 0
}
