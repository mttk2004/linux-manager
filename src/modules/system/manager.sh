#!/bin/bash

# Module quản lý cấu hình hệ thống

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

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[6]${NC}  ${WHITE}Quay lại menu chính${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu chính${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-6${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
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

# Hàm chính để quản lý cấu hình hệ thống
manage_system_configurations() {
    local choice

    while true; do
        display_system_menu
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-6${DARK_GRAY}]${NC}: "
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
                # Quay lại menu chính
                return 0
                ;;
            *)
                print_boxed_message "Lựa chọn không hợp lệ. Vui lòng chọn số từ 1-6." "error"
                sleep 2
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
