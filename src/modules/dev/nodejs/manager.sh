#!/bin/bash

# Module quản lý Node.js/NVM/NPM
# Tải utils từ core
source "../../../core/utils.sh"
source "../../../core/ui.sh"

# Phiên bản Node.js mặc định
DEFAULT_NODE_VERSION="18.16.0"
NVM_VERSION="0.39.7"

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
    echo -e "  ${ICON_INFO} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Xem thông tin môi trường${NC}"
    echo -e "      ${GRAY}${DIM}Hiển thị thông tin Node.js, NVM, NPM${NC}"
    echo

    echo -e "  ${ICON_PACKAGE} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Cài đặt NVM${NC}"
    echo -e "      ${GRAY}${DIM}Node Version Manager${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Cài đặt Node.js${NC}"
    echo -e "      ${GRAY}${DIM}Thông qua NVM${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[4]${NC}  ${WHITE}Quản lý phiên bản Node.js${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt/chuyển đổi phiên bản${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[5]${NC}  ${WHITE}Cài đặt gói NPM toàn cục${NC}"
    echo -e "      ${GRAY}${DIM}Các công cụ phổ biến${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[6]${NC}  ${WHITE}Quay lại menu chính${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu chính${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-6${NC}${WHITE} và nhấn Enter${NC}"
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

    # Cài đặt NVM thực tế
    print_boxed_message "Đang cài đặt NVM phiên bản $NVM_VERSION" "info"
    show_spinner "Tải xuống script cài đặt NVM" 1

    # Tải và cài đặt NVM
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh" | bash

    # Kiểm tra kết quả cài đặt
    if [ ! -d "$HOME/.nvm" ]; then
        print_boxed_message "Cài đặt NVM không thành công. Vui lòng thử lại." "error"
        return 1
    fi

    # Cấu hình cho Fish shell nếu đang sử dụng
    if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
        print_boxed_message "Phát hiện Fish shell, đang cấu hình NVM cho Fish..." "info"
        show_spinner "Cài đặt nvm.fish" 1

        # Tạo thư mục functions nếu chưa tồn tại
        mkdir -p "$HOME/.config/fish/functions"

        # Tải nvm.fish
        curl -sL https://git.io/nvm.fish > "$HOME/.config/fish/functions/nvm.fish"

        # Thêm vào fish config nếu chưa có
        if ! grep -q "nvm.fish" "$HOME/.config/fish/config.fish" 2>/dev/null; then
            echo '# NVM configuration' >> "$HOME/.config/fish/config.fish"
            echo 'source ~/.config/fish/functions/nvm.fish' >> "$HOME/.config/fish/config.fish"
        fi

        print_boxed_message "Đã cấu hình NVM cho Fish shell" "success"
    fi

    # Hiển thị thông báo thành công
    print_boxed_message "Đã cài đặt NVM phiên bản $NVM_VERSION thành công" "success"
    print_boxed_message "Vui lòng khởi động lại terminal hoặc chạy 'source ~/.bashrc' (bash) hoặc mở terminal mới (fish) để sử dụng NVM" "info"
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

    # Hiển thị menu lựa chọn phiên bản Node.js
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_NODE} ${BOLD}CÀI ĐẶT NODE.JS${NC} ${ICON_NODE}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Node.js LTS${NC} ${LIGHT_GREEN}(Khuyến nghị)${NC}"
    echo -e "      ${GRAY}${DIM}Phiên bản LTS mới nhất${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Node.js Latest${NC}"
    echo -e "      ${GRAY}${DIM}Phiên bản mới nhất${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Node.js Cụ thể${NC}"
    echo -e "      ${GRAY}${DIM}Chọn phiên bản cụ thể${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Yêu cầu người dùng chọn phiên bản
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Chọn phiên bản Node.js${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-3${DARK_GRAY}]${NC}: "
    read -n 1 node_choice
    echo

    # Xử lý lựa chọn
    case $node_choice in
        1)
            version="--lts"
            version_desc="LTS"
            ;;
        2)
            version="node"
            version_desc="Latest"
            ;;
        3)
            echo
            echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập phiên bản Node.js (ví dụ: 18, 20.10.0)${NC}: "
            read version
            version_desc="$version"
            ;;
        *)
            print_boxed_message "Lựa chọn không hợp lệ" "error"
            return 1
            ;;
    esac

    # Cài đặt Node.js thông qua NVM
    print_boxed_message "Đang cài đặt Node.js phiên bản $version_desc thông qua NVM" "info"
    show_spinner "Cài đặt Node.js" 2

    # Thực hiện cài đặt thông qua NVM
    if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
        # Với Fish shell, sử dụng nvm.fish
        if [ "$version" == "--lts" ]; then
            fish -c "nvm install --lts"
        else
            fish -c "nvm install $version"
        fi
    else
        # Với Bash hoặc shells khác
        source "$HOME/.nvm/nvm.sh"
        nvm install $version
    fi

    # Kiểm tra kết quả cài đặt
    if [ $? -ne 0 ]; then
        print_boxed_message "Cài đặt Node.js không thành công. Vui lòng thử lại." "error"
        return 1
    fi

    # Đặt phiên bản mặc định
    if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
        if [ "$version" == "--lts" ]; then
            fish -c "nvm use --lts"
            fish -c "nvm alias default 'lts/*'"
        else
            fish -c "nvm use $version"
            fish -c "nvm alias default $version"
        fi
    else
        source "$HOME/.nvm/nvm.sh"
        if [ "$version" == "--lts" ]; then
            nvm use --lts
            nvm alias default 'lts/*'
        else
            nvm use $version
            nvm alias default $version
        fi
    fi

    # Lấy phiên bản đã cài đặt
    local installed_version=""
    if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
        installed_version=$(fish -c "node -v" 2>/dev/null)
    else
        installed_version=$(node -v 2>/dev/null)
    fi

    # Hiển thị thông báo thành công
    print_boxed_message "Đã cài đặt Node.js phiên bản $installed_version thành công" "success"
    print_boxed_message "NPM đã được cài đặt kèm theo Node.js" "info"
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
    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Liệt kê phiên bản đã cài đặt${NC}"
    echo -e "      ${GRAY}${DIM}Xem các phiên bản Node.js đã cài đặt${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Liệt kê phiên bản có sẵn${NC}"
    echo -e "      ${GRAY}${DIM}Xem các phiên bản Node.js có thể cài đặt${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Chuyển đổi phiên bản${NC}"
    echo -e "      ${GRAY}${DIM}Chọn phiên bản Node.js để sử dụng${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[4]${NC}  ${WHITE}Đặt phiên bản mặc định${NC}"
    echo -e "      ${GRAY}${DIM}Đặt phiên bản Node.js mặc định${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[5]${NC}  ${WHITE}Gỡ cài đặt phiên bản${NC}"
    echo -e "      ${GRAY}${DIM}Xóa phiên bản Node.js đã cài đặt${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[6]${NC}  ${WHITE}Quay lại${NC}"
    echo -e "      ${GRAY}${DIM}Quay lại menu trước${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Yêu cầu người dùng chọn tùy chọn
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Chọn tùy chọn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-6${DARK_GRAY}]${NC}: "
    read -n 1 version_choice
    echo

    # Xử lý lựa chọn
    case $version_choice in
        1)
            # Liệt kê phiên bản đã cài đặt
            print_boxed_message "Đang liệt kê các phiên bản Node.js đã cài đặt" "info"

            if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
                fish -c "nvm list"
            else
                source "$HOME/.nvm/nvm.sh"
                nvm ls
            fi

            echo
            print_boxed_message "Đã liệt kê các phiên bản Node.js đã cài đặt" "success"
            ;;

        2)
            # Liệt kê phiên bản có sẵn
            print_boxed_message "Đang liệt kê các phiên bản Node.js có sẵn (LTS)" "info"
            print_boxed_message "Quá trình này có thể mất một chút thời gian" "info"

            if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
                fish -c "nvm ls-remote --lts | grep -i 'lts' | tail -n 10"
            else
                source "$HOME/.nvm/nvm.sh"
                nvm ls-remote --lts | grep -i 'lts' | tail -n 10
            fi

            echo
            print_boxed_message "Đã liệt kê các phiên bản Node.js có sẵn" "success"
            ;;

        3)
            # Chuyển đổi phiên bản
            echo
            echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập phiên bản Node.js muốn sử dụng${NC} (ví dụ: 18, 20, --lts): "
            read version_to_use

            print_boxed_message "Đang chuyển đổi sang Node.js phiên bản $version_to_use" "info"

            if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
                fish -c "nvm use $version_to_use"
            else
                source "$HOME/.nvm/nvm.sh"
                nvm use $version_to_use
            fi

            if [ $? -eq 0 ]; then
                print_boxed_message "Đã chuyển đổi sang Node.js phiên bản $version_to_use thành công" "success"
            else
                print_boxed_message "Không thể chuyển đổi sang phiên bản $version_to_use. Phiên bản này có thể chưa được cài đặt." "error"
            fi
            ;;

        4)
            # Đặt phiên bản mặc định
            echo
            echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập phiên bản Node.js muốn đặt làm mặc định${NC} (ví dụ: 18, 20, lts/*): "
            read default_version

            print_boxed_message "Đang đặt Node.js phiên bản $default_version làm mặc định" "info"

            if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
                fish -c "nvm alias default $default_version"
            else
                source "$HOME/.nvm/nvm.sh"
                nvm alias default $default_version
            fi

            if [ $? -eq 0 ]; then
                print_boxed_message "Đã đặt Node.js phiên bản $default_version làm mặc định thành công" "success"
            else
                print_boxed_message "Không thể đặt phiên bản $default_version làm mặc định. Phiên bản này có thể chưa được cài đặt." "error"
            fi
            ;;

        5)
            # Gỡ cài đặt phiên bản
            echo
            echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập phiên bản Node.js muốn gỡ cài đặt${NC} (ví dụ: 18, 20.10.0): "
            read version_to_uninstall

            print_boxed_message "Đang gỡ cài đặt Node.js phiên bản $version_to_uninstall" "info"

            if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
                fish -c "nvm uninstall $version_to_uninstall"
            else
                source "$HOME/.nvm/nvm.sh"
                nvm uninstall $version_to_uninstall
            fi

            if [ $? -eq 0 ]; then
                print_boxed_message "Đã gỡ cài đặt Node.js phiên bản $version_to_uninstall thành công" "success"
            else
                print_boxed_message "Không thể gỡ cài đặt phiên bản $version_to_uninstall. Phiên bản này có thể không tồn tại hoặc đang được sử dụng." "error"
            fi
            ;;

        6)
            # Quay lại menu trước
            return 0
            ;;

        *)
            print_boxed_message "Lựa chọn không hợp lệ. Vui lòng chọn số từ 1-6." "error"
            ;;
    esac

    return 0
}

# Cài đặt các gói NPM toàn cục
install_global_npm_packages() {
    # Kiểm tra xem NVM đã được cài đặt chưa
    if [ ! -d "$HOME/.nvm" ]; then
        print_boxed_message "NVM chưa được cài đặt. Vui lòng cài đặt NVM trước." "error"
        return 1
    fi

    # Tải NVM nếu chưa được tải
    source "$HOME/.nvm/nvm.sh" &>/dev/null

    # Kiểm tra xem Node.js đã được cài đặt chưa
    local node_installed=false
    if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
        if fish -c "node -v" &>/dev/null; then
            node_installed=true
        fi
    else
        if command -v node &>/dev/null; then
            node_installed=true
        fi
    fi

    if [ "$node_installed" = false ]; then
        print_boxed_message "Node.js chưa được cài đặt. Vui lòng cài đặt Node.js trước." "error"
        return 1
    fi

    # Danh sách các gói NPM phổ biến
    local npm_packages=(
        "typescript"
        "nodemon"
        "pm2"
        "eslint"
        "prettier"
        "create-react-app"
        "@vue/cli"
        "@angular/cli"
        "next"
        "sass"
        "gulp"
        "webpack"
        "yarn"
        "pnpm"
        "http-server"
        "ts-node"
        "rimraf"
        "npm-check-updates"
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
    echo -e "  ${GREEN}${BOLD}[C]${NC} ${WHITE}Cài đặt gói tùy chỉnh${NC}"
    echo

    # Yêu cầu người dùng chọn gói
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Chọn gói NPM để cài đặt${NC} ${DARK_GRAY}[${LIGHT_GREEN}0-${#npm_packages[@]} hoặc C${DARK_GRAY}]${NC}: "
    read npm_choice
    echo

    # Xử lý lựa chọn
    if [[ "$npm_choice" =~ ^[0-9]+$ ]]; then
        if [ "$npm_choice" -eq 0 ]; then
            # Cài đặt tất cả các gói
            print_boxed_message "Đang cài đặt tất cả các gói NPM toàn cục" "info"
            show_spinner "Chuẩn bị cài đặt các gói NPM" 1

            for package in "${npm_packages[@]}"; do
                print_boxed_message "Đang cài đặt $package..." "info"

                if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
                    fish -c "npm install -g $package"
                else
                    source "$HOME/.nvm/nvm.sh"
                    npm install -g $package
                fi

                if [ $? -eq 0 ]; then
                    print_boxed_message "Đã cài đặt $package thành công" "success"
                else
                    print_boxed_message "Không thể cài đặt $package" "error"
                fi
            done

            print_boxed_message "Đã cài đặt tất cả các gói NPM toàn cục thành công" "success"
        elif [ "$npm_choice" -le "${#npm_packages[@]}" ]; then
            # Cài đặt gói được chọn
            local selected_package="${npm_packages[$((npm_choice - 1))]}"
            print_boxed_message "Đang cài đặt gói NPM: $selected_package" "info"
            show_spinner "Chuẩn bị cài đặt $selected_package" 1

            if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
                fish -c "npm install -g $selected_package"
            else
                source "$HOME/.nvm/nvm.sh"
                npm install -g $selected_package
            fi

            if [ $? -eq 0 ]; then
                print_boxed_message "Đã cài đặt $selected_package thành công" "success"
            else
                print_boxed_message "Không thể cài đặt $selected_package" "error"
            fi
        else
            print_boxed_message "Lựa chọn không hợp lệ" "error"
            return 1
        fi
    elif [[ "$npm_choice" =~ ^[Cc]$ ]]; then
        # Cài đặt gói tùy chỉnh
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập tên gói NPM muốn cài đặt${NC}: "
        read custom_package

        if [ -z "$custom_package" ]; then
            print_boxed_message "Tên gói không được để trống" "error"
            return 1
        fi

        print_boxed_message "Đang cài đặt gói NPM: $custom_package" "info"
        show_spinner "Chuẩn bị cài đặt $custom_package" 1

        if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
            fish -c "npm install -g $custom_package"
        else
            source "$HOME/.nvm/nvm.sh"
            npm install -g $custom_package
        fi

        if [ $? -eq 0 ]; then
            print_boxed_message "Đã cài đặt $custom_package thành công" "success"
        else
            print_boxed_message "Không thể cài đặt $custom_package" "error"
        fi
    else
        print_boxed_message "Lựa chọn không hợp lệ" "error"
        return 1
    fi

    return 0
}

# Hiển thị thông tin về môi trường Node.js
show_nodejs_info() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Thông tin môi trường Node.js...${NC}"

    # Kiểm tra xem NVM đã được cài đặt chưa
    if [ ! -d "$HOME/.nvm" ]; then
        print_boxed_message "NVM chưa được cài đặt." "info"
        return 0
    fi

    # Tải NVM nếu chưa được tải
    source "$HOME/.nvm/nvm.sh" &>/dev/null

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_NODE} ${BOLD}THÔNG TIN NODE.JS${NC} ${ICON_NODE}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Kiểm tra phiên bản NVM
    local nvm_version=""
    if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
        nvm_version=$(fish -c "nvm --version" 2>/dev/null)
    else
        nvm_version=$(nvm --version 2>/dev/null)
    fi

    if [ -n "$nvm_version" ]; then
        echo -e "  ${ICON_CHECK} ${GREEN}NVM:${NC} ${WHITE}v$nvm_version${NC}"
    else
        echo -e "  ${ICON_CROSS} ${RED}NVM:${NC} ${WHITE}Không được cài đặt${NC}"
    fi

    # Kiểm tra phiên bản Node.js
    local node_version=""
    if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
        node_version=$(fish -c "node -v" 2>/dev/null)
    else
        node_version=$(node -v 2>/dev/null)
    fi

    if [ -n "$node_version" ]; then
        echo -e "  ${ICON_CHECK} ${GREEN}Node.js:${NC} ${WHITE}$node_version${NC}"
    else
        echo -e "  ${ICON_CROSS} ${RED}Node.js:${NC} ${WHITE}Không được cài đặt${NC}"
    fi

    # Kiểm tra phiên bản NPM
    local npm_version=""
    if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
        npm_version=$(fish -c "npm -v" 2>/dev/null)
    else
        npm_version=$(npm -v 2>/dev/null)
    fi

    if [ -n "$npm_version" ]; then
        echo -e "  ${ICON_CHECK} ${GREEN}NPM:${NC} ${WHITE}v$npm_version${NC}"
    else
        echo -e "  ${ICON_CROSS} ${RED}NPM:${NC} ${WHITE}Không được cài đặt${NC}"
    fi

    # Hiển thị đường dẫn cài đặt
    if [ -d "$HOME/.nvm" ]; then
        echo -e "\n  ${ICON_FOLDER} ${YELLOW}Đường dẫn NVM:${NC} ${WHITE}$HOME/.nvm${NC}"
    fi

    if [ -n "$node_version" ]; then
        local node_path=""
        if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
            node_path=$(fish -c "which node" 2>/dev/null)
        else
            node_path=$(which node 2>/dev/null)
        fi
        echo -e "  ${ICON_FOLDER} ${YELLOW}Đường dẫn Node.js:${NC} ${WHITE}$node_path${NC}"
    fi

    # Hiển thị phiên bản mặc định
    if [ -n "$nvm_version" ]; then
        local default_version=""
        if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
            default_version=$(fish -c "nvm alias default" 2>/dev/null)
        else
            default_version=$(nvm alias default 2>/dev/null)
        fi
        echo -e "  ${ICON_STAR} ${YELLOW}Phiên bản mặc định:${NC} ${WHITE}$default_version${NC}"
    fi

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
}

# Hàm chính để quản lý môi trường Node.js
manage_nodejs_environment() {
    local choice

    while true; do
        display_nodejs_menu
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-6${DARK_GRAY}]${NC}: "
        read -n 1 choice
        echo

        case $choice in
            1)
                show_nodejs_info
                ;;
            2)
                install_nvm
                ;;
            3)
                install_nodejs
                ;;
            4)
                manage_nodejs_versions
                ;;
            5)
                install_global_npm_packages
                ;;
            6)
                return 0
                ;;
            *)
                print_boxed_message "Lựa chọn không hợp lệ. Vui lòng chọn số từ 1-6." "error"
                ;;
        esac

        # Đợi người dùng nhấn phím bất kỳ để tiếp tục
        echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Nhấn ${LIGHT_GREEN}${BOLD}phím bất kỳ${NC}${WHITE} để quay lại menu Node.js..."
        read -n 1 -s
    done
}
