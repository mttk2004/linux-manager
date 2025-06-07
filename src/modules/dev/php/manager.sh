#!/bin/bash

# Module quản lý PHP/Composer/Laravel
# Tải utils từ core
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "${SCRIPT_DIR}/../../../core" && pwd)"
source "${CORE_DIR}/utils.sh"
source "${CORE_DIR}/ui.sh"

# Import các module chức năng
source "${SCRIPT_DIR}/build_php.sh"
source "${SCRIPT_DIR}/switch_php.sh"
source "${SCRIPT_DIR}/remove_php.sh"
source "${SCRIPT_DIR}/install_composer.sh"
source "${SCRIPT_DIR}/install_laravel.sh"

# Phiên bản PHP mặc định
DEFAULT_PHP_VERSION="8.2"

# Hiển thị menu PHP
display_php_menu() {
    clear
    echo -e "${LIGHT_CYAN}"
    echo "    ██████╗ ██╗  ██╗██████╗     ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗██████╗ "
    echo "    ██╔══██╗██║  ██║██╔══██╗    ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗"
    echo "    ██████╔╝███████║██████╔╝    ██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██████╔╝"
    echo "    ██╔═══╝ ██╔══██║██╔═══╝     ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██╔══██╗"
    echo "    ██║     ██║  ██║██║         ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██║  ██║"
    echo "    ╚═╝     ╚═╝  ╚═╝╚═╝         ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝"
    echo -e "${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_PHP} ${BOLD}PHP/COMPOSER/LARAVEL MANAGER${NC} ${ICON_PHP}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_SOURCE} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Build PHP từ source${NC}"
    echo -e "      ${GRAY}${DIM}Biên dịch và cài đặt PHP từ mã nguồn${NC}"
    echo

    echo -e "  ${ICON_SWITCH} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Chuyển phiên bản PHP${NC}"
    echo -e "      ${GRAY}${DIM}Chuyển đổi giữa các phiên bản PHP đã cài đặt${NC}"
    echo

    echo -e "  ${ICON_TRASH} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Xóa phiên bản PHP${NC}"
    echo -e "      ${GRAY}${DIM}Xóa các phiên bản PHP không sử dụng${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[4]${NC}  ${WHITE}Cài đặt Composer${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt trình quản lý gói cho PHP${NC}"
    echo

    echo -e "  ${ICON_PHP} ${GREEN}${BOLD}[5]${NC}  ${WHITE}Cài đặt Laravel${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt Laravel framework${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[6]${NC}  ${WHITE}Quay lại menu chính${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu chính${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-6${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
}

# Hàm chính để quản lý môi trường PHP
manage_php_environment() {
    local choice

    while true; do
        display_php_menu
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-6${DARK_GRAY}]${NC}: "
        read -n 1 choice
        echo

        case $choice in
            1)
                build_php_from_source
                ;;
            2)
                switch_php_version
                ;;
            3)
                remove_php_version
                ;;
            4)
                install_composer
                ;;
            5)
                install_laravel
                ;;
            6)
                return 0
                ;;
            *)
                print_boxed_message "Lựa chọn không hợp lệ. Vui lòng chọn số từ 1-6." "error"
                ;;
        esac

        # Đợi người dùng nhấn phím bất kỳ để tiếp tục
        echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Nhấn ${LIGHT_GREEN}${BOLD}phím bất kỳ${NC}${WHITE} để quay lại menu PHP..."
        read -n 1 -s
    done
}
