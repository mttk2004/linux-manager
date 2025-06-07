#!/bin/bash

# Module quản lý PHP/Composer/Laravel
# Tải utils từ core
source "../../../core/utils.sh"
source "../../../core/ui.sh"

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
    echo -e "  ${ICON_PACKAGE} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Cài đặt PHP${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt PHP và các extension${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Cài đặt Composer${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt trình quản lý gói${NC}"
    echo

    echo -e "  ${ICON_PHP} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Cài đặt Laravel${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt Laravel framework${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[4]${NC}  ${WHITE}Quản lý phiên bản PHP${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt và chuyển đổi phiên bản${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[5]${NC}  ${WHITE}Quay lại menu chính${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu chính${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-5${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
}

# Cài đặt PHP
install_php() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt PHP $DEFAULT_PHP_VERSION...${NC}"

    show_spinner "Chuẩn bị cài đặt PHP" 1

    # Kiểm tra xem PHP đã được cài đặt chưa
    if command -v php &>/dev/null; then
        local current_version=$(php -r "echo PHP_VERSION;")
        print_boxed_message "PHP đã được cài đặt (phiên bản $current_version)" "info"
    else
        # Mô phỏng cài đặt
        print_boxed_message "Đang cài đặt PHP $DEFAULT_PHP_VERSION và các extension phổ biến" "info"
        show_spinner "Cài đặt PHP" 2

        # Hiển thị thông báo thành công
        print_boxed_message "Đã cài đặt PHP $DEFAULT_PHP_VERSION thành công" "success"
    fi
}

# Cài đặt Composer
install_composer() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt Composer...${NC}"

    show_spinner "Chuẩn bị cài đặt Composer" 1

    # Kiểm tra xem Composer đã được cài đặt chưa
    if command -v composer &>/dev/null; then
        local current_version=$(composer --version | awk '{print $3}')
        print_boxed_message "Composer đã được cài đặt (phiên bản $current_version)" "info"
    else
        # Mô phỏng cài đặt
        print_boxed_message "Đang cài đặt Composer - Trình quản lý gói cho PHP" "info"
        show_spinner "Cài đặt Composer" 2

        # Hiển thị thông báo thành công
        print_boxed_message "Đã cài đặt Composer thành công" "success"
    fi
}

# Cài đặt Laravel
install_laravel() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt Laravel Installer...${NC}"

    show_spinner "Chuẩn bị cài đặt Laravel" 1

    # Kiểm tra xem Laravel đã được cài đặt chưa
    if command -v laravel &>/dev/null; then
        local current_version=$(laravel --version | awk '{print $3}')
        print_boxed_message "Laravel Installer đã được cài đặt (phiên bản $current_version)" "info"
    else
        # Kiểm tra xem Composer đã được cài đặt chưa
        if ! command -v composer &>/dev/null; then
            print_boxed_message "Composer chưa được cài đặt. Vui lòng cài đặt Composer trước." "error"
            return 1
        fi

        # Mô phỏng cài đặt
        print_boxed_message "Đang cài đặt Laravel Installer thông qua Composer" "info"
        show_spinner "Cài đặt Laravel" 2

        # Hiển thị thông báo thành công
        print_boxed_message "Đã cài đặt Laravel Installer thành công" "success"
    fi
}

# Quản lý phiên bản PHP
manage_php_versions() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Quản lý phiên bản PHP...${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_PHP} ${BOLD}QUẢN LÝ PHIÊN BẢN PHP${NC} ${ICON_PHP}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_PHP} ${GREEN}${BOLD}[1]${NC}  ${WHITE}PHP 8.2${NC} ${LIGHT_GREEN}(Khuyến nghị)${NC}"
    echo -e "      ${GRAY}${DIM}Phiên bản ổn định mới nhất${NC}"
    echo

    echo -e "  ${ICON_PHP} ${GREEN}${BOLD}[2]${NC}  ${WHITE}PHP 8.1${NC}"
    echo -e "      ${GRAY}${DIM}Phiên bản LTS${NC}"
    echo

    echo -e "  ${ICON_PHP} ${GREEN}${BOLD}[3]${NC}  ${WHITE}PHP 7.4${NC} ${YELLOW}(Legacy)${NC}"
    echo -e "      ${GRAY}${DIM}Phiên bản cũ hơn${NC}"
    echo

    echo -e "  ${ICON_PHP} ${GREEN}${BOLD}[4]${NC}  ${WHITE}PHP 8.3${NC} ${MAGENTA}(Beta)${NC}"
    echo -e "      ${GRAY}${DIM}Phiên bản thử nghiệm${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Yêu cầu người dùng chọn phiên bản
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Chọn phiên bản PHP${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-4${DARK_GRAY}]${NC}: "
    read -n 1 php_choice
    echo

    # Xử lý lựa chọn
    case $php_choice in
        1)
            version="8.2"
            ;;
        2)
            version="8.1"
            ;;
        3)
            version="7.4"
            ;;
        4)
            version="8.3"
            ;;
        *)
            print_boxed_message "Lựa chọn không hợp lệ" "error"
            return 1
            ;;
    esac

    # Mô phỏng cài đặt và chuyển đổi
    print_boxed_message "Đang cài đặt và chuyển đổi sang PHP $version" "info"
    show_spinner "Cài đặt PHP $version" 2

    # Hiển thị thông báo thành công
    print_boxed_message "Đã chuyển đổi sang PHP $version thành công" "success"
}

# Hàm chính để quản lý môi trường PHP
manage_php_environment() {
    local choice

    while true; do
        display_php_menu
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-5${DARK_GRAY}]${NC}: "
        read -n 1 choice
        echo

        case $choice in
            1)
                install_php
                ;;
            2)
                install_composer
                ;;
            3)
                install_laravel
                ;;
            4)
                manage_php_versions
                ;;
            5)
                return 0
                ;;
            *)
                print_boxed_message "Lựa chọn không hợp lệ. Vui lòng chọn số từ 1-5." "error"
                sleep 2
                ;;
        esac

        # Đợi người dùng nhấn phím bất kỳ để tiếp tục
        echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Nhấn ${LIGHT_GREEN}${BOLD}phím bất kỳ${NC}${WHITE} để quay lại menu PHP..."
        read -n 1 -s
    done
}
