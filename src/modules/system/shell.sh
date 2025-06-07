# Hiển thị trạng thái shell
show_shell_status() {
    local shell="$1"
    local status="$2"
    local color=""
    local icon=""

    case $status in
        "current")
            icon="${ICON_CHECK}"
            color="${GREEN}"
            ;;
        "installed")
            icon="${ICON_INFO}"
            color="${BLUE}"
            ;;
        "not-installed")
            icon="${ICON_WARNING}"
            color="${YELLOW}"
            ;;
        "failed")
            icon="${ICON_CROSS}"
            color="${LIGHT_RED}"
            ;;
    esac

    echo -e "  ${color}${icon} ${WHITE}${shell}${NC} ${GRAY}${DIM}(${color}${status}${GRAY})${NC}"
}

# Hiển thị menu cấu hình shell
display_shell_menu() {
    # Hiển thị header với style tối giản
    display_section_header "CẤU HÌNH SHELL" "${ICON_GEAR}"

    # Hiển thị thông tin shell hiện tại
    echo -e "  ${YELLOW}Shell hiện tại:${NC} ${WHITE}${BOLD}$SHELL${NC}"
    echo -e "  ${YELLOW}Người dùng:${NC} ${LIGHT_CYAN}$USER${NC}"
    echo

    # Menu tùy chọn
    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Bash${NC}"
    echo -e "      ${GRAY}${DIM}Shell mặc định${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Zsh${NC}"
    echo -e "      ${GRAY}${DIM}Shell mở rộng với Oh My Zsh${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Fish${NC}"
    echo -e "      ${GRAY}${DIM}Shell thân thiện với người dùng${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[4]${NC}  ${WHITE}Quay lại${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu trước${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-4${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
}

# Xác nhận thay đổi shell
confirm_change_shell() {
    local new_shell="$1"
    local current_shell="$SHELL"

    # Hiển thị header với style tối giản
    display_section_header "THAY ĐỔI SHELL" "${ICON_GEAR}"

    # Hiển thị thông tin
    echo -e "  ${YELLOW}Shell hiện tại:${NC} ${WHITE}${BOLD}$current_shell${NC}"
    echo -e "  ${YELLOW}Shell mới:${NC} ${LIGHT_CYAN}$new_shell${NC}"
    echo

    # Yêu cầu xác nhận
    if confirm_yn "Bạn có muốn đổi shell mặc định sang ${BOLD}$new_shell${NC}${WHITE} không?" "n"; then
        return 0
    else
        return 1
    fi
}

# Hiển thị menu cấu hình shell tùy chỉnh
display_shell_config_menu() {
    local shell="$1"

    # Hiển thị header với style tối giản
    display_section_header "CẤU HÌNH $shell" "${ICON_GEAR}"

    # Menu tùy chọn
    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Sao chép cấu hình mẫu${NC}"
    echo -e "      ${GRAY}${DIM}Sử dụng cấu hình có sẵn${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Tùy chỉnh cấu hình${NC}"
    echo -e "      ${GRAY}${DIM}Chỉnh sửa cấu hình thủ công${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[3]${NC}  ${WHITE}Quay lại${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu trước${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-3${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
}
