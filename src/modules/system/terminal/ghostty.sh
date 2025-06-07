#!/bin/bash

# Hàm cấu hình Ghostty
configure_ghostty() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cấu hình Ghostty...${NC}"

    # Kiểm tra xem Ghostty đã được cài đặt chưa
    if ! command -v ghostty &>/dev/null; then
        print_boxed_message "Ghostty chưa được cài đặt" "info"

        # Yêu cầu cài đặt Ghostty
        if confirm_yn "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}Bạn có muốn cài đặt Ghostty không?${NC}" "y"; then
            # Ghostty thường không có trong các kho chính thống, cần cài đặt từ AUR
            if command -v yay &>/dev/null; then
                if ! yay -S --noconfirm ghostty; then
                    print_boxed_message "Không thể cài đặt Ghostty. Không thể tiếp tục." "error"
                    return 1
                fi
            else
                print_boxed_message "Không thể cài đặt Ghostty. Cần cài đặt yay trước." "error"
                return 1
            fi
        else
            print_boxed_message "Ghostty không được cài đặt. Không thể tiếp tục." "error"
            return 1
        fi
    fi

    # Tạo thư mục config nếu chưa tồn tại
    mkdir -p "$HOME/.config/ghostty"

    print_boxed_message "Đang tạo cấu hình Ghostty..." "info"

    # Tạo file cấu hình mẫu cho Ghostty
    cat > "$HOME/.config/ghostty/config" << EOF
# Ghostty configuration
font-family = "CaskaydiaCove Nerd Font"
font-size = 13
theme = "Tokyo Night"

# Window settings
window-width = 110
window-height = 28
window-padding-x = 20
window-padding-y = 20
window-decoration = false
background-opacity = 0.95

# Cursor settings
cursor-style = "bar"
cursor-blink-interval-ms = 500

# Keyboard shortcuts
keybind = ctrl+equal=increase_font_size
keybind = ctrl+minus=decrease_font_size
keybind = ctrl+0=reset_font_size

# Colors
foreground = #e0e0e0
background = #1a1b26
selection-foreground = #e6e6fa
selection-background = #2b3045

# Terminal settings
shell = /usr/bin/fish
scrollback-lines = 10000
EOF

    print_boxed_message "Đã cài đặt cấu hình Ghostty thành công!" "success"
    return 0
}
