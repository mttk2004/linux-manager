#!/bin/bash

# Chức năng chuyển phiên bản PHP
# Tải utils từ core
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "${SCRIPT_DIR}/../../../core" && pwd)"
source "${CORE_DIR}/utils.sh"
source "${CORE_DIR}/ui.sh"

# Chuyển phiên bản PHP
switch_php_version() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Chuyển phiên bản PHP...${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                ${ICON_SWITCH} ${BOLD}CHUYỂN PHIÊN BẢN PHP${NC} ${ICON_SWITCH}"
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

    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Chọn phiên bản PHP muốn sử dụng${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-${#php_versions[@]}${DARK_GRAY} hoặc ${LIGHT_RED}x${DARK_GRAY}]${NC}: "
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

    # Nếu đã là phiên bản hiện tại
    if [ "$selected_version" = "$current_version" ]; then
        print_boxed_message "PHP $selected_version đã là phiên bản đang sử dụng" "info"
        return 0
    fi

    # Thực hiện chuyển đổi phiên bản
    print_boxed_message "Đang chuyển sang PHP $selected_version" "info"

    # Di chuyển vào thư mục PHP
    cd "$HOME/.php" || {
        print_boxed_message "Không thể truy cập thư mục $HOME/.php" "error"
        return 1
    }

    # Cập nhật symlink
    echo -e "${WHITE}Cập nhật symlink: $HOME/.php/current -> $HOME/.php/php-$selected_version${NC}"
    ln -sfn "php-$selected_version" current || {
        print_boxed_message "Không thể cập nhật symlink" "error"
        return 1
    }

    # Hiển thị thông báo thành công
    print_boxed_message "Đã chuyển sang PHP $selected_version thành công" "success"
    echo -e "${WHITE}PHP $selected_version đã được kích hoạt tại: ${LIGHT_GREEN}$HOME/.php/current${NC}"

    # Kiểm tra phiên bản PHP
    if [ -x "$HOME/.php/current/bin/php" ]; then
        local new_version=$("$HOME/.php/current/bin/php" -r "echo PHP_VERSION;" 2>/dev/null)
        echo -e "${WHITE}Phiên bản PHP hiện tại: ${LIGHT_GREEN}$new_version${NC}"
    fi
    echo

    # Kiểm tra và cập nhật PATH nếu cần
    if ! grep -q "$HOME/.php/current/bin" "$HOME/.config/fish/config.fish" 2>/dev/null; then
        echo -e "${YELLOW}${ICON_WARNING} ${WHITE}Đường dẫn PHP chưa được thêm vào PATH${NC}"
        echo -e "${WHITE}Thêm dòng sau vào file ~/.config/fish/config.fish:${NC}"
        echo -e "${LIGHT_GREEN}set -gx PATH $HOME/.php/current/bin \$PATH${NC}"

        # Hỏi người dùng có muốn thêm vào không
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Thêm vào PATH ngay bây giờ?${NC} ${DARK_GRAY}[${LIGHT_GREEN}y${DARK_GRAY}/${LIGHT_RED}n${DARK_GRAY}]${NC}: "
        read -n 1 add_path
        echo

        if [[ "$add_path" =~ ^[yY]$ ]]; then
            # Đảm bảo thư mục cấu hình tồn tại
            mkdir -p "$HOME/.config/fish"

            # Thêm vào file cấu hình
            echo "" >> "$HOME/.config/fish/config.fish"
            echo "# PHP từ source" >> "$HOME/.config/fish/config.fish"
            echo "set -gx PATH $HOME/.php/current/bin \$PATH" >> "$HOME/.config/fish/config.fish"

            print_boxed_message "Đã thêm PHP vào PATH thành công" "success"
        fi
    fi

    # Nhắc nhở người dùng khởi động lại shell nếu cần
    echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Để áp dụng thay đổi ngay lập tức, hãy chạy:${NC}"
    echo -e "${LIGHT_GREEN}source ~/.config/fish/config.fish${NC}"
    echo

    # Trở lại thư mục ban đầu
    cd - > /dev/null
}
