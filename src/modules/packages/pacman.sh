#!/bin/bash

# Module quản lý gói Pacman
# Được sử dụng để cài đặt và quản lý các gói từ kho chính thức của Arch Linux

# Kiểm tra xem một gói đã được cài đặt chưa
is_pacman_package_installed() {
    local package="$1"

    # Sử dụng pacman -Qi để kiểm tra
    if pacman -Qi "$package" &> /dev/null; then
        return 0 # Gói đã được cài đặt
    else
        return 1 # Gói chưa được cài đặt
    fi
}

# Yêu cầu xác nhận cài đặt gói
ask_install_pacman() {
    local package="$1"
    local description="$2"

    # Nếu không có mô tả, sử dụng tên gói
    if [ -z "$description" ]; then
        description="$package"
    fi

    # Hiển thị header với style tối giản
    display_section_header "CÀI ĐẶT GÓI PACMAN" "${ICON_PACKAGE}"

    # Hiển thị thông tin gói
    echo -e "  ${YELLOW}Gói:${NC} ${WHITE}${BOLD}$package${NC}"
    echo -e "  ${YELLOW}Mô tả:${NC} ${LIGHT_CYAN}$description${NC}"
    echo -e "  ${YELLOW}Nguồn:${NC} ${LIGHT_CYAN}Arch Linux Repository${NC}"
    echo

    # Sử dụng hàm confirm_yn từ utils.sh với style mới
    if confirm_yn "Bạn có muốn cài đặt ${BOLD}$package${NC}${WHITE} không?" "y"; then
        return 0 # Người dùng chọn có
    else
        return 1 # Người dùng chọn không
    fi
}

# Hiển thị trạng thái cài đặt gói
show_package_status() {
    local package="$1"
    local status="$2"
    local color=""
    local icon=""

    case $status in
        "installed")
            icon="${ICON_CHECK}"
            color="${GREEN}"
            ;;
        "skipped")
            icon="${ICON_WARNING}"
            color="${YELLOW}"
            ;;
        "already")
            icon="${ICON_INFO}"
            color="${BLUE}"
            ;;
        "failed")
            icon="${ICON_CROSS}"
            color="${LIGHT_RED}"
            ;;
    esac

    echo -e "  ${color}${icon} ${WHITE}${package}${NC} ${GRAY}${DIM}(${color}${status}${GRAY})${NC}"
}

# Hiển thị trạng thái cài đặt gói
show_pacman_package_status() {
    local package="$1"
    local status="$2"
    local icon=""
    local color=""

    case $status in
        "installed")
            icon="${ICON_CHECK}"
            color="${GREEN}"
            ;;
        "skipped")
            icon="${ICON_CROSS}"
            color="${YELLOW}"
            ;;
        "already")
            icon="${ICON_INFO}"
            color="${BLUE}"
            ;;
        "failed")
            icon="${ICON_CROSS}"
            color="${LIGHT_RED}"
            ;;
    esac

    echo -e "${color}  ${icon} ${WHITE}${package}${NC} ${color}${status}${NC}"

    # Ghi nhật ký
    log_info "Gói Pacman: $package - Trạng thái: $status"
}

# Cài đặt một gói Pacman cụ thể
install_pacman_package() {
    local package="$1"
    local installed_count=0
    local skipped_count=0
    local already_installed_count=0

    # Kiểm tra xem gói đã được cài đặt chưa
    if is_pacman_package_installed "$package"; then
        show_pacman_package_status "$package" "đã được cài đặt"
        already_installed_count=$((already_installed_count + 1))
        return 0
    fi

    # Yêu cầu xác nhận cài đặt
    if ask_install_pacman "$package"; then
        # Hiển thị spinner khi đang cài đặt
        echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt $package...${NC}"

        # Cài đặt gói sử dụng pacman
        if sudo pacman -S --noconfirm "$package"; then
            # Xác minh cài đặt thành công
            if is_pacman_package_installed "$package"; then
                show_pacman_package_status "$package" "đã cài đặt thành công"
                installed_count=$((installed_count + 1))
                return 0
            else
                show_pacman_package_status "$package" "cài đặt thất bại"
                return 1
            fi
        else
            show_pacman_package_status "$package" "cài đặt thất bại"
            return 1
        fi
    else
        show_pacman_package_status "$package" "bỏ qua bởi người dùng"
        skipped_count=$((skipped_count + 1))
        return 2
    fi
}

# Cài đặt nhiều gói Pacman từ danh sách
install_pacman_packages() {
    local packages=("$@")
    local installed_count=0
    local skipped_count=0
    local already_installed_count=0

    echo -e "${LIGHT_YELLOW}${ICON_GEAR} ${BOLD}Kiểm tra các gói Pacman...${NC}\n"

    for package in "${packages[@]}"; do
        # Kiểm tra xem gói đã được cài đặt chưa
        if is_pacman_package_installed "$package"; then
            show_pacman_package_status "$package" "đã được cài đặt"
            already_installed_count=$((already_installed_count + 1))
            continue
        fi

        # Yêu cầu xác nhận cài đặt
        if ask_install_pacman "$package"; then
            # Hiển thị spinner khi đang cài đặt
            echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt $package...${NC}"

            # Cài đặt gói sử dụng pacman
            if sudo pacman -S --noconfirm "$package"; then
                # Xác minh cài đặt thành công
                if is_pacman_package_installed "$package"; then
                    show_pacman_package_status "$package" "đã cài đặt thành công"
                    installed_count=$((installed_count + 1))
                else
                    show_pacman_package_status "$package" "cài đặt thất bại"
                fi
            else
                show_pacman_package_status "$package" "cài đặt thất bại"
            fi
        else
            show_pacman_package_status "$package" "bỏ qua bởi người dùng"
            skipped_count=$((skipped_count + 1))
        fi
        echo
    done

    # Lưu kết quả để sử dụng ở nơi khác
    PACMAN_INSTALLED_COUNT=$installed_count
    PACMAN_SKIPPED_COUNT=$skipped_count
    PACMAN_ALREADY_INSTALLED_COUNT=$already_installed_count

    return 0
}

# Cập nhật cơ sở dữ liệu gói
update_pacman_database() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cập nhật cơ sở dữ liệu gói...${NC}"

    show_spinner "Cập nhật cơ sở dữ liệu Pacman" 1

    if sudo pacman -Sy; then
        print_boxed_message "Đã cập nhật cơ sở dữ liệu gói thành công" "success"
        return 0
    else
        print_boxed_message "Cập nhật cơ sở dữ liệu gói thất bại" "error"
        return 1
    fi
}

# Nâng cấp tất cả các gói
upgrade_all_pacman_packages() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang nâng cấp tất cả các gói...${NC}"

    show_spinner "Chuẩn bị nâng cấp gói" 1

    if sudo pacman -Syu --noconfirm; then
        print_boxed_message "Đã nâng cấp tất cả các gói thành công" "success"
        return 0
    else
        print_boxed_message "Nâng cấp gói thất bại" "error"
        return 1
    fi
}

# Gỡ cài đặt gói
remove_pacman_package() {
    local package="$1"

    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang gỡ cài đặt gói $package...${NC}"

    # Kiểm tra xem gói có được cài đặt không
    if ! is_pacman_package_installed "$package"; then
        print_boxed_message "Gói $package không được cài đặt" "error"
        return 1
    fi

    # Yêu cầu xác nhận gỡ cài đặt
    if confirm_yn "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}Bạn có chắc chắn muốn gỡ cài đặt ${BOLD}$package${NC}${WHITE} không?${NC}" "n"; then
        # Gỡ cài đặt gói
        if sudo pacman -R "$package" --noconfirm; then
            print_boxed_message "Đã gỡ cài đặt $package thành công" "success"
            return 0
        else
            print_boxed_message "Gỡ cài đặt $package thất bại" "error"
            return 1
        fi
    else
        print_boxed_message "Đã hủy gỡ cài đặt $package" "info"
        return 2
    fi
}

# Tìm kiếm gói
search_pacman_package() {
    local keyword="$1"

    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang tìm kiếm gói với từ khóa '$keyword'...${NC}"

    # Tìm kiếm gói
    pacman -Ss "$keyword"

    return 0
}
