#!/bin/bash

# Module quản lý Node.js/NVM/NPM
# Xác định đường dẫn thư mục hiện tại
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "${SCRIPT_DIR}/../../../core" && pwd)"

# Tải utils từ core
source "${CORE_DIR}/utils.sh"
source "${CORE_DIR}/ui.sh"

# Tải các module con
source "${SCRIPT_DIR}/utils.sh"
source "${SCRIPT_DIR}/nvm_installer.sh"
source "${SCRIPT_DIR}/nodejs_installer.sh"
source "${SCRIPT_DIR}/npm_installer.sh"

# Hiển thị menu Node.js
display_nodejs_menu() {
    clear
    echo -e "${LIGHT_CYAN}"
    echo "    ███╗   ██╗ ██████╗ ██████╗ ███████╗     ██╗███████╗    ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗██████╗ "
    echo "    ████╗  ██║██╔═══██╗██╔══██╗██╔════╝     ██║██╔════╝    ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗"
    echo "    ██╔██╗ ██║██║   ██║██║  ██║█████╗       ██║███████╗    ██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██████╔╝"
    echo "    ██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██   ██║╚════██║    ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██╔══██╗"
    echo "    ██║ ╚████║╚██████╔╝██████╔╝███████╗╚█████╔╝███████║    ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██║  ██║"
    echo "    ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝ ╚════╝ ╚══════╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝"
    echo -e "${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_NODE} ${BOLD}NODE.JS/NVM/NPM MANAGER${NC} ${ICON_NODE}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_INFO} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Xem thông tin môi trường${NC}"
    echo -e "      ${GRAY}${DIM}Hiển thị thông tin Node.js, NVM, NPM${NC}"
    echo

    echo -e "  ${ICON_PACKAGE} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Cài đặt NVM${NC}"
    echo -e "      ${GRAY}${DIM}Node Version Manager${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Cài đặt Node.js${NC}"
    echo -e "      ${GRAY}${DIM}Thông qua NVM${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[4]${NC}  ${WHITE}Quản lý phiên bản Node.js${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt/chuyển đổi phiên bản${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[5]${NC}  ${WHITE}Cài đặt gói NPM toàn cục${NC}"
    echo -e "      ${GRAY}${DIM}Các công cụ phổ biến${NC}"
    echo

    echo -e "  ${ICON_LIST} ${GREEN}${BOLD}[6]${NC}  ${WHITE}Liệt kê gói NPM toàn cục${NC}"
    echo -e "      ${GRAY}${DIM}Xem các gói đã cài đặt${NC}"
    echo

    echo -e "  ${ICON_UPDATE} ${GREEN}${BOLD}[7]${NC}  ${WHITE}Cập nhật gói NPM toàn cục${NC}"
    echo -e "      ${GRAY}${DIM}Cập nhật tất cả các gói${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[8]${NC}  ${WHITE}Quay lại menu chính${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu chính${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-8${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
}

# Hàm chính để quản lý môi trường Node.js
manage_nodejs_environment() {
    local choice

    while true; do
        display_nodejs_menu
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-8${DARK_GRAY}]${NC}: "
        read -n 1 choice
        echo

        case $choice in
            1)
                show_nodejs_info
                ;;
            2)
                install_nvm
                ;;
            3)
                install_nodejs
                ;;
            4)
                manage_nodejs_versions
                ;;
            5)
                install_global_npm_packages
                ;;
            6)
                list_global_npm_packages
                ;;
            7)
                update_global_npm_packages
                ;;
            8)
                return 0
                ;;
            *)
                print_boxed_message "Lựa chọn không hợp lệ. Vui lòng chọn số từ 1-8." "error"
                ;;
        esac

        # Đợi người dùng nhấn phím bất kỳ để tiếp tục
        echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Nhấn ${LIGHT_GREEN}${BOLD}phím bất kỳ${NC}${WHITE} để quay lại menu Node.js..."
        read -n 1 -s
    done
}
