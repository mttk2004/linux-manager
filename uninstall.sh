#!/bin/bash

# Script gỡ cài đặt Linux Manager

# Xác định thư mục hiện tại
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Hàm xác nhận gỡ cài đặt
confirm_uninstall() {
    echo -e "\033[1;33m⚠ CẢNH BÁO: Bạn sắp gỡ cài đặt Linux Manager và xóa tất cả dữ liệu liên quan.\033[0m"
    echo -e "\033[1;31mThao tác này không thể hoàn tác!\033[0m"
    read -p "Bạn có chắc chắn muốn tiếp tục? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Đã hủy gỡ cài đặt."
        exit 0
    fi
}

# Hàm gỡ cài đặt
uninstall() {
    echo "Đang gỡ cài đặt Linux Manager..."

    # Xóa thư mục src
    if [ -d "$CURRENT_DIR/src" ]; then
        echo "Xóa thư mục src..."
        rm -rf "$CURRENT_DIR/src"
    fi

    # Xóa thư mục bin
    if [ -d "$CURRENT_DIR/bin" ]; then
        echo "Xóa thư mục bin..."
        rm -rf "$CURRENT_DIR/bin"
    fi

    # Xóa thư mục logs
    if [ -d "$CURRENT_DIR/logs" ]; then
        echo "Xóa thư mục logs..."
        rm -rf "$CURRENT_DIR/logs"
    fi

    # Giữ lại các tập tin gốc để có thể cài đặt lại
    echo "Đã gỡ cài đặt Linux Manager thành công!"
    echo "Các tập tin gốc (manager.sh, config.sh, utils.sh, install_packages.sh) vẫn được giữ lại để bạn có thể cài đặt lại sau này."
}

# Hàm chính
main() {
    confirm_uninstall
    uninstall
}

# Chạy script
main
