#!/bin/bash

# Core Configuration Module - Chứa thông tin cấu hình chung

# Thông tin ứng dụng
APP_NAME="Kiet Linux Manager"
APP_VERSION="2.1"
APP_AUTHOR="Kiet"
APP_DESCRIPTION="Một công cụ quản lý hệ thống Linux mạnh mẽ"

# Đường dẫn
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BASE_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
DATA_DIR="$BASE_DIR/src/data"
LOGS_DIR="$BASE_DIR/logs"
MODULES_DIR="$BASE_DIR/src/modules"
PACKAGES_DIR="$DATA_DIR/packages"
CONFIGS_DIR="$DATA_DIR/configs"

# Đảm bảo các thư mục tồn tại
mkdir -p "$LOGS_DIR"
mkdir -p "$PACKAGES_DIR"
mkdir -p "$CONFIGS_DIR"

# Tên tập tin nhật ký
LOG_FILE="$LOGS_DIR/manager_$(date +%Y%m%d).log"

# Tải danh sách gói
load_package_list() {
    local list_file="$PACKAGES_DIR/$1.list"
    if [ -f "$list_file" ]; then
        mapfile -t PACKAGES < "$list_file"
        return 0
    else
        echo "Lỗi: Không tìm thấy tập tin danh sách $list_file" >&2
        # Tự động tạo file nếu chưa tồn tại
        create_default_package_lists
        # Thử lại sau khi tạo file mặc định
        if [ -f "$list_file" ]; then
            mapfile -t PACKAGES < "$list_file"
            return 0
        fi
        return 1
    fi
}

# Ghi nhật ký
log_message() {
    local level="$1"
    local message="$2"
    local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    # Tạo thư mục logs nếu chưa tồn tại
    mkdir -p "$LOGS_DIR"

    # Ghi vào tập tin nhật ký
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Ghi nhật ký thông tin
log_info() {
    log_message "INFO" "$1"
}

# Ghi nhật ký lỗi
log_error() {
    log_message "ERROR" "$1"
}

# Ghi nhật ký cảnh báo
log_warning() {
    log_message "WARNING" "$1"
}

# Tạo danh sách gói mặc định nếu chưa tồn tại
create_default_package_lists() {
    # Tạo thư mục nếu chưa tồn tại
    mkdir -p "$PACKAGES_DIR"

    # Tạo danh sách gói Pacman nếu chưa tồn tại
    if [ ! -f "$PACKAGES_DIR/pacman.list" ]; then
        cat > "$PACKAGES_DIR/pacman.list" << EOF
wezterm
ghostty
7zip
unzip
unrar
vlc
ksnip
bitwarden
discord
redshift
thunar
nemo
thunderbird
bleachbit
timeshift
xed
meld
maven
jdk24-openjdk
postgresql
mariadb
docker
EOF
    fi

    # Tạo danh sách gói AUR nếu chưa tồn tại
    if [ ! -f "$PACKAGES_DIR/aur.list" ]; then
        cat > "$PACKAGES_DIR/aur.list" << EOF
octopi
visual-studio-code-bin
waterfox-bin
zen-browser-bin
google-chrome
betterbird-bin
downgrade
ventoy-bin
EOF
    fi

    # Tạo danh sách gói development
    if [ ! -f "$PACKAGES_DIR/dev.list" ]; then
        cat > "$PACKAGES_DIR/dev.list" << EOF
git
vim
neovim
vscode
docker
docker-compose
gcc
make
cmake
python
python-pip
nodejs
npm
EOF
    fi

    # Tạo danh sách gói multimedia
    if [ ! -f "$PACKAGES_DIR/multimedia.list" ]; then
        cat > "$PACKAGES_DIR/multimedia.list" << EOF
vlc
mpv
ffmpeg
gimp
obs-studio
kdenlive
audacity
audacious
EOF
    fi
}

# Tải các danh sách gói
load_all_package_lists() {
    # Tạo danh sách mặc định nếu chưa tồn tại
    create_default_package_lists

    # Tải danh sách gói Pacman
    load_package_list "pacman"
    PACMAN_PACKAGES_TO_INSTALL=("${PACKAGES[@]}")

    # Tải danh sách gói AUR
    load_package_list "aur"
    AUR_PACKAGES_TO_INSTALL=("${PACKAGES[@]}")

    # Tải danh sách gói development
    load_package_list "dev"
    DEV_PACKAGES=("${PACKAGES[@]}")

    # Tải danh sách gói multimedia
    load_package_list "multimedia"
    MULTIMEDIA_PACKAGES=("${PACKAGES[@]}")

    log_info "Đã tải tất cả danh sách gói thành công"
}

# Tải tất cả danh sách gói khi source
load_all_package_lists
