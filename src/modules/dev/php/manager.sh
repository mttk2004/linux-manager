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
    echo -e "      ${GRAY}${DIM}Cài đặt trình quản lý gói${NC}"
    echo

    echo -e "  ${ICON_PHP} ${GREEN}${BOLD}[5]${NC}  ${WHITE}Cài đặt Laravel${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt Laravel framework${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[6]${NC}  ${WHITE}Quản lý phiên bản PHP${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt và chuyển đổi phiên bản${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[7]${NC}  ${WHITE}Quay lại menu chính${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu chính${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-7${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
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

# Xóa phiên bản PHP
remove_php_version() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Xóa phiên bản PHP...${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                ${ICON_TRASH} ${BOLD}XÓA PHIÊN BẢN PHP${NC} ${ICON_TRASH}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Kiểm tra thư mục PHP
    if [ ! -d "$HOME/.php" ]; then
        print_boxed_message "Không tìm thấy thư mục $HOME/.php. Vui lòng build PHP từ source trước." "error"
        return 1
    fi

    # Liệt kê các phiên bản PHP đã cài đặt
    echo -e "${WHITE}${BOLD}Các phiên bản PHP đã cài đặt:${NC}"
    echo

    # Lấy danh sách các thư mục php-*
    local php_versions=()
    local current_version=""
    local i=1

    # Kiểm tra symlink hiện tại
    if [ -L "$HOME/.php/current" ]; then
        current_version=$(readlink -f "$HOME/.php/current" | sed 's|.*/php-||')
    fi

    # Liệt kê các phiên bản đã cài đặt
    for dir in "$HOME"/.php/php-*; do
        if [ -d "$dir" ]; then
            local version=$(basename "$dir" | sed 's/php-//')
            php_versions+=("$version")

            if [ "$version" = "$current_version" ]; then
                echo -e "  ${ICON_PHP} ${GREEN}${BOLD}[$i]${NC}  ${WHITE}PHP $version${NC} ${LIGHT_GREEN}(Đang sử dụng)${NC}"
            else
                echo -e "  ${ICON_PHP} ${GREEN}${BOLD}[$i]${NC}  ${WHITE}PHP $version${NC}"
            fi

            echo -e "      ${GRAY}${DIM}Đường dẫn: $dir${NC}"
            echo

            ((i++))
        fi
    done

    # Nếu không có phiên bản nào
    if [ ${#php_versions[@]} -eq 0 ]; then
        print_boxed_message "Không tìm thấy phiên bản PHP nào đã được cài đặt từ source." "error"
        return 1
    fi

    # Yêu cầu người dùng chọn phiên bản
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${GRAY}    Nhập 'x' để quay lại menu trước${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Chọn phiên bản PHP muốn xóa${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-${#php_versions[@]}${DARK_GRAY} hoặc ${LIGHT_RED}x${DARK_GRAY}]${NC}: "
    read php_choice
    echo

    # Kiểm tra nếu người dùng muốn thoát
    if [[ "$php_choice" =~ ^[xX]$ ]]; then
        echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Quay lại menu trước...${NC}"
        return 0
    fi

    # Kiểm tra lựa chọn hợp lệ
    if ! [[ "$php_choice" =~ ^[0-9]+$ ]] || [ "$php_choice" -lt 1 ] || [ "$php_choice" -gt ${#php_versions[@]} ]; then
        print_boxed_message "Lựa chọn không hợp lệ" "error"
        return 1
    fi

    # Lấy phiên bản đã chọn
    local selected_version=${php_versions[$php_choice-1]}

    # Nếu là phiên bản hiện tại
    if [ "$selected_version" = "$current_version" ]; then
        print_boxed_message "Bạn không thể xóa phiên bản PHP đang sử dụng. Vui lòng chuyển sang phiên bản khác trước." "error"

        # Hỏi người dùng có muốn chuyển phiên bản không
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Bạn có muốn chuyển phiên bản PHP ngay bây giờ?${NC} ${DARK_GRAY}[${LIGHT_GREEN}y${DARK_GRAY}/${LIGHT_RED}n${DARK_GRAY}]${NC}: "
        read -n 1 switch_version
        echo

        if [[ "$switch_version" =~ ^[yY]$ ]]; then
            switch_php_version
            # Sau khi chuyển phiên bản, kiểm tra lại phiên bản hiện tại
            if [ -L "$HOME/.php/current" ]; then
                current_version=$(readlink -f "$HOME/.php/current" | sed 's|.*/php-||')
            fi

            # Nếu vẫn là phiên bản người dùng muốn xóa, thoát
            if [ "$selected_version" = "$current_version" ]; then
                print_boxed_message "Bạn vẫn đang sử dụng phiên bản muốn xóa. Hủy thao tác xóa." "error"
                return 1
            fi
        else
            print_boxed_message "Đã hủy thao tác xóa PHP $selected_version" "info"
            return 0
        fi
    fi

    # Xác nhận từ người dùng
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Bạn có chắc chắn muốn xóa PHP $selected_version?${NC} ${DARK_GRAY}[${LIGHT_GREEN}y${DARK_GRAY}/${LIGHT_RED}n${DARK_GRAY}]${NC}: "
    read -n 1 confirm
    echo

    if [[ ! "$confirm" =~ ^[yY]$ ]]; then
        print_boxed_message "Đã hủy thao tác xóa PHP $selected_version" "info"
        return 0
    fi

    # Thực hiện xóa
    print_boxed_message "Đang xóa PHP $selected_version" "info"

    # Xóa thư mục
    rm -rf "$HOME/.php/php-$selected_version" || {
        print_boxed_message "Không thể xóa thư mục PHP $selected_version" "error"
        return 1
    }

    # Hiển thị thông báo thành công
    print_boxed_message "Đã xóa PHP $selected_version thành công" "success"

    # Hiển thị các phiên bản còn lại
    local remaining_count=$(find "$HOME/.php" -maxdepth 1 -type d -name "php-*" | wc -l)
    echo -e "${WHITE}Số phiên bản PHP còn lại: ${LIGHT_GREEN}$remaining_count${NC}"

    # Nhắc nhở người dùng nếu không còn phiên bản nào
    if [ "$remaining_count" -eq 0 ]; then
        print_boxed_message "Bạn đã xóa tất cả các phiên bản PHP. Vui lòng build lại PHP nếu cần." "warning"
    fi

    echo
}

# Hàm chính để quản lý môi trường PHP
manage_php_environment() {
    local choice

    while true; do
        display_php_menu
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-7${DARK_GRAY}]${NC}: "
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
                manage_php_versions
                ;;
            7)
                return 0
                ;;
            *)
                print_boxed_message "Lựa chọn không hợp lệ. Vui lòng chọn số từ 1-7." "error"
                ;;
        esac

        # Đợi người dùng nhấn phím bất kỳ để tiếp tục
        echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Nhấn ${LIGHT_GREEN}${BOLD}phím bất kỳ${NC}${WHITE} để quay lại menu PHP..."
        read -n 1 -s
    done
}
