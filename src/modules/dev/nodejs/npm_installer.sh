#!/bin/bash

# Xác định đường dẫn thư mục hiện tại
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "${SCRIPT_DIR}/../../../core" && pwd)"

# Tải các module cần thiết
source "${SCRIPT_DIR}/utils.sh"
source "${CORE_DIR}/utils.sh"
source "${CORE_DIR}/ui.sh"

# Cài đặt các gói NPM toàn cục
install_global_npm_packages() {
    # Kiểm tra xem NVM đã được cài đặt chưa
    if ! check_nvm_installed; then
        print_boxed_message "NVM chưa được cài đặt. Vui lòng cài đặt NVM trước." "error"
        return 1
    fi

    # Kiểm tra xem Node.js đã được cài đặt chưa
    if ! check_nodejs_installed; then
        print_boxed_message "Node.js chưa được cài đặt. Vui lòng cài đặt Node.js trước." "error"
        return 1
    fi

    # Danh sách các gói NPM phổ biến
    local npm_packages=(
        "typescript"
        "nodemon"
        "pm2"
        "eslint"
        "prettier"
        "create-react-app"
        "@vue/cli"
        "@angular/cli"
        "next"
        "sass"
        "gulp"
        "webpack"
        "yarn"
        "pnpm"
        "http-server"
        "ts-node"
        "rimraf"
        "npm-check-updates"
    )

    # Hiển thị danh sách các gói NPM
    display_section_header "CÁC GÓI NPM TOÀN CỤC" "${ICON_NODE}"
    echo -e "  ${YELLOW}Tổng số:${NC} ${WHITE}${BOLD}${#npm_packages[@]}${NC} ${GRAY}${DIM}gói${NC}"
    echo

    for i in "${!npm_packages[@]}"; do
        local package="${npm_packages[$i]}"
        local number=$((i + 1))
        echo -e "  ${GREEN}${BOLD}[$number]${NC} ${WHITE}$package${NC}"
    done

    echo -e "\n  ${GREEN}${BOLD}[0]${NC} ${WHITE}Cài đặt tất cả${NC}"
    echo -e "  ${GREEN}${BOLD}[C]${NC} ${WHITE}Cài đặt gói tùy chỉnh${NC}"
    echo

    # Yêu cầu người dùng chọn gói
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Chọn gói NPM để cài đặt${NC} ${DARK_GRAY}[${LIGHT_GREEN}0-${#npm_packages[@]} hoặc C${DARK_GRAY}]${NC}: "
    read npm_choice
    echo

    # Xử lý lựa chọn
    if [[ "$npm_choice" =~ ^[0-9]+$ ]]; then
        if [ "$npm_choice" -eq 0 ]; then
            # Cài đặt tất cả các gói
            print_boxed_message "Đang cài đặt tất cả các gói NPM toàn cục" "info"
            show_spinner "Chuẩn bị cài đặt các gói NPM" 1

            for package in "${npm_packages[@]}"; do
                print_boxed_message "Đang cài đặt $package..." "info"
                install_npm_package "$package"
            done

            print_boxed_message "Đã cài đặt tất cả các gói NPM toàn cục thành công" "success"
        elif [ "$npm_choice" -le "${#npm_packages[@]}" ]; then
            # Cài đặt gói được chọn
            local selected_package="${npm_packages[$((npm_choice - 1))]}"
            print_boxed_message "Đang cài đặt gói NPM: $selected_package" "info"
            show_spinner "Chuẩn bị cài đặt $selected_package" 1
            install_npm_package "$selected_package"
        else
            print_boxed_message "Lựa chọn không hợp lệ" "error"
            return 1
        fi
    elif [[ "$npm_choice" =~ ^[Cc]$ ]]; then
        # Cài đặt gói tùy chỉnh
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập tên gói NPM muốn cài đặt${NC}: "
        read custom_package

        if [ -z "$custom_package" ]; then
            print_boxed_message "Tên gói không được để trống" "error"
            return 1
        fi

        print_boxed_message "Đang cài đặt gói NPM: $custom_package" "info"
        show_spinner "Chuẩn bị cài đặt $custom_package" 1
        install_npm_package "$custom_package"
    else
        print_boxed_message "Lựa chọn không hợp lệ" "error"
        return 1
    fi

    return 0
}

# Hàm trợ giúp cài đặt một gói NPM cụ thể
install_npm_package() {
    local package="$1"

    if is_fish_shell; then
        run_with_fish "npm install -g $package"
    else
        run_with_bash "npm install -g $package"
    fi

    if [ $? -eq 0 ]; then
        print_boxed_message "Đã cài đặt $package thành công" "success"
    else
        print_boxed_message "Không thể cài đặt $package" "error"
    fi
}

# Liệt kê các gói NPM đã cài đặt toàn cục
list_global_npm_packages() {
    # Kiểm tra xem Node.js đã được cài đặt chưa
    if ! check_nodejs_installed; then
        print_boxed_message "Node.js chưa được cài đặt. Vui lòng cài đặt Node.js trước." "error"
        return 1
    fi

    print_boxed_message "Đang liệt kê các gói NPM đã cài đặt toàn cục" "info"

    if is_fish_shell; then
        run_with_fish "npm list -g --depth=0"
    else
        run_with_bash "npm list -g --depth=0"
    fi

    echo
    print_boxed_message "Đã liệt kê các gói NPM đã cài đặt toàn cục" "success"

    return 0
}

# Cập nhật các gói NPM toàn cục
update_global_npm_packages() {
    # Kiểm tra xem Node.js đã được cài đặt chưa
    if ! check_nodejs_installed; then
        print_boxed_message "Node.js chưa được cài đặt. Vui lòng cài đặt Node.js trước." "error"
        return 1
    fi

    print_boxed_message "Đang cập nhật các gói NPM toàn cục" "info"

    if is_fish_shell; then
        run_with_fish "npm update -g"
    else
        run_with_bash "npm update -g"
    fi

    if [ $? -eq 0 ]; then
        print_boxed_message "Đã cập nhật các gói NPM toàn cục thành công" "success"
    else
        print_boxed_message "Không thể cập nhật các gói NPM toàn cục" "error"
    fi

    return 0
}
