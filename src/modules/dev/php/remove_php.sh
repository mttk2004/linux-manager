#!/bin/bash

# Chức năng xóa phiên bản PHP
# Tải utils từ core
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "${SCRIPT_DIR}/../../../core" && pwd)"
source "${CORE_DIR}/utils.sh"
source "${CORE_DIR}/ui.sh"

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
