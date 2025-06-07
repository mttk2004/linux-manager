#!/bin/bash

# Chức năng cài đặt Composer
# Tải utils từ core
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "${SCRIPT_DIR}/../../../core" && pwd)"
source "${CORE_DIR}/utils.sh"
source "${CORE_DIR}/ui.sh"

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
