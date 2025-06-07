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

# Cài đặt Composer
install_composer() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt Composer...${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                ${ICON_CONFIG} ${BOLD}CÀI ĐẶT COMPOSER${NC} ${ICON_CONFIG}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Kiểm tra xem Composer đã được cài đặt chưa
    if command -v composer &>/dev/null; then
        local current_version=$(composer --version | awk '{print $3}')
        print_boxed_message "Composer đã được cài đặt (phiên bản $current_version)" "info"

        # Hỏi người dùng có muốn cài đặt lại không
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Bạn có muốn cài đặt lại không?${NC} ${DARK_GRAY}[${LIGHT_GREEN}y${DARK_GRAY}/${LIGHT_RED}n${DARK_GRAY}]${NC}: "
        read -n 1 reinstall
        echo

        if [[ ! "$reinstall" =~ ^[yY]$ ]]; then
            print_boxed_message "Đã hủy cài đặt Composer" "info"
            return 0
        fi
    fi

    # Bước 1: Tạo thư mục chứa binary nếu chưa có
    print_boxed_message "1. Tạo thư mục .local/bin" "info"
    echo -e "${WHITE}Tạo thư mục $HOME/.local/bin để chứa Composer...${NC}"

    mkdir -p "$HOME/.local/bin" || {
        print_boxed_message "Không thể tạo thư mục $HOME/.local/bin" "error"
        return 1
    }

    # Bước 2: Download Composer
    print_boxed_message "2. Tải và cài đặt Composer" "info"
    echo -e "${WHITE}Đang tải Composer Installer...${NC}"

    # Kiểm tra xem PHP đã được cài đặt chưa
    if ! command -v php &>/dev/null; then
        # Kiểm tra PHP từ local
        if [ -x "$HOME/.php/current/bin/php" ]; then
            PHP_CMD="$HOME/.php/current/bin/php"
            echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Sử dụng PHP từ $PHP_CMD${NC}"
        else
            print_boxed_message "Không tìm thấy PHP. Vui lòng cài đặt PHP trước khi cài Composer." "error"
            return 1
        fi
    else
        PHP_CMD="php"
    fi

    # Tải installer
    $PHP_CMD -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" || {
        print_boxed_message "Không thể tải Composer Installer" "error"
        return 1
    }

    # Cài đặt Composer
    echo -e "${WHITE}Đang cài đặt Composer vào $HOME/.local/bin...${NC}"
    $PHP_CMD composer-setup.php --install-dir="$HOME/.local/bin" --filename=composer || {
        print_boxed_message "Không thể cài đặt Composer" "error"
        $PHP_CMD -r "unlink('composer-setup.php');"
        return 1
    }

    # Xóa installer
    $PHP_CMD -r "unlink('composer-setup.php');"

    # Bước 3: Thêm Composer vào PATH
    print_boxed_message "3. Cập nhật PATH" "info"

    # Kiểm tra xem đã có cấu hình PATH chưa
    if ! grep -q "$HOME/.local/bin" "$HOME/.config/fish/config.fish" 2>/dev/null; then
        echo -e "${WHITE}Thêm $HOME/.local/bin vào PATH trong ~/.config/fish/config.fish${NC}"

        # Đảm bảo thư mục cấu hình tồn tại
        mkdir -p "$HOME/.config/fish"

        # Thêm vào file cấu hình
        echo "" >> "$HOME/.config/fish/config.fish"
        echo "# Composer bin" >> "$HOME/.config/fish/config.fish"
        echo "set -gx PATH $HOME/.local/bin \$PATH" >> "$HOME/.config/fish/config.fish"

        print_boxed_message "Đã thêm Composer vào PATH thành công" "success"
    else
        echo -e "${WHITE}Đường dẫn $HOME/.local/bin đã có trong PATH${NC}"
    fi

    # Bước 4: Kiểm tra Composer
    print_boxed_message "4. Kiểm tra cài đặt" "info"
    echo -e "${WHITE}Kiểm tra phiên bản Composer...${NC}"

    if [ -x "$HOME/.local/bin/composer" ]; then
        local version=$("$HOME/.local/bin/composer" --version | awk '{print $3}')
        echo -e "${WHITE}Phiên bản Composer: ${LIGHT_GREEN}$version${NC}"

        # Hiển thị thông báo thành công
        print_boxed_message "Đã cài đặt Composer thành công" "success"
    else
        print_boxed_message "Cài đặt Composer thành công nhưng không thể thực thi. Kiểm tra lại quyền thực thi." "warning"
        return 1
    fi

    # Nhắc nhở người dùng khởi động lại shell
    echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Để áp dụng thay đổi ngay lập tức, hãy chạy:${NC}"
    echo -e "${LIGHT_GREEN}source ~/.config/fish/config.fish${NC}"
    echo
}

# Cài đặt Laravel
install_laravel() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt Laravel Installer...${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                ${ICON_PHP} ${BOLD}CÀI ĐẶT LARAVEL${NC} ${ICON_PHP}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Kiểm tra xem Laravel đã được cài đặt chưa
    if command -v laravel &>/dev/null; then
        local current_version=$(laravel --version | awk '{print $3}')
        print_boxed_message "Laravel Installer đã được cài đặt (phiên bản $current_version)" "info"

        # Hỏi người dùng có muốn cài đặt lại không
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Bạn có muốn cài đặt lại không?${NC} ${DARK_GRAY}[${LIGHT_GREEN}y${DARK_GRAY}/${LIGHT_RED}n${DARK_GRAY}]${NC}: "
        read -n 1 reinstall
        echo

        if [[ ! "$reinstall" =~ ^[yY]$ ]]; then
            print_boxed_message "Đã hủy cài đặt Laravel" "info"
            return 0
        fi
    fi

    # Bước 1: Kiểm tra Composer đã cài đặt chưa
    print_boxed_message "1. Kiểm tra cài đặt Composer" "info"

    # Kiểm tra Composer global hoặc local
    if command -v composer &>/dev/null; then
        COMPOSER_CMD="composer"
    elif [ -x "$HOME/.local/bin/composer" ]; then
        COMPOSER_CMD="$HOME/.local/bin/composer"
    else
        print_boxed_message "Không tìm thấy Composer. Vui lòng cài đặt Composer trước khi cài Laravel." "error"

        # Hỏi người dùng có muốn cài Composer ngay không
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Bạn có muốn cài đặt Composer ngay bây giờ?${NC} ${DARK_GRAY}[${LIGHT_GREEN}y${DARK_GRAY}/${LIGHT_RED}n${DARK_GRAY}]${NC}: "
        read -n 1 install_composer_now
        echo

        if [[ "$install_composer_now" =~ ^[yY]$ ]]; then
            install_composer
            # Kiểm tra lại sau khi cài đặt
            if [ -x "$HOME/.local/bin/composer" ]; then
                COMPOSER_CMD="$HOME/.local/bin/composer"
            else
                print_boxed_message "Không thể cài đặt Composer. Hủy cài đặt Laravel." "error"
                return 1
            fi
        else
            print_boxed_message "Đã hủy cài đặt Laravel" "info"
            return 0
        fi
    fi

    echo -e "${WHITE}Sử dụng Composer: ${LIGHT_GREEN}$COMPOSER_CMD${NC}"

    # Bước 2: Cài đặt Laravel Installer
    print_boxed_message "2. Cài đặt Laravel Installer" "info"
    echo -e "${WHITE}Cài đặt Laravel Installer thông qua Composer...${NC}"

    $COMPOSER_CMD global require laravel/installer || {
        print_boxed_message "Không thể cài đặt Laravel Installer" "error"
        return 1
    }

    # Bước 3: Thêm Composer global bin vào PATH
    print_boxed_message "3. Cập nhật PATH" "info"

    # Xác định đường dẫn Composer global bin
    COMPOSER_BIN="$HOME/.config/composer/vendor/bin"

    # Kiểm tra xem đã có cấu hình PATH chưa
    if ! grep -q "$COMPOSER_BIN" "$HOME/.config/fish/config.fish" 2>/dev/null; then
        echo -e "${WHITE}Thêm $COMPOSER_BIN vào PATH trong ~/.config/fish/config.fish${NC}"

        # Đảm bảo thư mục cấu hình tồn tại
        mkdir -p "$HOME/.config/fish"

        # Thêm vào file cấu hình
        echo "" >> "$HOME/.config/fish/config.fish"
        echo "# Laravel Installer (Composer global)" >> "$HOME/.config/fish/config.fish"
        echo "set -gx PATH $COMPOSER_BIN \$PATH" >> "$HOME/.config/fish/config.fish"

        print_boxed_message "Đã thêm Laravel vào PATH thành công" "success"
    else
        echo -e "${WHITE}Đường dẫn $COMPOSER_BIN đã có trong PATH${NC}"
    fi

    # Bước 4: Kiểm tra Laravel
    print_boxed_message "4. Kiểm tra cài đặt" "info"
    echo -e "${WHITE}Kiểm tra phiên bản Laravel Installer...${NC}"

    if [ -x "$COMPOSER_BIN/laravel" ]; then
        local version=$("$COMPOSER_BIN/laravel" --version | awk '{print $3}')
        echo -e "${WHITE}Phiên bản Laravel Installer: ${LIGHT_GREEN}$version${NC}"

        # Hiển thị thông báo thành công
        print_boxed_message "Đã cài đặt Laravel Installer thành công" "success"
    else
        print_boxed_message "Cài đặt Laravel thành công nhưng không thể thực thi. Kiểm tra lại PATH." "warning"
    fi

    # Hiển thị tổng kết cấu hình PATH
    print_boxed_message "5. Tổng kết cấu hình PATH" "info"
    echo -e "${WHITE}Cấu hình PATH hoàn chỉnh cho Fish shell:${NC}"
    echo -e "${GRAY}set -gx PATH $HOME/.php/current/bin $HOME/.local/bin $COMPOSER_BIN \$PATH${NC}"

    # Nhắc nhở người dùng khởi động lại shell
    echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Để áp dụng thay đổi ngay lập tức, hãy chạy:${NC}"
    echo -e "${LIGHT_GREEN}source ~/.config/fish/config.fish${NC}"
    echo

    # Hiển thị hướng dẫn sử dụng
    echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Tạo dự án Laravel mới:${NC}"
    echo -e "${LIGHT_GREEN}laravel new my-project${NC}"
    echo
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
