#!/bin/bash

# Module quản lý gói AUR
# Được sử dụng để cài đặt và quản lý các gói từ Arch User Repository

# Kiểm tra xem một trình trợ giúp AUR đã được cài đặt chưa
check_aur_helper() {
    if command -v yay &>/dev/null; then
        AUR_HELPER="yay"
        return 0
    elif command -v paru &>/dev/null; then
        AUR_HELPER="paru"
        return 0
    elif command -v aurman &>/dev/null; then
        AUR_HELPER="aurman"
        return 0
    else
        AUR_HELPER=""
        return 1
    fi
}

# Cài đặt trình trợ giúp AUR (yay)
install_aur_helper() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt trình trợ giúp AUR (yay)...${NC}"

    # Kiểm tra xem git đã được cài đặt chưa
    if ! command -v git &>/dev/null; then
        echo -e "${LIGHT_YELLOW}${ICON_GEAR} Cài đặt git...${NC}"
        sudo pacman -S --noconfirm git
    fi

    # Tạo thư mục tạm thời
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"

    # Clone yay từ AUR
    if git clone https://aur.archlinux.org/yay.git; then
        cd yay
        if makepkg -si --noconfirm; then
            print_boxed_message "Đã cài đặt yay thành công" "success"
            AUR_HELPER="yay"

            # Dọn dẹp
            cd
            rm -rf "$temp_dir"
            return 0
        else
            print_boxed_message "Cài đặt yay thất bại" "error"
            cd
            rm -rf "$temp_dir"
            return 1
        fi
    else
        print_boxed_message "Không thể tải yay từ AUR" "error"
        cd
        rm -rf "$temp_dir"
        return 1
    fi
}

# Kiểm tra xem một gói đã được cài đặt chưa
is_aur_package_installed() {
    local package="$1"

    # Sử dụng pacman -Qi để kiểm tra (cả gói AUR cũng được quản lý bởi pacman sau khi cài đặt)
    if pacman -Qi "$package" &> /dev/null; then
        return 0 # Gói đã được cài đặt
    else
        return 1 # Gói chưa được cài đặt
    fi
}

# Yêu cầu xác nhận cài đặt gói AUR
ask_install_aur() {
    local package="$1"
    local description="$2"

    # Nếu không có mô tả, sử dụng tên gói
    if [ -z "$description" ]; then
        description="$package"
    fi

    # Hiển thị header với style tối giản
    display_section_header "CÀI ĐẶT GÓI AUR" "${ICON_PACKAGE}"

    # Hiển thị thông tin gói
    echo -e "  ${YELLOW}Gói:${NC} ${WHITE}${BOLD}$package${NC}"
    echo -e "  ${YELLOW}Mô tả:${NC} ${LIGHT_CYAN}$description${NC}"
    echo -e "  ${YELLOW}Nguồn:${NC} ${LIGHT_CYAN}Arch User Repository${NC}"
    echo

    # Sử dụng hàm confirm_yn từ utils.sh với style mới
    if confirm_yn "Bạn có muốn cài đặt ${BOLD}$package${NC}${WHITE} không?" "y"; then
        return 0 # Người dùng chọn có
    else
        return 1 # Người dùng chọn không
    fi
}

# Hiển thị trạng thái cài đặt gói AUR
show_aur_status() {
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

    # Ghi nhật ký
    log_info "AUR: $package - Status: $status"
}

# Kiểm tra và cài đặt trình trợ giúp AUR
check_install_aur_helper() {
    local helper_installed=false

    # Hiển thị header
    display_section_header "KIỂM TRA TRÌNH TRỢ GIÚP AUR" "${ICON_GEAR}"

    # Kiểm tra từng trình trợ giúp
    if command -v yay &>/dev/null; then
        echo -e "  ${GREEN}${ICON_CHECK} ${WHITE}Đã cài đặt${NC} ${LIGHT_CYAN}yay${NC}"
        AUR_HELPER="yay"
        helper_installed=true
    elif command -v paru &>/dev/null; then
        echo -e "  ${GREEN}${ICON_CHECK} ${WHITE}Đã cài đặt${NC} ${LIGHT_CYAN}paru${NC}"
        AUR_HELPER="paru"
        helper_installed=true
    fi

    if ! $helper_installed; then
        echo -e "  ${YELLOW}${ICON_WARNING} ${WHITE}Chưa cài đặt trình trợ giúp AUR${NC}"
        echo

        # Yêu cầu cài đặt trình trợ giúp
        if confirm_yn "Bạn có muốn cài đặt trình trợ giúp AUR (yay) không?" "y"; then
            install_aur_helper
            return $?
        else
            print_boxed_message "Không thể tiếp tục mà không có trình trợ giúp AUR" "error"
            return 1
        fi
    fi

    return 0
}

# Hiển thị thông tin chi tiết về gói AUR
show_aur_package_info() {
    local package="$1"

    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang lấy thông tin gói AUR $package...${NC}"

    # Kiểm tra xem trình trợ giúp AUR đã được cài đặt chưa
    if ! check_aur_helper; then
        print_boxed_message "Không tìm thấy trình trợ giúp AUR" "error"
        return 1
    fi

    # Lấy thông tin gói
    if ! $AUR_HELPER -Si "$package" >/dev/null 2>&1; then
        print_boxed_message "Không thể tìm thấy gói AUR $package" "error"
        return 1
    fi

    # Hiển thị thông tin gói
    $AUR_HELPER -Si "$package" | awk -F ': ' '/^Name/{printf "\033[1;37m%-20s\033[0m: ", $2} /^Version/{printf "\033[1;32m%s\033[0m\n", $2} /^Description/{printf "\033[1;36m%s\033[0m\n", $2} /^URL/{printf "\033[1;34m%s\033[0m\n", $2} /^Maintainer/{printf "\033[1;35m%s\033[0m\n", $2} /^Last Updated/{printf "\033[1;33m%s\033[0m\n", $2}'

    return 0
}

# Cài đặt một gói AUR cụ thể
install_aur_package() {
    local package="$1"
    local installed_count=0
    local skipped_count=0
    local already_installed_count=0

    # Kiểm tra xem gói đã được cài đặt chưa
    if is_aur_package_installed "$package"; then
        show_aur_package_status "$package" "đã được cài đặt (AUR)"
        already_installed_count=$((already_installed_count + 1))
        return 0
    fi

    # Kiểm tra xem trình trợ giúp AUR đã được cài đặt chưa
    if ! check_aur_helper; then
        print_boxed_message "Không tìm thấy trình trợ giúp AUR (yay, paru, aurman)" "info"

        # Yêu cầu cài đặt trình trợ giúp AUR
        if confirm_yn "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}Bạn có muốn cài đặt trình trợ giúp AUR (yay) không?${NC}" "y"; then
            if ! install_aur_helper; then
                print_boxed_message "Không thể cài đặt trình trợ giúp AUR. Không thể tiếp tục." "error"
                return 1
            fi
        else
            print_boxed_message "Không có trình trợ giúp AUR. Không thể tiếp tục." "error"
            return 1
        fi
    fi

    # Yêu cầu xác nhận cài đặt
    if ask_install_aur "$package"; then
        # Hiển thị spinner khi đang cài đặt
        echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt $package từ AUR...${NC}"

        # Cài đặt gói sử dụng trình trợ giúp AUR
        if $AUR_HELPER -S --noconfirm "$package"; then
            # Xác minh cài đặt thành công
            if is_aur_package_installed "$package"; then
                show_aur_package_status "$package" "đã cài đặt thành công (AUR)"
                installed_count=$((installed_count + 1))
                return 0
            else
                show_aur_package_status "$package" "cài đặt thất bại (AUR)"
                return 1
            fi
        else
            show_aur_package_status "$package" "cài đặt thất bại (AUR)"
            return 1
        fi
    else
        show_aur_package_status "$package" "bỏ qua bởi người dùng"
        skipped_count=$((skipped_count + 1))
        return 2
    fi
}

# Cài đặt nhiều gói AUR từ danh sách
install_aur_packages() {
    local packages=("$@")
    local installed_count=0
    local skipped_count=0
    local already_installed_count=0

    echo -e "${LIGHT_YELLOW}${ICON_GEAR} ${BOLD}Kiểm tra các gói AUR...${NC}\n"

    # Kiểm tra xem trình trợ giúp AUR đã được cài đặt chưa
    if ! check_aur_helper; then
        print_boxed_message "Không tìm thấy trình trợ giúp AUR (yay, paru, aurman)" "info"

        # Yêu cầu cài đặt trình trợ giúp AUR
        if confirm_yn "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}Bạn có muốn cài đặt trình trợ giúp AUR (yay) không?${NC}" "y"; then
            if ! install_aur_helper; then
                print_boxed_message "Không thể cài đặt trình trợ giúp AUR. Không thể tiếp tục." "error"
                return 1
            fi
        else
            print_boxed_message "Không có trình trợ giúp AUR. Không thể tiếp tục." "error"
            return 1
        fi
    fi

    for package in "${packages[@]}"; do
        # Kiểm tra xem gói đã được cài đặt chưa
        if is_aur_package_installed "$package"; then
            show_aur_package_status "$package" "đã được cài đặt (AUR)"
            already_installed_count=$((already_installed_count + 1))
            continue
        fi

        # Yêu cầu xác nhận cài đặt
        if ask_install_aur "$package"; then
            # Hiển thị spinner khi đang cài đặt
            echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt $package từ AUR...${NC}"

            # Cài đặt gói sử dụng trình trợ giúp AUR
            if $AUR_HELPER -S --noconfirm "$package"; then
                # Xác minh cài đặt thành công
                if is_aur_package_installed "$package"; then
                    show_aur_package_status "$package" "đã cài đặt thành công (AUR)"
                    installed_count=$((installed_count + 1))
                else
                    show_aur_package_status "$package" "cài đặt thất bại (AUR)"
                fi
            else
                show_aur_package_status "$package" "cài đặt thất bại (AUR)"
            fi
        else
            show_aur_package_status "$package" "bỏ qua bởi người dùng"
            skipped_count=$((skipped_count + 1))
        fi
        echo
    done

    # Lưu kết quả để sử dụng ở nơi khác
    AUR_INSTALLED_COUNT=$installed_count
    AUR_SKIPPED_COUNT=$skipped_count
    AUR_ALREADY_INSTALLED_COUNT=$already_installed_count

    return 0
}

# Cập nhật tất cả các gói AUR
upgrade_all_aur_packages() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang nâng cấp tất cả các gói AUR...${NC}"

    # Kiểm tra xem trình trợ giúp AUR đã được cài đặt chưa
    if ! check_aur_helper; then
        print_boxed_message "Không tìm thấy trình trợ giúp AUR" "error"
        return 1
    fi

    show_spinner "Chuẩn bị nâng cấp gói AUR" 1

    if $AUR_HELPER -Sua --noconfirm; then
        print_boxed_message "Đã nâng cấp tất cả các gói AUR thành công" "success"
        return 0
    else
        print_boxed_message "Nâng cấp gói AUR thất bại" "error"
        return 1
    fi
}

# Gỡ cài đặt gói AUR
remove_aur_package() {
    local package="$1"

    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang gỡ cài đặt gói AUR $package...${NC}"

    # Kiểm tra xem gói có được cài đặt không
    if ! is_aur_package_installed "$package"; then
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

# Tìm kiếm gói AUR
search_aur_package() {
    local keyword="$1"

    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang tìm kiếm gói AUR với từ khóa '$keyword'...${NC}"

    # Kiểm tra xem trình trợ giúp AUR đã được cài đặt chưa
    if ! check_aur_helper; then
        print_boxed_message "Không tìm thấy trình trợ giúp AUR" "error"
        return 1
    fi

    # Tìm kiếm gói
    $AUR_HELPER -Ss "$keyword"

    return 0
}
