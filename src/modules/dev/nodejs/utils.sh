#!/bin/bash

# Xác định đường dẫn thư mục hiện tại
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "${SCRIPT_DIR}/../../../core" && pwd)"

# Các hằng số và biến toàn cục
DEFAULT_NODE_VERSION="18.16.0"
NVM_VERSION="0.39.7"

# Kiểm tra shell hiện tại có phải là fish không
is_fish_shell() {
    if [ "$SHELL" == "/sbin/fish" ] || [ "$SHELL" == "/usr/bin/fish" ] || [ "$SHELL" == "/bin/fish" ]; then
        return 0
    else
        return 1
    fi
}

# Thực thi lệnh với fish shell
run_with_fish() {
    local command="$1"
    fish -c "$command"
}

# Thực thi lệnh với bash shell (qua nvm)
run_with_bash() {
    local command="$1"
    source "$HOME/.nvm/nvm.sh" &>/dev/null
    eval "$command"
}

# Thực thi lệnh dựa vào shell hiện tại
run_command() {
    local command="$1"
    if is_fish_shell; then
        run_with_fish "$command"
    else
        run_with_bash "$command"
    fi
}

# Kiểm tra xem NVM đã được cài đặt chưa
check_nvm_installed() {
    if [ ! -d "$HOME/.nvm" ]; then
        return 1
    fi
    return 0
}

# Kiểm tra xem Node.js đã được cài đặt chưa
check_nodejs_installed() {
    local node_installed=false
    if is_fish_shell; then
        if run_with_fish "node -v" &>/dev/null; then
            node_installed=true
        fi
    else
        if command -v node &>/dev/null; then
            node_installed=true
        fi
    fi

    if [ "$node_installed" = true ]; then
        return 0
    else
        return 1
    fi
}

# Lấy phiên bản Node.js hiện tại
get_nodejs_version() {
    if is_fish_shell; then
        run_with_fish "node -v" 2>/dev/null
    else
        node -v 2>/dev/null
    fi
}

# Lấy phiên bản NVM hiện tại
get_nvm_version() {
    if is_fish_shell; then
        run_with_fish "nvm --version" 2>/dev/null
    else
        source "$HOME/.nvm/nvm.sh" &>/dev/null
        nvm --version 2>/dev/null
    fi
}

# Lấy phiên bản NPM hiện tại
get_npm_version() {
    if is_fish_shell; then
        run_with_fish "npm -v" 2>/dev/null
    else
        npm -v 2>/dev/null
    fi
}
