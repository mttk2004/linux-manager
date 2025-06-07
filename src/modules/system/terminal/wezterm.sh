#!/bin/bash

# Hàm cấu hình WezTerm
configure_wezterm() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cấu hình WezTerm...${NC}"

    # Kiểm tra xem WezTerm đã được cài đặt chưa
    if ! command -v wezterm &>/dev/null; then
        print_boxed_message "WezTerm chưa được cài đặt" "info"

        # Yêu cầu cài đặt WezTerm
        if confirm_yn "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}Bạn có muốn cài đặt WezTerm không?${NC}" "y"; then
            if ! sudo pacman -S --noconfirm wezterm; then
                print_boxed_message "Không thể cài đặt WezTerm. Không thể tiếp tục." "error"
                return 1
            fi
        else
            print_boxed_message "WezTerm không được cài đặt. Không thể tiếp tục." "error"
            return 1
        fi
    fi

    print_boxed_message "Đang tải cấu hình WezTerm..." "info"

    # Tạo file cấu hình WezTerm
    if curl -s "https://raw.githubusercontent.com/mttk2004/wezterm/refs/heads/main/.wezterm.lua" > "$HOME/.wezterm.lua"; then
        print_boxed_message "Đã cài đặt cấu hình WezTerm thành công!" "success"
    else
        print_boxed_message "Không thể tải cấu hình WezTerm. Vui lòng kiểm tra kết nối mạng." "error"
        return 1
    fi

    return 0
}
