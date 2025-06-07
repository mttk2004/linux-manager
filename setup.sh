#!/bin/bash

# Script cài đặt Linux Manager với cấu trúc thư mục mới

# Màu sắc
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
LIGHT_CYAN='\033[1;36m'
DARK_GRAY='\033[1;30m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Biểu tượng
ICON_CHECK="✓"
ICON_CROSS="✗"
ICON_INFO="ℹ"
ICON_WARNING="⚠"
ICON_GEAR="⚙"

# Xác định thư mục hiện tại
CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Hiển thị thông báo
print_message() {
    local message="$1"
    local type="$2"
    local color=""
    local icon=""

    case $type in
        "success")
            color="$GREEN"
            icon="$ICON_CHECK"
            ;;
        "error")
            color="$RED"
            icon="$ICON_CROSS"
            ;;
        "info")
            color="$LIGHT_CYAN"
            icon="$ICON_INFO"
            ;;
        "warning")
            color="$YELLOW"
            icon="$ICON_WARNING"
            ;;
        *)
            color="$BLUE"
            icon="$ICON_INFO"
            ;;
    esac

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${color}    ${icon} ${WHITE}${BOLD}${message}${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
}

# Hiển thị tiêu đề
print_header() {
    clear
    echo -e "${LIGHT_CYAN}"
    echo "    ██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗    ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗██████╗ "
    echo "    ██║     ██║████╗  ██║██║   ██║╚██╗██╔╝    ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗"
    echo "    ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝     ██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██████╔╝"
    echo "    ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗     ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██╔══██╗"
    echo "    ███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗    ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██║  ██║"
    echo "    ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝"
    echo -e "${NC}"
    echo -e "${YELLOW}                                  THIẾT LẬP CẤU TRÚC THƯ MỤC MỚI${NC}"
    echo -e "${BLUE}═════════════════════════════════════════════════════════════════════════════════════════════════${NC}"
    echo
}

# Yêu cầu xác nhận
confirm() {
    local message="$1"
    local default="$2"

    if [ "$default" = "y" ]; then
        echo -e -n "${YELLOW}${ICON_WARNING} ${message} [Y/n]: ${NC}"
        read -r response
        if [[ "$response" =~ ^[Nn]$ ]]; then
            return 1
        else
            return 0
        fi
    else
        echo -e -n "${YELLOW}${ICON_WARNING} ${message} [y/N]: ${NC}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            return 0
        else
            return 1
        fi
    fi
}

# Tạo cấu trúc thư mục mới
create_directory_structure() {
    print_message "Tạo cấu trúc thư mục mới..." "info"

    # Tạo thư mục chính
    mkdir -p "$CURRENT_DIR/src/core"
    mkdir -p "$CURRENT_DIR/src/modules/packages"
    mkdir -p "$CURRENT_DIR/src/modules/system"
    mkdir -p "$CURRENT_DIR/src/modules/dev/php"
    mkdir -p "$CURRENT_DIR/src/modules/dev/nodejs"
    mkdir -p "$CURRENT_DIR/src/modules/dev/docker"
    mkdir -p "$CURRENT_DIR/src/modules/misc"
    mkdir -p "$CURRENT_DIR/src/data/packages"
    mkdir -p "$CURRENT_DIR/src/data/configs/bash"
    mkdir -p "$CURRENT_DIR/src/data/configs/fish"
    mkdir -p "$CURRENT_DIR/src/data/configs/vim"
    mkdir -p "$CURRENT_DIR/logs"
    mkdir -p "$CURRENT_DIR/bin"

    print_message "Đã tạo xong cấu trúc thư mục!" "success"
}

# Di chuyển các tập tin hiện có vào cấu trúc mới
migrate_existing_files() {
    print_message "Di chuyển các tập tin hiện có..." "info"

    # Di chuyển các tập tin core
    cp "$CURRENT_DIR/config.sh" "$CURRENT_DIR/src/core/"
    cp "$CURRENT_DIR/utils.sh" "$CURRENT_DIR/src/core/"

    # Tạo ui.sh từ các phần UI trong manager.sh
    grep -E "(print_fancy_header|display_menu|animate_text|show_exit_message)" "$CURRENT_DIR/manager.sh" > "$CURRENT_DIR/src/core/ui.sh"

    # Di chuyển install_packages.sh vào module packages
    cp "$CURRENT_DIR/install_packages.sh" "$CURRENT_DIR/src/modules/packages/manager.sh"

    # Nếu các thư mục module đã tồn tại, di chuyển nội dung của chúng
    if [ -d "$CURRENT_DIR/manage_php_composer_laravel" ]; then
        cp -r "$CURRENT_DIR/manage_php_composer_laravel/"* "$CURRENT_DIR/src/modules/dev/php/"
    fi

    if [ -d "$CURRENT_DIR/manage_nvm_nodejs_npm" ]; then
        cp -r "$CURRENT_DIR/manage_nvm_nodejs_npm/"* "$CURRENT_DIR/src/modules/dev/nodejs/"
    fi

    # Tạo danh sách gói từ config.sh
    mkdir -p "$CURRENT_DIR/src/data/packages"
    grep -A 100 "PACMAN_PACKAGES_TO_INSTALL" "$CURRENT_DIR/config.sh" | grep -v "AUR_PACKAGES_TO_INSTALL" | grep -E "^    \".*\"$" | sed 's/    "//' | sed 's/"[,]*$//' > "$CURRENT_DIR/src/data/packages/pacman.list"
    grep -A 100 "AUR_PACKAGES_TO_INSTALL" "$CURRENT_DIR/config.sh" | grep -E "^    \".*\"$" | sed 's/    "//' | sed 's/"[,]*$//' > "$CURRENT_DIR/src/data/packages/aur.list"

    # Sao chép script chính vào bin
    if [ -f "$CURRENT_DIR/bin/linux-manager" ]; then
        print_message "Script chính đã tồn tại trong thư mục bin" "info"
    else
        cp "$CURRENT_DIR/setup/linux-manager" "$CURRENT_DIR/bin/linux-manager" 2>/dev/null || \
        print_message "Không tìm thấy script chính mẫu, sẽ tạo một script mới" "warning"
    fi

    # Đảm bảo script chính có quyền thực thi
    chmod +x "$CURRENT_DIR/bin/linux-manager"

    print_message "Đã di chuyển các tập tin hiện có vào cấu trúc mới!" "success"
}

# Tạo các tập tin module mới nếu chưa tồn tại
create_module_files() {
    print_message "Tạo các tập tin module mới..." "info"

    # Tạo module pacman.sh nếu chưa tồn tại
    if [ ! -f "$CURRENT_DIR/src/modules/packages/pacman.sh" ]; then
        print_message "Tạo module pacman.sh..." "info"
        touch "$CURRENT_DIR/src/modules/packages/pacman.sh"
        echo '#!/bin/bash

# Module quản lý gói Pacman
# Được sử dụng để cài đặt và quản lý các gói từ kho chính thức của Arch Linux

# Kiểm tra xem một gói đã được cài đặt chưa
is_pacman_package_installed() {
    local package="$1"

    # Sử dụng pacman -Qi để kiểm tra
    if pacman -Qi "$package" &> /dev/null; then
        return 0 # Gói đã được cài đặt
    else
        return 1 # Gói chưa được cài đặt
    fi
}' > "$CURRENT_DIR/src/modules/packages/pacman.sh"
    fi

    # Tạo module aur.sh nếu chưa tồn tại
    if [ ! -f "$CURRENT_DIR/src/modules/packages/aur.sh" ]; then
        print_message "Tạo module aur.sh..." "info"
        touch "$CURRENT_DIR/src/modules/packages/aur.sh"
        echo '#!/bin/bash

# Module quản lý gói AUR
# Được sử dụng để cài đặt và quản lý các gói từ Arch User Repository

# Kiểm tra xem một trình trợ giúp AUR đã được cài đặt chưa
check_aur_helper() {
    if command -v yay &>/dev/null; then
        AUR_HELPER="yay"
        return 0
    elif command -v paru &>/dev/null; then
        AUR_HELPER="paru"
        return 0
    else
        AUR_HELPER=""
        return 1
    fi
}' > "$CURRENT_DIR/src/modules/packages/aur.sh"
    fi

    # Tạo module flatpak.sh nếu chưa tồn tại
    if [ ! -f "$CURRENT_DIR/src/modules/packages/flatpak.sh" ]; then
        print_message "Tạo module flatpak.sh..." "info"
        touch "$CURRENT_DIR/src/modules/packages/flatpak.sh"
        echo '#!/bin/bash

# Module quản lý gói Flatpak
# Được sử dụng để cài đặt và quản lý các ứng dụng Flatpak

# Kiểm tra xem Flatpak đã được cài đặt chưa
check_flatpak_installed() {
    if command -v flatpak &>/dev/null; then
        return 0
    else
        return 1
    fi
}' > "$CURRENT_DIR/src/modules/packages/flatpak.sh"
    fi

    # Tạo module system manager nếu chưa tồn tại
    if [ ! -f "$CURRENT_DIR/src/modules/system/manager.sh" ]; then
        print_message "Tạo module system manager..." "info"
        touch "$CURRENT_DIR/src/modules/system/manager.sh"
        echo '#!/bin/bash

# Module cấu hình hệ thống
install_configurations() {
    print_boxed_message "Tính năng cấu hình hệ thống sẽ sớm được phát triển!" "info"
}' > "$CURRENT_DIR/src/modules/system/manager.sh"
    fi

    print_message "Đã tạo xong các tập tin module mới!" "success"
}

# Tạo các tập tin config mẫu
create_sample_configs() {
    print_message "Tạo các tập tin cấu hình mẫu..." "info"

    # Tạo cấu hình bash mẫu
    if [ ! -f "$CURRENT_DIR/src/data/configs/bash/.bashrc" ]; then
        cat > "$CURRENT_DIR/src/data/configs/bash/.bashrc" << 'EOF'
# .bashrc được tạo bởi Linux Manager

# Alias hữu ích
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias ip='ip -color=auto'

# Prompt đẹp mắt
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Lịch sử lệnh
HISTSIZE=1000
HISTFILESIZE=2000
HISTCONTROL=ignoreboth
shopt -s histappend
EOF
    fi

    # Tạo cấu hình fish mẫu
    if [ ! -f "$CURRENT_DIR/src/data/configs/fish/config.fish" ]; then
        cat > "$CURRENT_DIR/src/data/configs/fish/config.fish" << 'EOF'
# config.fish được tạo bởi Linux Manager

# Alias hữu ích
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'

# Thiết lập môi trường
set -gx PATH $HOME/.local/bin $PATH

# Chào mừng khi khởi động
function fish_greeting
    echo "Chào mừng đến với Fish Shell!"
end
EOF
    fi

    # Tạo cấu hình vim mẫu
    if [ ! -f "$CURRENT_DIR/src/data/configs/vim/.vimrc" ]; then
        cat > "$CURRENT_DIR/src/data/configs/vim/.vimrc" << 'EOF'
" .vimrc được tạo bởi Linux Manager

" Cài đặt cơ bản
set nocompatible
set number
set ruler
set autoindent
set smartindent
set tabstop=4
set shiftwidth=4
set expandtab
set hlsearch
set incsearch
set ignorecase
set smartcase
set showmatch
set cursorline
set wildmenu
set showmode
set showcmd
set encoding=utf-8
set fileencoding=utf-8
set backspace=indent,eol,start

" Cú pháp và màu sắc
syntax on
colorscheme desert
set background=dark
EOF
    fi

    print_message "Đã tạo xong các tập tin cấu hình mẫu!" "success"
}

# Tạo README.md
create_readme() {
    print_message "Tạo tập tin README.md..." "info"

    cat > "$CURRENT_DIR/README.md" << 'EOF'
# Kiet's Linux Manager

Một công cụ quản lý hệ thống Linux mạnh mẽ giúp tự động hóa các tác vụ nhàm chán khi cài đặt hệ điều hành mới.

## Tính năng

- Cài đặt các gói phần mềm thiết yếu (Pacman, AUR và Flatpak)
- Cấu hình hệ thống
- Quản lý môi trường phát triển PHP/Composer/Laravel
- Quản lý môi trường phát triển NVM/NodeJS/NPM
- Giao diện người dùng CLI trực quan và đẹp mắt

## Cấu trúc thư mục

```
linux-manager/
├── src/                 # Thư mục chứa tất cả mã nguồn
│   ├── core/            # Các chức năng cốt lõi
│   │   ├── ui.sh        # Giao diện người dùng, menu, animation
│   │   ├── utils.sh     # Các hàm tiện ích chung
│   │   └── config.sh    # Cấu hình và biến môi trường
│   │
│   ├── modules/         # Các module chức năng
│   │   ├── packages/    # Quản lý gói
│   │   │   ├── pacman.sh
│   │   │   ├── aur.sh
│   │   │   └── flatpak.sh
│   │   │
│   │   ├── system/      # Cấu hình hệ thống
│   │   │   ├── backups.sh
│   │   │   ├── kernel.sh
│   │   │   └── services.sh
│   │   │
│   │   ├── dev/         # Môi trường phát triển
│   │   │   ├── php/
│   │   │   │   ├── setup.sh
│   │   │   │   ├── config.sh
│   │   │   │   └── utils.sh
│   │   │   │
│   │   │   ├── nodejs/
│   │   │   │   ├── setup.sh
│   │   │   │   ├── config.sh
│   │   │   │   └── utils.sh
│   │   │   │
│   │   │   └── docker/
│   │   │       ├── setup.sh
│   │   │       └── utils.sh
│   │   │
│   │   └── misc/        # Các chức năng khác
│   │       ├── themes.sh
│   │       └── hardware.sh
│   │
│   └── data/            # Dữ liệu tĩnh
│       ├── packages/    # Danh sách các gói theo nhóm
│       │   ├── essential.list
│       │   ├── dev.list
│       │   └── media.list
│       │
│       └── configs/     # Các tệp cấu hình mẫu
│           ├── bash/
│           ├── fish/
│           └── vim/
│
├── logs/                # Nhật ký hoạt động
├── bin/                 # Scripts khởi chạy
│   └── linux-manager    # Script chính để chạy
│
├── setup.sh             # Script cài đặt
├── README.md            # Tài liệu hướng dẫn
└── LICENSE              # Giấy phép sử dụng
```

## Cài đặt

```bash
chmod +x setup.sh
./setup.sh
```

## Sử dụng

```bash
./bin/linux-manager
```

## Phát triển

Để thêm module mới:

1. Tạo thư mục mới trong `src/modules/`
2. Tạo tập tin `manager.sh` trong thư mục module
3. Triển khai các hàm cần thiết
4. Cập nhật script chính để tích hợp module mới

## Giấy phép

MIT
EOF

    print_message "Đã tạo xong tập tin README.md!" "success"
}

# Tạo tập tin LICENSE
create_license() {
    print_message "Tạo tập tin LICENSE..." "info"

    cat > "$CURRENT_DIR/LICENSE" << 'EOF'
MIT License

Copyright (c) 2025 Mai Tran Tuan Kiet

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

    print_message "Đã tạo xong tập tin LICENSE!" "success"
}

# Hàm chính
main() {
    print_header

    print_message "Cài đặt Linux Manager với cấu trúc thư mục mới..." "info"
    echo

    if ! confirm "Bạn có muốn tiếp tục cài đặt không?" "y"; then
        print_message "Đã hủy cài đặt." "info"
        exit 0
    fi

    echo

    create_directory_structure
    migrate_existing_files
    create_module_files
    create_sample_configs
    create_readme
    create_license

    echo
    print_message "Cài đặt hoàn tất!" "success"
    print_message "Bạn có thể chạy chương trình bằng cách: ./bin/linux-manager" "info"
    print_message "Vui lòng đảm bảo script có quyền thực thi bằng lệnh: chmod +x ./bin/linux-manager" "info"
    echo

    # Cấp quyền thực thi cho script chính
    if confirm "Bạn có muốn cấp quyền thực thi cho script chính không?" "y"; then
        chmod +x "$CURRENT_DIR/bin/linux-manager"
        print_message "Đã cấp quyền thực thi cho script chính" "success"
    fi

    # Hỏi người dùng có muốn chạy script ngay không
    if confirm "Bạn có muốn chạy Linux Manager ngay bây giờ không?" "y"; then
        "$CURRENT_DIR/bin/linux-manager"
    else
        print_message "Cảm ơn bạn đã cài đặt Linux Manager!" "success"
    fi
}

# Chạy script
main
