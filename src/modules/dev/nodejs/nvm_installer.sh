#!/bin/bash

# Xác định đường dẫn thư mục hiện tại
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "${SCRIPT_DIR}/../../../core" && pwd)"

# Tải các module cần thiết
source "${SCRIPT_DIR}/utils.sh"
source "${CORE_DIR}/utils.sh"
source "${CORE_DIR}/ui.sh"

# Cài đặt NVM
install_nvm() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt NVM (Node Version Manager)...${NC}"

    show_spinner "Chuẩn bị cài đặt NVM" 1

    # Kiểm tra xem NVM đã được cài đặt chưa
    if [ -d "$HOME/.nvm" ]; then
        local current_version=$(get_nvm_version)
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
    if is_fish_shell; then
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

# Hiển thị thông tin về môi trường Node.js
show_nodejs_info() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Thông tin môi trường Node.js...${NC}"

    # Kiểm tra xem NVM đã được cài đặt chưa
    if ! check_nvm_installed; then
        print_boxed_message "NVM chưa được cài đặt." "info"
        return 0
    fi

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_NODE} ${BOLD}THÔNG TIN NODE.JS${NC} ${ICON_NODE}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Kiểm tra phiên bản NVM
    local nvm_version=$(get_nvm_version)

    if [ -n "$nvm_version" ]; then
        echo -e "  ${ICON_CHECK} ${GREEN}NVM:${NC} ${WHITE}v$nvm_version${NC}"
    else
        echo -e "  ${ICON_CROSS} ${RED}NVM:${NC} ${WHITE}Không được cài đặt${NC}"
    fi

    # Kiểm tra phiên bản Node.js
    local node_version=$(get_nodejs_version)

    if [ -n "$node_version" ]; then
        echo -e "  ${ICON_CHECK} ${GREEN}Node.js:${NC} ${WHITE}$node_version${NC}"
    else
        echo -e "  ${ICON_CROSS} ${RED}Node.js:${NC} ${WHITE}Không được cài đặt${NC}"
    fi

    # Kiểm tra phiên bản NPM
    local npm_version=$(get_npm_version)

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
        if is_fish_shell; then
            node_path=$(run_with_fish "which node" 2>/dev/null)
        else
            node_path=$(which node 2>/dev/null)
        fi
        echo -e "  ${ICON_FOLDER} ${YELLOW}Đường dẫn Node.js:${NC} ${WHITE}$node_path${NC}"
    fi

    # Hiển thị phiên bản mặc định
    if [ -n "$nvm_version" ]; then
        local default_version=""
        if is_fish_shell; then
            default_version=$(run_with_fish "nvm alias default" 2>/dev/null)
        else
            default_version=$(run_with_bash "nvm alias default" 2>/dev/null)
        fi
        echo -e "  ${ICON_STAR} ${YELLOW}Phiên bản mặc định:${NC} ${WHITE}$default_version${NC}"
    fi

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
}
