#!/bin/bash

# Chức năng build PHP từ source
# Tải utils từ core
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "${SCRIPT_DIR}/../../../core" && pwd)"
source "${CORE_DIR}/utils.sh"
source "${CORE_DIR}/ui.sh"

# Build PHP từ source
build_php_from_source() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Build PHP từ mã nguồn...${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                ${ICON_SOURCE} ${BOLD}BUILD PHP TỪ MÃ NGUỒN${NC} ${ICON_SOURCE}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Yêu cầu người dùng nhập phiên bản PHP
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập phiên bản PHP muốn build${NC} ${DARK_GRAY}(ví dụ: 8.4.4)${DARK_GRAY}: ${NC}"
    read php_version
    echo

    # Kiểm tra phiên bản hợp lệ
    if [[ ! $php_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        print_boxed_message "Phiên bản không hợp lệ. Vui lòng nhập đúng định dạng (ví dụ: 8.4.4)" "error"
        return 1
    fi

    # Kiểm tra xem phiên bản đã tồn tại chưa
    if [ -d "$HOME/.php/php-$php_version" ]; then
        print_boxed_message "PHP phiên bản $php_version đã được cài đặt tại $HOME/.php/php-$php_version" "warning"
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Bạn có muốn cài đặt lại không?${NC} ${DARK_GRAY}[${LIGHT_GREEN}y${DARK_GRAY}/${LIGHT_RED}n${DARK_GRAY}]${NC}: "
        read -n 1 reinstall
        echo

        if [[ ! "$reinstall" =~ ^[yY]$ ]]; then
            print_boxed_message "Đã hủy quá trình build PHP" "info"
            return 0
        fi

        # Xóa thư mục cũ nếu người dùng chọn cài đặt lại
        echo -e "${WHITE}Đang xóa cài đặt cũ...${NC}"
        rm -rf "$HOME/.php/php-$php_version" || {
            print_boxed_message "Không thể xóa thư mục cũ. Vui lòng kiểm tra quyền truy cập." "error"
            return 1
        }
    fi

    # Hiển thị thông tin cài đặt
    print_boxed_message "Chuẩn bị build PHP $php_version từ mã nguồn" "info"
    echo -e "${WHITE}Quá trình này có thể mất nhiều thời gian, tùy thuộc vào cấu hình máy tính.${NC}"
    echo -e "${WHITE}PHP sẽ được cài đặt vào thư mục: ${LIGHT_GREEN}$HOME/.php/php-$php_version${NC}"
    echo

    # Xác nhận từ người dùng
    echo -e -n "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Bạn có muốn tiếp tục không? ${DARK_GRAY}[${LIGHT_GREEN}y${DARK_GRAY}/${LIGHT_RED}n${DARK_GRAY}]${NC}: "
    read -n 1 confirm
    echo

    if [[ ! "$confirm" =~ ^[yY]$ ]]; then
        print_boxed_message "Đã hủy quá trình build PHP" "info"
        return 0
    fi

    # 1. Tải mã nguồn PHP
    print_boxed_message "1. Tải mã nguồn PHP $php_version" "info"

    # Tạo thư mục nếu chưa tồn tại
    if [ ! -d "$HOME/.php" ]; then
        mkdir -p "$HOME/.php"
    fi

    # Di chuyển vào thư mục
    cd "$HOME/.php" || {
        print_boxed_message "Không thể tạo hoặc truy cập thư mục $HOME/.php" "error"
        return 1
    }

    # Kiểm tra xem file đã tồn tại chưa
    if [ -f "php-$php_version.tar.gz" ]; then
        echo -e "${WHITE}File tải về đã tồn tại. Sử dụng file hiện có.${NC}"
    else
        # Tải mã nguồn
        echo -e "${WHITE}Đang tải mã nguồn từ https://www.php.net/distributions/php-$php_version.tar.gz${NC}"
        wget -q --show-progress "https://www.php.net/distributions/php-$php_version.tar.gz" || {
            print_boxed_message "Không thể tải mã nguồn PHP $php_version. Kiểm tra kết nối mạng hoặc phiên bản PHP." "error"
            return 1
        }
    fi

    # Giải nén
    echo -e "${WHITE}Đang giải nén mã nguồn...${NC}"
    tar -xzf "php-$php_version.tar.gz" || {
        print_boxed_message "Không thể giải nén mã nguồn" "error"
        return 1
    }

    # Di chuyển vào thư mục mã nguồn
    cd "php-$php_version" || {
        print_boxed_message "Không thể truy cập thư mục mã nguồn" "error"
        return 1
    }

    # 2. Cấu hình trước khi biên dịch
    print_boxed_message "2. Cấu hình PHP $php_version" "info"
    echo -e "${WHITE}Đang chạy lệnh configure với các tùy chọn...${NC}"

    # Kiểm tra các gói phụ thuộc cần thiết
    echo -e "${WHITE}Kiểm tra các gói phụ thuộc...${NC}"

    # Lệnh configure với tất cả các tùy chọn
    ./configure --prefix="$HOME/.php/php-$php_version" \
      --enable-mbstring \
      --enable-intl \
      --enable-fpm \
      --enable-pcntl \
      --enable-bcmath \
      --enable-exif \
      --enable-soap \
      --enable-sockets \
      --enable-opcache \
      --enable-gd \
      --with-zip \
      --with-openssl \
      --with-zlib \
      --with-bz2 \
      --with-curl \
      --with-mysqli \
      --with-pdo-mysql \
      --with-pdo-sqlite \
      --with-sqlite3 \
      --with-webp \
      --with-xpm \
      --with-freetype \
      --with-jpeg \
      --with-ldap \
      --with-readline || {
        print_boxed_message "Lỗi trong quá trình cấu hình PHP. Một số gói phụ thuộc có thể chưa được cài đặt." "error"

        echo -e "${YELLOW}${ICON_WARNING} ${WHITE}Gợi ý: Bạn có thể cần cài đặt các gói phát triển sau:${NC}"
        echo -e "${GRAY}libxml2-dev libssl-dev libcurl4-openssl-dev libpng-dev libjpeg-dev"
        echo -e "libfreetype6-dev libwebp-dev libxpm-dev libldap2-dev libreadline-dev libzip-dev"
        echo -e "libonig-dev libsqlite3-dev libicu-dev libbz2-dev${NC}"
        return 1
    }

    # 3. Biên dịch và cài đặt
    print_boxed_message "3. Biên dịch và cài đặt PHP $php_version" "info"
    echo -e "${WHITE}Đang biên dịch PHP (quá trình này có thể mất từ 5-15 phút)...${NC}"

    # Sử dụng tất cả các lõi CPU để tăng tốc
    make -j"$(nproc)" || {
        print_boxed_message "Lỗi trong quá trình biên dịch PHP" "error"
        return 1
    }

    echo -e "${WHITE}Đang cài đặt PHP...${NC}"
    make install || {
        print_boxed_message "Lỗi trong quá trình cài đặt PHP" "error"
        return 1
    }

    # 4. Tạo symlink
    print_boxed_message "4. Tạo symlink" "info"
    cd "$HOME/.php" || return 1

    echo -e "${WHITE}Tạo symlink: $HOME/.php/current -> $HOME/.php/php-$php_version${NC}"
    ln -sfn "php-$php_version" current || {
        print_boxed_message "Không thể tạo symlink" "error"
        return 1
    }

    # 5. Cập nhật PATH cho Fish shell
    print_boxed_message "5. Cập nhật PATH" "info"

    # Kiểm tra xem đã có cấu hình PATH chưa
    if ! grep -q "$HOME/.php/current/bin" "$HOME/.config/fish/config.fish" 2>/dev/null; then
        echo -e "${WHITE}Thêm $HOME/.php/current/bin vào PATH trong ~/.config/fish/config.fish${NC}"

        # Đảm bảo thư mục cấu hình tồn tại
        mkdir -p "$HOME/.config/fish"

        # Thêm vào file cấu hình
        echo "" >> "$HOME/.config/fish/config.fish"
        echo "# PHP từ source" >> "$HOME/.config/fish/config.fish"
        echo "set -gx PATH $HOME/.php/current/bin \$PATH" >> "$HOME/.config/fish/config.fish"
    else
        echo -e "${WHITE}Đường dẫn $HOME/.php/current/bin đã có trong PATH${NC}"
    fi

    # 6. Xóa file tạm
    print_boxed_message "6. Dọn dẹp" "info"
    echo -e "${WHITE}Xóa file tạm $HOME/.php/php-$php_version.tar.gz${NC}"
    rm -f "$HOME/.php/php-$php_version.tar.gz" || {
        echo -e "${YELLOW}Cảnh báo: Không thể xóa file tạm${NC}"
    }

    # 7. Tạo php.ini từ php.ini-development
    if [ -f "$HOME/.php/php-$php_version/lib/php.ini-development" ]; then
        echo -e "${WHITE}Tạo file php.ini từ php.ini-development...${NC}"
        cp "$HOME/.php/php-$php_version/lib/php.ini-development" "$HOME/.php/php-$php_version/lib/php.ini" || {
            echo -e "${YELLOW}Cảnh báo: Không thể tạo file php.ini${NC}"
        }
    fi

    # Hiển thị thông báo thành công
    print_boxed_message "Đã build và cài đặt PHP $php_version thành công" "success"
    echo -e "${WHITE}PHP $php_version đã được cài đặt tại: ${LIGHT_GREEN}$HOME/.php/php-$php_version${NC}"
    echo -e "${WHITE}Bạn có thể sử dụng PHP bằng lệnh: ${LIGHT_GREEN}$HOME/.php/current/bin/php${NC}"

    # Kiểm tra phiên bản PHP
    if [ -x "$HOME/.php/current/bin/php" ]; then
        local new_version=$("$HOME/.php/current/bin/php" -r "echo PHP_VERSION;" 2>/dev/null)
        echo -e "${WHITE}Phiên bản PHP hiện tại: ${LIGHT_GREEN}$new_version${NC}"
    fi
    echo

    # Hiển thị thông tin về cách khởi động lại shell
    echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Để áp dụng thay đổi ngay lập tức, hãy chạy:${NC}"
    echo -e "${LIGHT_GREEN}source ~/.config/fish/config.fish${NC}"
    echo

    # Trở lại thư mục ban đầu
    cd - > /dev/null
}
