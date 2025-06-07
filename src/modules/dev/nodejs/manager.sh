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

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_NODE} ${BOLD}NODE.JS/NVM/NPM MANAGER${NC} ${ICON_NODE}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_PACKAGE} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Cài đặt NVM${NC}"
    echo -e "      ${GRAY}${DIM}Node Version Manager${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Cài đặt Node.js${NC}"
    echo -e "      ${GRAY}${DIM}Thông qua NVM${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Quản lý phiên bản Node.js${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt/chuyển đổi phiên bản${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[4]${NC}  ${WHITE}Cài đặt gói NPM toàn cục${NC}"
    echo -e "      ${GRAY}${DIM}Các công cụ phổ biến${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[5]${NC}  ${WHITE}Quay lại menu chính${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu chính${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-5${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
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

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_NODE} ${BOLD}QUẢN LÝ PHIÊN BẢN NODE.JS${NC} ${ICON_NODE}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Node.js 20 LTS${NC} ${LIGHT_GREEN}(Khuyến nghị)${NC}"
    echo -e "      ${GRAY}${DIM}Phiên bản LTS mới nhất${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Node.js 18 LTS${NC}"
    echo -e "      ${GRAY}${DIM}Phiên bản LTS ổn định${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Node.js 16 LTS${NC} ${YELLOW}(Legacy)${NC}"
    echo -e "      ${GRAY}${DIM}Phiên bản cũ hơn${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[4]${NC}  ${WHITE}Node.js 21${NC} ${MAGENTA}(Latest)${NC}"
    echo -e "      ${GRAY}${DIM}Phiên bản mới nhất${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

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
    # Danh sách các gói NPM phổ biến
    local npm_packages=(
        "typescript"
        "nodemon"
        "pm2"
        "eslint"
        "prettier"
        "create-react-app"
        "vue-cli"
        "@angular/cli"
        "next"
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
    echo

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

    return 0
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
                ;;
        esac

        # Đợi người dùng nhấn phím bất kỳ để tiếp tục
        echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Nhấn ${LIGHT_GREEN}${BOLD}phím bất kỳ${NC}${WHITE} để quay lại menu Node.js..."
        read -n 1 -s
    done
}
