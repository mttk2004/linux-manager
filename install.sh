#!/bin/bash

# Script cài đặt Linux Manager với cấu trúc thư mục mới

# Xác định thư mục hiện tại
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Tạo cấu trúc thư mục mới
create_directory_structure() {
    echo "Tạo cấu trúc thư mục mới..."

    # Tạo thư mục chính
    mkdir -p "$CURRENT_DIR/src/core"
    mkdir -p "$CURRENT_DIR/src/modules/packages"
    mkdir -p "$CURRENT_DIR/src/modules/system"
    mkdir -p "$CURRENT_DIR/src/modules/dev/php"
    mkdir -p "$CURRENT_DIR/src/modules/dev/nodejs"
    mkdir -p "$CURRENT_DIR/src/modules/dev/docker"
    mkdir -p "$CURRENT_DIR/src/modules/misc"
    mkdir -p "$CURRENT_DIR/src/data/packages"
    mkdir -p "$CURRENT_DIR/src/data/configs"
    mkdir -p "$CURRENT_DIR/logs"
    mkdir -p "$CURRENT_DIR/bin"

    echo "Đã tạo xong cấu trúc thư mục!"
}

# Cập nhật cấu hình core
update_core_config() {
    echo "Cập nhật cấu hình core..."

    # Tạo cấu hình mới cho việc đọc danh sách gói từ tập tin
    echo '#!/bin/bash

# Cấu hình chung
APP_NAME="Kiet Linux Manager"
APP_VERSION="2.1"
APP_AUTHOR="Kiet"

# Đường dẫn dữ liệu
DATA_DIR="../data"
PACKAGES_DIR="$DATA_DIR/packages"
CONFIGS_DIR="$DATA_DIR/configs"

# Tải danh sách gói
load_package_list() {
    local list_file="$PACKAGES_DIR/$1.list"
    if [ -f "$list_file" ]; then
        mapfile -t PACKAGES < "$list_file"
        return 0
    else
        echo "Lỗi: Không tìm thấy tập tin danh sách $list_file"
        return 1
    fi
}

# Tải danh sách gói Pacman
load_pacman_packages() {
    load_package_list "pacman"
    PACMAN_PACKAGES_TO_INSTALL=("${PACKAGES[@]}")
}

# Tải danh sách gói AUR
load_aur_packages() {
    load_package_list "aur"
    AUR_PACKAGES_TO_INSTALL=("${PACKAGES[@]}")
}

# Mặc định tải tất cả danh sách gói khi source
load_pacman_packages
load_aur_packages' > "$CURRENT_DIR/src/core/config.sh"

    echo "Đã cập nhật cấu hình core!"
}

# Tạo README.md
create_readme() {
    echo "Tạo tập tin README.md..."

    echo "# Kiet's Linux Manager

Một công cụ quản lý hệ thống Linux mạnh mẽ giúp tự động hóa các tác vụ nhàm chán khi cài đặt hệ điều hành mới.

## Tính năng

- Cài đặt các gói phần mềm thiết yếu (Pacman và AUR)
- Cấu hình hệ thống
- Quản lý môi trường phát triển PHP/Composer/Laravel
- Quản lý môi trường phát triển NVM/NodeJS/NPM
- Giao diện người dùng CLI trực quan và đẹp mắt

## Cấu trúc thư mục

\`\`\`
linux-manager/
├── src/                 # Thư mục chứa tất cả mã nguồn
│   ├── core/            # Các chức năng cốt lõi
│   ├── modules/         # Các module chức năng
│   └── data/            # Dữ liệu tĩnh
├── logs/                # Nhật ký hoạt động
├── bin/                 # Scripts khởi chạy
├── install.sh           # Script cài đặt
└── uninstall.sh         # Script gỡ cài đặt
\`\`\`

## Cài đặt

\`\`\`bash
chmod +x install.sh
./install.sh
\`\`\`

## Sử dụng

\`\`\`bash
./bin/linux-manager
\`\`\`

## Phát triển

Để thêm module mới:

1. Tạo thư mục mới trong \`src/modules/\`
2. Tạo tập tin \`manager.sh\` trong thư mục module
3. Triển khai các hàm cần thiết
4. Cập nhật script chính để tích hợp module mới

## License

MIT
" > "$CURRENT_DIR/README.md"

    echo "Đã tạo tập tin README.md!"
}

# Hàm chính
main() {
    echo "Cài đặt Linux Manager với cấu trúc thư mục mới..."

    create_directory_structure
    update_core_config
    create_readme

    echo "Cài đặt hoàn tất!"
    echo "Bạn có thể chạy chương trình bằng cách: ./bin/linux-manager"
}

# Chạy script
main
