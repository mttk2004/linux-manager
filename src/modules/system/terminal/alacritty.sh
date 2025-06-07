#!/bin/bash

# Hàm cấu hình Alacritty
configure_alacritty() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cấu hình Alacritty...${NC}"

    # Kiểm tra xem Alacritty đã được cài đặt chưa
    if ! command -v alacritty &>/dev/null; then
        print_boxed_message "Alacritty chưa được cài đặt" "info"

        # Yêu cầu cài đặt Alacritty
        if confirm_yn "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}Bạn có muốn cài đặt Alacritty không?${NC}" "y"; then
            if ! sudo pacman -S --noconfirm alacritty; then
                print_boxed_message "Không thể cài đặt Alacritty. Không thể tiếp tục." "error"
                return 1
            fi
        else
            print_boxed_message "Alacritty không được cài đặt. Không thể tiếp tục." "error"
            return 1
        fi
    fi

    # Tạo thư mục config nếu chưa tồn tại
    mkdir -p "$HOME/.config/alacritty"

    print_boxed_message "Đang tạo cấu hình Alacritty..." "info"

    # Tạo file cấu hình mẫu cho Alacritty
    cat > "$HOME/.config/alacritty/alacritty.yml" << EOF
# Alacritty configuration

window:
  padding:
    x: 20
    y: 20
  decorations: none
  opacity: 0.95
  dimensions:
    columns: 110
    lines: 28

font:
  normal:
    family: CaskaydiaCove Nerd Font
    style: Light
  size: 13.0

colors:
  # Tokyo Night theme
  primary:
    background: '#1a1b26'
    foreground: '#e0e0e0'
  selection:
    text: '#e6e6fa'
    background: '#2b3045'
  normal:
    black:   '#32344a'
    red:     '#f7768e'
    green:   '#9ece6a'
    yellow:  '#e0af68'
    blue:    '#7aa2f7'
    magenta: '#ad8ee6'
    cyan:    '#449dab'
    white:   '#787c99'
  bright:
    black:   '#444b6a'
    red:     '#ff7a93'
    green:   '#b9f27c'
    yellow:  '#ff9e64'
    blue:    '#7da6ff'
    magenta: '#bb9af7'
    cyan:    '#0db9d7'
    white:   '#acb0d0'

cursor:
  style:
    shape: Beam
  blink: true
  blink_interval: 500

shell:
  program: /usr/bin/fish

scrolling:
  history: 10000

key_bindings:
  - { key: Equals,   mods: Control,       action: IncreaseFontSize }
  - { key: Minus,    mods: Control,       action: DecreaseFontSize }
  - { key: Key0,     mods: Control,       action: ResetFontSize    }
EOF

    print_boxed_message "Đã cài đặt cấu hình Alacritty thành công!" "success"
    return 0
}
