# Hiển thị trạng thái dịch vụ
show_service_status() {
    local service="$1"
    local status="$2"
    local color=""
    local icon=""

    case $status in
        "active")
            icon="${ICON_CHECK}"
            color="${GREEN}"
            ;;
        "inactive")
            icon="${ICON_WARNING}"
            color="${YELLOW}"
            ;;
        "failed")
            icon="${ICON_CROSS}"
            color="${LIGHT_RED}"
            ;;
        *)
            icon="${ICON_INFO}"
            color="${LIGHT_CYAN}"
            ;;
    esac

    echo -e "  ${color}${icon} ${WHITE}${service}${NC} ${GRAY}${DIM}(${color}${status}${GRAY})${NC}"
}

# Hiển thị menu quản lý dịch vụ
display_service_menu() {
    local service="$1"

    # Hiển thị header với style tối giản
    display_section_header "QUẢN LÝ DỊCH VỤ SYSTEMD" "${ICON_GEAR}"

    # Hiển thị thông tin dịch vụ
    echo -e "  ${YELLOW}Dịch vụ:${NC} ${WHITE}${BOLD}$service${NC}"
    echo -e "  ${YELLOW}Trạng thái:${NC} $(systemctl is-active "$service")"
    echo

    # Menu tùy chọn
    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Bật/tắt dịch vụ${NC}"
    echo -e "      ${GRAY}${DIM}Kích hoạt hoặc vô hiệu hóa dịch vụ${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Khởi động/dừng dịch vụ${NC}"
    echo -e "      ${GRAY}${DIM}Điều khiển trạng thái dịch vụ${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Xem nhật ký${NC}"
    echo -e "      ${GRAY}${DIM}Xem log của dịch vụ${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[4]${NC}  ${WHITE}Quay lại${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu trước${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-4${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
}
