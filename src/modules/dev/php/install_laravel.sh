#!/bin/bash

# Chức năng cài đặt Laravel
# Tải utils từ core
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "${SCRIPT_DIR}/../../../core" && pwd)"
source "${CORE_DIR}/utils.sh"
source "${CORE_DIR}/ui.sh"

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
