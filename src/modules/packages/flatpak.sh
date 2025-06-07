#!/bin/bash

# Module quản lý gói Flatpak
# Được sử dụng để cài đặt và quản lý các ứng dụng Flatpak

# Kiểm tra xem Flatpak đã được cài đặt chưa
check_flatpak_installed() {
    if command -v flatpak &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Cài đặt Flatpak
install_flatpak() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt Flatpak...${NC}"

    # Cài đặt flatpak từ kho chính thức
    if sudo pacman -S --noconfirm flatpak; then
        print_boxed_message "Đã cài đặt Flatpak thành công" "success"

        # Thêm kho Flathub
        echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang thêm kho Flathub...${NC}"
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

        print_boxed_message "Đã thêm kho Flathub thành công" "success"
        print_boxed_message "Bạn nên khởi động lại máy tính để hoàn tất cài đặt Flatpak" "info"

        return 0
    else
        print_boxed_message "Cài đặt Flatpak thất bại" "error"
        return 1
    fi
}

# Kiểm tra xem một gói Flatpak đã được cài đặt chưa
is_flatpak_installed() {
    local app_id="$1"

    if flatpak list --app | grep -q "$app_id"; then
        return 0 # Đã cài đặt
    else
        return 1 # Chưa cài đặt
    fi
}

# Hiển thị trạng thái cài đặt gói
show_flatpak_status() {
    local app_id="$1"
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

    echo -e "${color}  ${icon} ${WHITE}${app_id}${NC} ${color}${status}${NC}"

    # Ghi nhật ký
    log_info "Flatpak: $app_id - Trạng thái: $status"
}

# Yêu cầu xác nhận cài đặt gói
ask_install_flatpak() {
    local app_id="$1"
    local app_name="$2"

    # Nếu tên ứng dụng không được cung cấp, sử dụng app_id
    if [ -z "$app_name" ]; then
        app_name="$app_id"
    fi

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_PACKAGE} ${BOLD}CÀI ĐẶT ỨNG DỤNG FLATPAK${NC} ${ICON_PACKAGE}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
    echo -e "  ${YELLOW}Ứng dụng:${NC} ${WHITE}${BOLD}$app_name${NC}"
    echo -e "  ${YELLOW}ID:${NC} ${LIGHT_CYAN}$app_id${NC}"
    echo -e "  ${YELLOW}Nguồn:${NC} ${LIGHT_CYAN}Flathub${NC}"
    echo
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Sử dụng hàm confirm_yn từ utils.sh
    if confirm_yn "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}Bạn có muốn cài đặt ${BOLD}$app_name${NC}${WHITE} không?${NC}" "y"; then
        return 0 # Người dùng chọn có
    else
        return 1 # Người dùng chọn không
    fi
}

# Cài đặt một ứng dụng Flatpak
install_flatpak_app() {
    local app_id="$1"
    local app_name="$2"

    # Nếu tên ứng dụng không được cung cấp, sử dụng app_id
    if [ -z "$app_name" ]; then
        app_name="$app_id"
    fi

    # Kiểm tra xem Flatpak đã được cài đặt chưa
    if ! check_flatpak_installed; then
        print_boxed_message "Flatpak chưa được cài đặt" "info"

        # Yêu cầu cài đặt Flatpak
        if confirm_yn "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}Bạn có muốn cài đặt Flatpak không?${NC}" "y"; then
            if ! install_flatpak; then
                print_boxed_message "Không thể cài đặt Flatpak. Không thể tiếp tục." "error"
                return 1
            fi
        else
            print_boxed_message "Flatpak không được cài đặt. Không thể tiếp tục." "error"
            return 1
        fi
    fi

    # Kiểm tra xem ứng dụng đã được cài đặt chưa
    if is_flatpak_installed "$app_id"; then
        show_flatpak_status "$app_id" "đã được cài đặt (Flatpak)"
        return 0
    fi

    # Yêu cầu xác nhận cài đặt
    if ask_install_flatpak "$app_id" "$app_name"; then
        # Hiển thị spinner khi đang cài đặt
        echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt $app_name từ Flathub...${NC}"

        # Cài đặt ứng dụng
        if flatpak install flathub "$app_id" -y; then
            # Xác minh cài đặt thành công
            if is_flatpak_installed "$app_id"; then
                show_flatpak_status "$app_id" "đã cài đặt thành công (Flatpak)"
                return 0
            else
                show_flatpak_status "$app_id" "cài đặt thất bại (Flatpak)"
                return 1
            fi
        else
            show_flatpak_status "$app_id" "cài đặt thất bại (Flatpak)"
            return 1
        fi
    else
        show_flatpak_status "$app_id" "bỏ qua bởi người dùng"
        return 2
    fi
}

# Cài đặt nhiều ứng dụng Flatpak
install_flatpak_apps() {
    local app_ids=("$@")
    local installed_count=0
    local skipped_count=0
    local already_installed_count=0

    echo -e "${LIGHT_YELLOW}${ICON_GEAR} ${BOLD}Kiểm tra các ứng dụng Flatpak...${NC}\n"

    # Kiểm tra xem Flatpak đã được cài đặt chưa
    if ! check_flatpak_installed; then
        print_boxed_message "Flatpak chưa được cài đặt" "info"

        # Yêu cầu cài đặt Flatpak
        if confirm_yn "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}Bạn có muốn cài đặt Flatpak không?${NC}" "y"; then
            if ! install_flatpak; then
                print_boxed_message "Không thể cài đặt Flatpak. Không thể tiếp tục." "error"
                return 1
            fi
        else
            print_boxed_message "Flatpak không được cài đặt. Không thể tiếp tục." "error"
            return 1
        fi
    fi

    for app_id in "${app_ids[@]}"; do
        # Kiểm tra xem ứng dụng đã được cài đặt chưa
        if is_flatpak_installed "$app_id"; then
            show_flatpak_status "$app_id" "đã được cài đặt (Flatpak)"
            already_installed_count=$((already_installed_count + 1))
            continue
        fi

        # Yêu cầu xác nhận cài đặt
        if ask_install_flatpak "$app_id"; then
            # Hiển thị spinner khi đang cài đặt
            echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt $app_id từ Flathub...${NC}"

            # Cài đặt ứng dụng
            if flatpak install flathub "$app_id" -y; then
                # Xác minh cài đặt thành công
                if is_flatpak_installed "$app_id"; then
                    show_flatpak_status "$app_id" "đã cài đặt thành công (Flatpak)"
                    installed_count=$((installed_count + 1))
                else
                    show_flatpak_status "$app_id" "cài đặt thất bại (Flatpak)"
                fi
            else
                show_flatpak_status "$app_id" "cài đặt thất bại (Flatpak)"
            fi
        else
            show_flatpak_status "$app_id" "bỏ qua bởi người dùng"
            skipped_count=$((skipped_count + 1))
        fi
        echo
    done

    # Lưu kết quả để sử dụng ở nơi khác
    FLATPAK_INSTALLED_COUNT=$installed_count
    FLATPAK_SKIPPED_COUNT=$skipped_count
    FLATPAK_ALREADY_INSTALLED_COUNT=$already_installed_count

    return 0
}

# Cập nhật tất cả các ứng dụng Flatpak
update_flatpak_apps() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cập nhật tất cả các ứng dụng Flatpak...${NC}"

    # Kiểm tra xem Flatpak đã được cài đặt chưa
    if ! check_flatpak_installed; then
        print_boxed_message "Flatpak chưa được cài đặt" "error"
        return 1
    fi

    show_spinner "Chuẩn bị cập nhật ứng dụng Flatpak" 1

    if flatpak update -y; then
        print_boxed_message "Đã cập nhật tất cả các ứng dụng Flatpak thành công" "success"
        return 0
    else
        print_boxed_message "Cập nhật ứng dụng Flatpak thất bại" "error"
        return 1
    fi
}

# Gỡ cài đặt ứng dụng Flatpak
remove_flatpak_app() {
    local app_id="$1"

    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang gỡ cài đặt ứng dụng Flatpak $app_id...${NC}"

    # Kiểm tra xem ứng dụng có được cài đặt không
    if ! is_flatpak_installed "$app_id"; then
        print_boxed_message "Ứng dụng $app_id không được cài đặt" "error"
        return 1
    fi

    # Yêu cầu xác nhận gỡ cài đặt
    if confirm_yn "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}Bạn có chắc chắn muốn gỡ cài đặt ${BOLD}$app_id${NC}${WHITE} không?${NC}" "n"; then
        # Gỡ cài đặt ứng dụng
        if flatpak uninstall "$app_id" -y; then
            print_boxed_message "Đã gỡ cài đặt $app_id thành công" "success"
            return 0
        else
            print_boxed_message "Gỡ cài đặt $app_id thất bại" "error"
            return 1
        fi
    else
        print_boxed_message "Đã hủy gỡ cài đặt $app_id" "info"
        return 2
    fi
}

# Tìm kiếm ứng dụng Flatpak
search_flatpak_app() {
    local keyword="$1"

    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang tìm kiếm ứng dụng Flatpak với từ khóa '$keyword'...${NC}"

    # Kiểm tra xem Flatpak đã được cài đặt chưa
    if ! check_flatpak_installed; then
        print_boxed_message "Flatpak chưa được cài đặt" "error"
        return 1
    fi

    # Tìm kiếm ứng dụng
    flatpak search "$keyword"

    return 0
}

# Liệt kê tất cả các ứng dụng Flatpak đã cài đặt
list_installed_flatpak_apps() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang liệt kê tất cả các ứng dụng Flatpak đã cài đặt...${NC}"

    # Kiểm tra xem Flatpak đã được cài đặt chưa
    if ! check_flatpak_installed; then
        print_boxed_message "Flatpak chưa được cài đặt" "error"
        return 1
    fi

    # Liệt kê ứng dụng
    flatpak list --app

    return 0
}
