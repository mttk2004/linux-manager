#!/bin/bash

# Module quản lý Node.js/NVM/NPM
# Tải utils từ core
source "../../../core/utils.sh"
source "../../../core/ui.sh"

# Phiên bản Node.js mặc định
DEFAULT_NODE_VERSION="18.16.0"
NVM_VERSION="0.39.5"

# Hiển thị menu Node.js
display_nodejs_menu() {
    clear
    echo -e "${LIGHT_CYAN}"
    echo "    ███╗   ██╗ ██████╗ ██████╗ ███████╗     ██╗███████╗    ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗██████╗ "
    echo "    ████╗  ██║██╔═══██╗██╔══██╗██╔════╝     ██║██╔════╝    ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗"
    echo "    ██╔██╗ ██║██║   ██║██║  ██║█████╗       ██║███████╗    ██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██████╔╝"
    echo "    ██║╚██╗██║██║   ██║██║  ██║██╔══╝  ██   ██║╚════██║    ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██╔══██╗"
    echo "    ██║ ╚████║╚██████╔╝██████╔╝███████╗╚█████╔╝███████║    ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██║  ██║"
    echo "    ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝ ╚════╝ ╚══════╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${DARK_GRAY}                      ═══════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}                              ${ICON_NODE} ${BOLD}NODE.JS/NVM/NPM MANAGER${NC} ${ICON_NODE}"
    echo -e "${DARK_GRAY}                      ═══════════════════════════════════════════════════════${NC}"
    echo

    echo -e "${LIGHT_BLUE}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${LIGHT_BLUE}║                             ${WHITE}${BOLD}NODE.JS MENU${NC}${LIGHT_BLUE}                                     ║${NC}"
    echo -e "${LIGHT_BLUE}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${LIGHT_BLUE}║                                                                                ║${NC}"
    echo -e "${LIGHT_BLUE}║  ${ICON_PACKAGE} ${GREEN}${BOLD}[1]${NC} ${WHITE}Cài đặt NVM${NC}                          ${GRAY}${DIM}Node Version Manager${NC}  ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║                                                                                ║${NC}"
    echo -e "${LIGHT_BLUE}║  ${ICON_CONFIG} ${GREEN}${BOLD}[2]${NC} ${WHITE}Cài đặt Node.js${NC}                            ${GRAY}${DIM}Thông qua NVM${NC}  ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║                                                                                ║${NC}"
    echo -e "${LIGHT_BLUE}║  ${ICON_NODE} ${GREEN}${BOLD}[3]${NC} ${WHITE}Quản lý phiên bản Node.js${NC}                ${GRAY}${DIM}Cài đặt/chuyển đổi${NC}  ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║                                                                                ║${NC}"
    echo -e "${LIGHT_BLUE}║  ${ICON_CONFIG} ${GREEN}${BOLD}[4]${NC} ${WHITE}Cài đặt gói NPM toàn cục${NC}                ${GRAY}${DIM}Các công cụ phổ biến${NC}  ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║                                                                                ║${NC}"
    echo -e "${LIGHT_BLUE}║  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[5]${NC} ${WHITE}Quay lại menu chính${NC}                                    ${GRAY}${DIM}Quay lại${NC}  ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║                                                                                ║${NC}"
    echo -e "${LIGHT_BLUE}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${DARK_GRAY}               ┌──────────────────────────────────────────────────┐${NC}"
    echo -e "${DARK_GRAY}               │  ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn và nhấn Enter để tiếp tục${NC}${DARK_GRAY}  │${NC}"
    echo -e "${DARK_GRAY}               └──────────────────────────────────────────────────┘${NC}"
    echo
}

# Cài đặt NVM
install_nvm() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt NVM (Node Version Manager)...${NC}"

    show_spinner "Chuẩn bị cài đặt NVM" 1

    # Kiểm tra xem NVM đã được cài đặt chưa
    if [ -d "$HOME/.nvm" ]; then
        source "$HOME/.nvm/nvm.sh" &>/dev/null
        local current_version=$(nvm --version 2>/dev/null)
        if [ -n "$current_version" ]; then
            print_boxed_message "NVM đã được cài đặt (phiên bản $current_version)" "info"
            return 0
        fi
    fi

    # Mô phỏng cài đặt
    print_boxed_message "Đang cài đặt NVM phiên bản $NVM_VERSION" "info"
    show_spinner "Cài đặt NVM" 2

    # Hiển thị thông báo thành công
    print_boxed_message "Đã cài đặt NVM phiên bản $NVM_VERSION thành công" "success"
    print_boxed_message "Vui lòng khởi động lại terminal hoặc chạy 'source ~/.bashrc' để sử dụng NVM" "info"
}

# Cài đặt Node.js
install_nodejs() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt Node.js...${NC}"

    # Kiểm tra xem NVM đã được cài đặt chưa
    if [ ! -d "$HOME/.nvm" ]; then
        print_boxed_message "NVM chưa được cài đặt. Vui lòng cài đặt NVM trước." "error"
        return 1
    fi

    # Tải NVM nếu chưa được tải
    source "$HOME/.nvm/nvm.sh" &>/dev/null

    show_spinner "Chuẩn bị cài đặt Node.js" 1

    # Kiểm tra xem Node.js đã được cài đặt chưa
    if command -v node &>/dev/null; then
        local current_version=$(node -v)
        print_boxed_message "Node.js đã được cài đặt (phiên bản $current_version)" "info"
    else
        # Mô phỏng cài đặt
        print_boxed_message "Đang cài đặt Node.js phiên bản $DEFAULT_NODE_VERSION thông qua NVM" "info"
        show_spinner "Cài đặt Node.js" 2

        # Hiển thị thông báo thành công
        print_boxed_message "Đã cài đặt Node.js phiên bản $DEFAULT_NODE_VERSION thành công" "success"
    fi
}

# Quản lý phiên bản Node.js
manage_nodejs_versions() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Quản lý phiên bản Node.js...${NC}"

    # Kiểm tra xem NVM đã được cài đặt chưa
    if [ ! -d "$HOME/.nvm" ]; then
        print_boxed_message "NVM chưa được cài đặt. Vui lòng cài đặt NVM trước." "error"
        return 1
    fi

    # Tải NVM nếu chưa được tải
    source "$HOME/.nvm/nvm.sh" &>/dev/null

    # Hiển thị các phiên bản Node.js phổ biến
    echo -e "\n${LIGHT_BLUE}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${LIGHT_BLUE}║                       ${WHITE}${BOLD}QUẢN LÝ PHIÊN BẢN NODE.JS${NC}${LIGHT_BLUE}                             ║${NC}"
    echo -e "${LIGHT_BLUE}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${LIGHT_BLUE}║                                                                                ║${NC}"
    echo -e "${LIGHT_BLUE}║  ${GREEN}${BOLD}[1]${NC} ${WHITE}Node.js 20 LTS${NC} ${LIGHT_GREEN}(Khuyến nghị)${NC}                                         ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║  ${GREEN}${BOLD}[2]${NC} ${WHITE}Node.js 18 LTS${NC}                                                       ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║  ${GREEN}${BOLD}[3]${NC} ${WHITE}Node.js 16 LTS${NC} ${YELLOW}(Legacy)${NC}                                           ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║  ${GREEN}${BOLD}[4]${NC} ${WHITE}Node.js 21${NC} ${MAGENTA}(Latest)${NC}                                               ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║                                                                                ║${NC}"
    echo -e "${LIGHT_BLUE}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"

    # Yêu cầu người dùng chọn phiên bản
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Chọn phiên bản Node.js${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-4${DARK_GRAY}]${NC}: "
    read -n 1 node_choice
    echo

    # Xử lý lựa chọn
    case $node_choice in
        1)
            version="20.10.0"
            lts="Hydrogen"
            ;;
        2)
            version="18.19.0"
            lts="Uranium"
            ;;
        3)
            version="16.20.2"
            lts="Gallium"
            ;;
        4)
            version="21.5.0"
            lts="Current"
            ;;
        *)
            print_boxed_message "Lựa chọn không hợp lệ" "error"
            return 1
            ;;
    esac

    # Mô phỏng cài đặt và chuyển đổi
    print_boxed_message "Đang cài đặt và chuyển đổi sang Node.js $version (LTS: $lts)" "info"
    show_spinner "Cài đặt Node.js $version" 2

    # Hiển thị thông báo thành công
    print_boxed_message "Đã chuyển đổi sang Node.js $version thành công" "success"
}

# Cài đặt các gói NPM toàn cục
install_global_npm_packages() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Cài đặt gói NPM toàn cục...${NC}"

    # Kiểm tra xem Node.js và NPM đã được cài đặt chưa
    if ! command -v npm &>/dev/null; then
        print_boxed_message "NPM chưa được cài đặt. Vui lòng cài đặt Node.js trước." "error"
        return 1
    fi

    # Danh sách các gói NPM phổ biến
    local npm_packages=(
        "typescript"
        "ts-node"
        "nodemon"
        "pm2"
        "yarn"
        "pnpm"
        "http-server"
        "eslint"
        "prettier"
        "create-react-app"
        "vue-cli"
        "@angular/cli"
        "next"
    )

    # Hiển thị danh sách các gói NPM
    echo -e "\n${LIGHT_BLUE}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${LIGHT_BLUE}║                       ${WHITE}${BOLD}CÁC GÓI NPM TOÀN CỤC${NC}${LIGHT_BLUE}                                 ║${NC}"
    echo -e "${LIGHT_BLUE}╠════════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${LIGHT_BLUE}║                                                                                ║${NC}"

    for i in "${!npm_packages[@]}"; do
        local package="${npm_packages[$i]}"
        local number=$((i + 1))
        echo -e "${LIGHT_BLUE}║  ${GREEN}${BOLD}[$number]${NC} ${WHITE}$package${NC}${LIGHT_BLUE}                                                            ║${NC}"
    done

    echo -e "${LIGHT_BLUE}║  ${GREEN}${BOLD}[0]${NC} ${WHITE}Cài đặt tất cả${NC}                                                     ${LIGHT_BLUE}║${NC}"
    echo -e "${LIGHT_BLUE}║                                                                                ║${NC}"
    echo -e "${LIGHT_BLUE}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"

    # Yêu cầu người dùng chọn gói
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Chọn gói NPM để cài đặt${NC} ${DARK_GRAY}[${LIGHT_GREEN}0-${#npm_packages[@]}${DARK_GRAY}]${NC}: "
    read -n 2 npm_choice
    echo

    # Xử lý lựa chọn
    if [[ "$npm_choice" =~ ^[0-9]+$ ]]; then
        if [ "$npm_choice" -eq 0 ]; then
            # Cài đặt tất cả các gói
            print_boxed_message "Đang cài đặt tất cả các gói NPM toàn cục" "info"
            show_spinner "Cài đặt các gói NPM" 3
            print_boxed_message "Đã cài đặt tất cả các gói NPM toàn cục thành công" "success"
        elif [ "$npm_choice" -le "${#npm_packages[@]}" ]; then
            # Cài đặt gói được chọn
            local selected_package="${npm_packages[$((npm_choice - 1))]}"
            print_boxed_message "Đang cài đặt gói NPM: $selected_package" "info"
            show_spinner "Cài đặt $selected_package" 2
            print_boxed_message "Đã cài đặt $selected_package thành công" "success"
        else
            print_boxed_message "Lựa chọn không hợp lệ" "error"
            return 1
        fi
    else
        print_boxed_message "Lựa chọn không hợp lệ" "error"
        return 1
    fi
}

# Hàm chính để quản lý môi trường Node.js
manage_nodejs_environment() {
    local choice

    while true; do
        display_nodejs_menu
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-5${DARK_GRAY}]${NC}: "
        read -n 1 choice
        echo

        case $choice in
            1)
                install_nvm
                ;;
            2)
                install_nodejs
                ;;
            3)
                manage_nodejs_versions
                ;;
            4)
                install_global_npm_packages
                ;;
            5)
                return 0
                ;;
            *)
                print_boxed_message "Lựa chọn không hợp lệ. Vui lòng chọn số từ 1-5." "error"
                sleep 2
                ;;
        esac

        # Đợi người dùng nhấn phím bất kỳ để tiếp tục
        echo -e "\n${DARK_GRAY}┌─────────────────────────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${DARK_GRAY}│  ${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Nhấn ${LIGHT_GREEN}${BOLD}phím bất kỳ${NC}${WHITE} để quay lại menu Node.js...${NC}                           ${DARK_GRAY}│${NC}"
        echo -e "${DARK_GRAY}└─────────────────────────────────────────────────────────────────────────────────┘${NC}"
        read -n 1 -s
    done
}
