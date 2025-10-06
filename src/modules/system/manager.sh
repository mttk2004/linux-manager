#!/bin/bash

# Module quản lý cấu hình hệ thống

# Tải các module chức năng
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "${SCRIPT_DIR}/../../core" && pwd)"

# Tải các module core trước
source "${CORE_DIR}/config.sh"
source "${CORE_DIR}/utils.sh"
source "${CORE_DIR}/ui.sh"

# Tải các module chức năng
if [ -f "${SCRIPT_DIR}/terminal/manager.sh" ]; then
    source "${SCRIPT_DIR}/terminal/manager.sh"
fi

# Module cleanup được tích hợp trực tiếp trong file này

# Hiển thị menu cấu hình hệ thống
display_system_menu() {
    clear
    echo -e "${LIGHT_CYAN}"
    echo "    ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗"
    echo "    ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║"
    echo "    ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║"
    echo "    ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║"
    echo "    ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║"
    echo "    ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝"
    echo -e "${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_CONFIG} ${BOLD}QUẢN LÝ CẤU HÌNH HỆ THỐNG${NC} ${ICON_CONFIG}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Cấu hình shell${NC}"
    echo -e "      ${GRAY}${DIM}Bash, Zsh, Fish${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Cấu hình trình soạn thảo${NC}"
    echo -e "      ${GRAY}${DIM}Vim, Neovim, Emacs${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Cấu hình mạng${NC}"
    echo -e "      ${GRAY}${DIM}NetworkManager${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[4]${NC}  ${WHITE}Cấu hình dịch vụ${NC}"
    echo -e "      ${GRAY}${DIM}Systemd${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[5]${NC}  ${WHITE}Tạo bản sao lưu${NC}"
    echo -e "      ${GRAY}${DIM}Timeshift${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[6]${NC}  ${WHITE}Cấu hình Window Manager${NC}"
    echo -e "      ${GRAY}${DIM}Qtile, Xmonad${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[7]${NC}  ${WHITE}Cấu hình Terminal Emulator${NC}"
    echo -e "      ${GRAY}${DIM}WezTerm, Ghostty, Alacritty${NC}"
    echo

    echo -e "  🧹 ${GREEN}${BOLD}[8]${NC}  ${WHITE}Dọn dẹp hệ thống${NC}"
    echo -e "      ${GRAY}${DIM}Gỡ gói mồ côi, cache, AUR${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[9]${NC}  ${WHITE}Quay lại menu chính${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu chính${NC}"
    echo

    echo -e "${DARK_GRAY}    ────────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-9${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ────────────────────────────────────────────────────────────────${NC}"
    echo
}

# Cấu hình shell
configure_shell() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Cấu hình shell...${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_CONFIG} ${BOLD}LỰA CHỌN SHELL${NC} ${ICON_CONFIG}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Bash${NC}"
    echo -e "      ${GRAY}${DIM}Shell mặc định${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Zsh${NC}"
    echo -e "      ${GRAY}${DIM}Với Oh My Zsh${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Fish${NC}"
    echo -e "      ${GRAY}${DIM}User-friendly${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[4]${NC}  ${WHITE}Quay lại${NC}"
    echo -e "      ${GRAY}${DIM}Menu trước${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-4${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Lấy lựa chọn từ người dùng
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-4${DARK_GRAY}]${NC}: "
    read -n 1 shell_choice
    echo

    case $shell_choice in
        1)
            # Cấu hình Bash
            print_boxed_message "Đang cấu hình Bash..." "info"
            show_spinner "Cài đặt cấu hình Bash" 2
            print_boxed_message "Tính năng cấu hình Bash sẽ sớm được phát triển!" "info"
            ;;
        2)
            # Cấu hình Zsh
            print_boxed_message "Đang cấu hình Zsh..." "info"
            show_spinner "Cài đặt cấu hình Zsh" 2
            print_boxed_message "Tính năng cấu hình Zsh sẽ sớm được phát triển!" "info"
            ;;
        3)
            # Cấu hình Fish
            print_boxed_message "Đang cấu hình Fish..." "info"
            show_spinner "Cài đặt cấu hình Fish" 2
            print_boxed_message "Tính năng cấu hình Fish sẽ sớm được phát triển!" "info"
            ;;
        4)
            # Quay lại
            return 0
            ;;
        *)
            print_boxed_message "Lựa chọn không hợp lệ" "error"
            ;;
    esac

    return 0
}

# Cấu hình trình soạn thảo
configure_editor() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Cấu hình trình soạn thảo...${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_CONFIG} ${BOLD}LỰA CHỌN TRÌNH SOẠN THẢO${NC} ${ICON_CONFIG}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Vim${NC}"
    echo -e "      ${GRAY}${DIM}Trình soạn thảo cơ bản${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Neovim${NC}"
    echo -e "      ${GRAY}${DIM}Phiên bản hiện đại của Vim${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[3]${NC}  ${WHITE}VS Code${NC}"
    echo -e "      ${GRAY}${DIM}Trình soạn thảo đồ họa hiện đại${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[4]${NC}  ${WHITE}Quay lại${NC}"
    echo -e "      ${GRAY}${DIM}Menu trước${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Lấy lựa chọn từ người dùng
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-4${DARK_GRAY}]${NC}: "
    read -n 1 editor_choice
    echo

    case $editor_choice in
        1)
            # Cấu hình Vim
            print_boxed_message "Đang cấu hình Vim..." "info"
            show_spinner "Cài đặt cấu hình Vim" 2
            print_boxed_message "Tính năng cấu hình Vim sẽ sớm được phát triển!" "info"
            ;;
        2)
            # Cấu hình Neovim
            print_boxed_message "Đang cấu hình Neovim..." "info"
            show_spinner "Cài đặt cấu hình Neovim" 2
            print_boxed_message "Tính năng cấu hình Neovim sẽ sớm được phát triển!" "info"
            ;;
        3)
            # Cấu hình VS Code
            print_boxed_message "Đang cấu hình VS Code..." "info"
            show_spinner "Cài đặt cấu hình VS Code" 2
            print_boxed_message "Tính năng cấu hình VS Code sẽ sớm được phát triển!" "info"
            ;;
        4)
            # Quay lại
            return 0
            ;;
        *)
            print_boxed_message "Lựa chọn không hợp lệ" "error"
            ;;
    esac

    return 0
}

# Cấu hình mạng
configure_network() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Cấu hình mạng...${NC}"

    print_boxed_message "Tính năng cấu hình mạng sẽ sớm được phát triển!" "info"

    return 0
}

# Cấu hình dịch vụ
configure_services() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Cấu hình dịch vụ...${NC}"

    print_boxed_message "Tính năng cấu hình dịch vụ sẽ sớm được phát triển!" "info"

    return 0
}

# Tạo bản sao lưu
create_backup() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Tạo bản sao lưu...${NC}"

    # Kiểm tra xem Timeshift đã được cài đặt chưa
    if ! command -v timeshift &>/dev/null; then
        print_boxed_message "Timeshift chưa được cài đặt" "info"

        # Yêu cầu cài đặt Timeshift
        if confirm_yn "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}Bạn có muốn cài đặt Timeshift không?${NC}" "y"; then
            if ! sudo pacman -S --noconfirm timeshift; then
                print_boxed_message "Không thể cài đặt Timeshift. Không thể tiếp tục." "error"
                return 1
            fi
        else
            print_boxed_message "Timeshift không được cài đặt. Không thể tiếp tục." "error"
            return 1
        fi
    fi

    # Tạo bản sao lưu sử dụng Timeshift
    print_boxed_message "Đang tạo bản sao lưu sử dụng Timeshift..." "info"

    if sudo timeshift --create --comments "Bản sao lưu được tạo bởi Linux Manager" --tags D; then
        print_boxed_message "Đã tạo bản sao lưu thành công" "success"
    else
        print_boxed_message "Tạo bản sao lưu thất bại" "error"
    fi

    return 0
}

# Cấu hình Window Manager
configure_window_manager() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Cấu hình Window Manager...${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_CONFIG} ${BOLD}LỰA CHỌN WINDOW MANAGER${NC} ${ICON_CONFIG}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Qtile${NC}"
    echo -e "      ${GRAY}${DIM}Window Manager dựa trên Python${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Xmonad${NC}"
    echo -e "      ${GRAY}${DIM}Window Manager dựa trên Haskell${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[3]${NC}  ${WHITE}Quay lại${NC}"
    echo -e "      ${GRAY}${DIM}Menu trước${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-3${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Lấy lựa chọn từ người dùng
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-3${DARK_GRAY}]${NC}: "
    read -n 1 wm_choice
    echo

    case $wm_choice in
        1)
            # Cấu hình Qtile
            configure_qtile
            ;;
        2)
            # Cấu hình Xmonad
            print_boxed_message "Đang cấu hình Xmonad..." "info"
            show_spinner "Cài đặt cấu hình Xmonad" 2
            print_boxed_message "Tính năng cấu hình Xmonad sẽ sớm được phát triển!" "info"
            ;;
        3)
            # Quay lại
            return 0
            ;;
        *)
            print_boxed_message "Lựa chọn không hợp lệ" "error"
            ;;
    esac

    return 0
}

# Cấu hình Qtile
configure_qtile() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Cấu hình Qtile...${NC}"

    # Kiểm tra xem Qtile đã được cài đặt chưa
    if ! command -v qtile &>/dev/null; then
        print_boxed_message "Qtile chưa được cài đặt" "info"

        # Yêu cầu cài đặt Qtile
        if confirm_yn "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}Bạn có muốn cài đặt Qtile không?${NC}" "y"; then
            if ! sudo pacman -S --noconfirm qtile; then
                print_boxed_message "Không thể cài đặt Qtile. Không thể tiếp tục." "error"
                return 1
            fi
        else
            print_boxed_message "Qtile không được cài đặt. Không thể tiếp tục." "error"
            return 1
        fi
    fi

    # Tạo thư mục config nếu chưa tồn tại
    mkdir -p "$HOME/.config"

    # Tải cấu hình Qtile từ GitHub
    print_boxed_message "Đang tải cấu hình Qtile từ GitHub..." "info"

    # Tạo thư mục tạm để tải xuống
    temp_dir=$(mktemp -d)

    # Tải file cấu hình
    if wget -q https://github.com/mttk2004/qtile/archive/refs/heads/main.zip -O "$temp_dir/qtile.zip"; then
        print_boxed_message "Đã tải xuống cấu hình Qtile thành công" "success"

        # Giải nén vào thư mục ~/.config
        if unzip -q -o "$temp_dir/qtile.zip" -d "$temp_dir"; then
            # Di chuyển nội dung vào thư mục ~/.config/qtile
            mkdir -p "$HOME/.config/qtile"
            cp -r "$temp_dir/qtile-main/"* "$HOME/.config/qtile/"
            print_boxed_message "Đã cài đặt cấu hình Qtile thành công" "success"
        else
            print_boxed_message "Không thể giải nén file cấu hình Qtile" "error"
        fi

        # Dọn dẹp file tạm
        rm -rf "$temp_dir"
    else
        print_boxed_message "Không thể tải xuống cấu hình Qtile từ GitHub" "error"
        rm -rf "$temp_dir"
        return 1
    fi

    return 0
}

# Hàm dọn dẹp hệ thống (tạm thời tích hợp trực tiếp)
manage_system_cleanup() {
    clear
    echo -e "${LIGHT_CYAN}"
    echo "    ██████╗ ██╗      ███████╗ █████╗ ███╗   ██╗██╗   ██╗██████╗ "
    echo "    ██╔════╝██║      ██╔════╝██╔══██╗████╗  ██║██║   ██║██╔══██╗"
    echo "    ██║     ██║      █████╗  ███████║██╔██╗ ██║██║   ██║██████╔╝"
    echo "    ██║     ██║      ██╔══╝  ██╔══██║██║╚██╗██║██║   ██║██╔═══╝ "
    echo "    ╚██████╗███████╗ ███████╗██║  ██║██║ ╚████║╚██████╔╝██║     "
    echo "     ╚═════╝╚══════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     "
    echo -e "${NC}"

    echo -e "${DARK_GRAY}    ────────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    🧹 ${BOLD}DỌN DẸP HỆ THỐNG${NC} 🧹"
    echo -e "${DARK_GRAY}    ────────────────────────────────────────────────────────────────${NC}"
    echo

    echo -e "  🧩 ${GREEN}${BOLD}[1]${NC}  ${WHITE}Dọn gói mồ côi (Orphaned Packages)${NC}"
    echo -e "      ${GRAY}${DIM}Gỡ các gói không còn được phụ thuộc${NC}"
    echo

    echo -e "  💾 ${GREEN}${BOLD}[2]${NC}  ${WHITE}Dọn cache Pacman${NC}"
    echo -e "      ${GRAY}${DIM}Xóa các phiên bản cũ trong cache${NC}"
    echo

    echo -e "  📋 ${GREEN}${BOLD}[3]${NC}  ${WHITE}Xem gói cài thủ công${NC}"
    echo -e "      ${GRAY}${DIM}Hiển thị các gói được cài bằng tay${NC}"
    echo

    echo -e "  ${ICON_PACKAGE} ${GREEN}${BOLD}[4]${NC}  ${WHITE}Dọn AUR và cache${NC}"
    echo -e "      ${GRAY}${DIM}Dọn sạch gói AUR mồ côi và cache${NC}"
    echo

    echo -e "  🧧 ${GREEN}${BOLD}[5]${NC}  ${WHITE}Kiểm tra gói ngoại lai${NC}"
    echo -e "      ${GRAY}${DIM}Gói không còn trong repository${NC}"
    echo

    echo -e "  🔥 ${GREEN}${BOLD}[6]${NC}  ${WHITE}Dọn dẹp tự động (Safe Mode)${NC}"
    echo -e "      ${GRAY}${DIM}Chạy tất cả các thao tác dọn dẹp an toàn${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[7]${NC}  ${WHITE}Quay lại menu hệ thống${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu cấu hình hệ thống${NC}"
    echo

    echo -e "${DARK_GRAY}    ────────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-7${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ────────────────────────────────────────────────────────────────${NC}"
    echo

    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-7${DARK_GRAY}]${NC}: "
    local choice=$(read_single_key)
    echo "$choice"
    echo

    case $choice in
        1)
            # Dọn gói mồ côi
            print_boxed_message "Đang tìm kiếm các gói mồ côi..." "info"
            local orphans=$(pacman -Qdtq)
            if [ -z "$orphans" ]; then
                print_boxed_message "Không tìm thấy gói mồ côi nào. Hệ thống đã sạch!" "success"
            else
                echo -e "${YELLOW}${BOLD}Các gói mồ côi được tìm thấy:${NC}"
                pacman -Qdt
                if confirm_yn "Bạn có muốn gỡ tất cả các gói mồ côi này không?" "n"; then
                    sudo pacman -Rns $orphans && print_boxed_message "Đã gỡ thành công tất cả gói mồ côi!" "success"
                fi
            fi
            ;;
        2)
            # Dọn cache Pacman
            print_boxed_message "Đang dọn cache Pacman..." "info"
            if command -v paccache >/dev/null 2>&1; then
                sudo paccache -r && print_boxed_message "Đã dọn cache thành công!" "success"
            else
                print_boxed_message "paccache không được cài đặt. Cài đặt pacman-contrib trước." "warning"
            fi
            ;;
        3)
            # Xem gói cài thủ công
            echo -e "${YELLOW}${BOLD}Các gói được cài thủ công:${NC}"
            pacman -Qent
            ;;
        4)
            # Dọn AUR
            if command -v yay >/dev/null 2>&1; then
                yay -Yc && print_boxed_message "Đã dọn AUR thành công!" "success"
            elif command -v paru >/dev/null 2>&1; then
                paru -c && print_boxed_message "Đã dọn AUR thành công!" "success"
            else
                print_boxed_message "Không tìm thấy AUR helper (yay hoặc paru)" "warning"
            fi
            ;;
        5)
            # Kiểm tra gói ngoại lai
            echo -e "${YELLOW}${BOLD}Các gói ngoại lai:${NC}"
            pacman -Qm
            ;;
        6)
            # Dọn dẹp tự động
            print_boxed_message "Bắt đầu dọn dẹp tự động..." "info"
            # Gỡ gói mồ côi
            local orphans=$(pacman -Qdtq)
            if [ -n "$orphans" ]; then
                sudo pacman -Rns $orphans && echo "✓ Đã gỡ gói mồ côi"
            fi
            # Dọn cache
            if command -v paccache >/dev/null 2>&1; then
                sudo paccache -rk2 && echo "✓ Đã dọn cache pacman"
            fi
            # Dọn AUR
            if command -v yay >/dev/null 2>&1; then
                yay -Yc --noconfirm && echo "✓ Đã dọn AUR"
            fi
            print_boxed_message "🎉 Hoàn tất dọn dẹp tự động!" "success"
            ;;
        7)
            return 0
            ;;
        *)
            print_boxed_message "Lựa chọn không hợp lệ. Vui lòng chọn số từ 1-7." "error"
            ;;
    esac

    wait_for_user
}

# Hàm chính để quản lý cấu hình hệ thống
manage_system_configurations() {
    local choice

    while true; do
        display_system_menu
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-9${DARK_GRAY}]${NC}: "
        read -n 1 choice
        echo

        case $choice in
            1)
                configure_shell
                ;;
            2)
                configure_editor
                ;;
            3)
                configure_network
                ;;
            4)
                configure_services
                ;;
            5)
                create_backup
                ;;
            6)
                configure_window_manager
                ;;
            7)
                if declare -f configure_terminal >/dev/null 2>&1; then
                    configure_terminal
                else
                    print_boxed_message "Tính năng cấu hình terminal sẽ sớm được phát triển!" "info"
                fi
                ;;
            8)
                manage_system_cleanup
                ;;
            9)
                # Quay lại menu chính
                return 0
                ;;
            *)
                print_boxed_message "Lựa chọn không hợp lệ. Vui lòng chọn số từ 1-9." "error"
                ;;
        esac

        # Đợi người dùng nhấn phím bất kỳ để tiếp tục
        echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Nhấn ${LIGHT_GREEN}${BOLD}phím bất kỳ${NC}${WHITE} để quay lại menu cấu hình hệ thống..."
        read -n 1 -s
    done
}

# Hàm chính để cài đặt cấu hình (được gọi từ menu chính)
install_configurations() {
    manage_system_configurations
}
