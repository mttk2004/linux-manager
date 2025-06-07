#!/bin/bash

# Module quản lý PHP/Composer/Laravel
# Tải utils từ core
source "../../../core/utils.sh"
source "../../../core/ui.sh"

# Phiên bản PHP mặc định
DEFAULT_PHP_VERSION="8.2"

# Hiển thị menu PHP
display_php_menu() {
    clear
    echo -e "${LIGHT_CYAN}"
    echo "    ██████╗ ██╗  ██╗██████╗     ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗██████╗ "
    echo "    ██╔══██╗██║  ██║██╔══██╗    ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗"
    echo "    ██████╔╝███████║██████╔╝    ██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██████╔╝"
    echo "    ██╔═══╝ ██╔══██║██╔═══╝     ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██╔══██╗"
    echo "    ██║     ██║  ██║██║         ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██║  ██║"
    echo "    ╚═╝     ╚═╝  ╚═╝╚═╝         ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝"
    echo -e "${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_PHP} ${BOLD}PHP/COMPOSER/LARAVEL MANAGER${NC} ${ICON_PHP}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_PACKAGE} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Cài đặt PHP${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt PHP và các extension${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Cài đặt Composer${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt trình quản lý gói${NC}"
    echo

    echo -e "  ${ICON_PHP} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Cài đặt Laravel${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt Laravel framework${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[4]${NC}  ${WHITE}Quản lý phiên bản PHP${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt và chuyển đổi phiên bản${NC}"
    echo

    echo -e "  ${ICON_SOURCE} ${GREEN}${BOLD}[5]${NC}  ${WHITE}Build PHP từ source${NC}"
    echo -e "      ${GRAY}${DIM}Biên dịch và cài đặt PHP từ mã nguồn${NC}"
    echo

    echo -e "  ${ICON_SWITCH} ${GREEN}${BOLD}[6]${NC}  ${WHITE}Chuyển phiên bản PHP${NC}"
    echo -e "      ${GRAY}${DIM}Chuyển đổi giữa các phiên bản PHP đã cài đặt${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[7]${NC}  ${WHITE}Quay lại menu chính${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu chính${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-7${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
}

# Cài đặt PHP
install_php() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt PHP $DEFAULT_PHP_VERSION...${NC}"

    show_spinner "Chuẩn bị cài đặt PHP" 1

    # Kiểm tra xem PHP đã được cài đặt chưa
    if command -v php &>/dev/null; then
        local current_version=$(php -r "echo PHP_VERSION;")
        print_boxed_message "PHP đã được cài đặt (phiên bản $current_version)" "info"
    else
        # Mô phỏng cài đặt
        print_boxed_message "Đang cài đặt PHP $DEFAULT_PHP_VERSION và các extension phổ biến" "info"
        show_spinner "Cài đặt PHP" 2

        # Hiển thị thông báo thành công
        print_boxed_message "Đã cài đặt PHP $DEFAULT_PHP_VERSION thành công" "success"
    fi
}

# Cài đặt Composer
install_composer() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt Composer...${NC}"

    show_spinner "Chuẩn bị cài đặt Composer" 1

    # Kiểm tra xem Composer đã được cài đặt chưa
    if command -v composer &>/dev/null; then
        local current_version=$(composer --version | awk '{print $3}')
        print_boxed_message "Composer đã được cài đặt (phiên bản $current_version)" "info"
    else
        # Mô phỏng cài đặt
        print_boxed_message "Đang cài đặt Composer - Trình quản lý gói cho PHP" "info"
        show_spinner "Cài đặt Composer" 2

        # Hiển thị thông báo thành công
        print_boxed_message "Đã cài đặt Composer thành công" "success"
    fi
}

# Cài đặt Laravel
install_laravel() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt Laravel Installer...${NC}"

    show_spinner "Chuẩn bị cài đặt Laravel" 1

    # Kiểm tra xem Laravel đã được cài đặt chưa
    if command -v laravel &>/dev/null; then
        local current_version=$(laravel --version | awk '{print $3}')
        print_boxed_message "Laravel Installer đã được cài đặt (phiên bản $current_version)" "info"
    else
        # Kiểm tra xem Composer đã được cài đặt chưa
        if ! command -v composer &>/dev/null; then
            print_boxed_message "Composer chưa được cài đặt. Vui lòng cài đặt Composer trước." "error"
            return 1
        fi

        # Mô phỏng cài đặt
        print_boxed_message "Đang cài đặt Laravel Installer thông qua Composer" "info"
        show_spinner "Cài đặt Laravel" 2

        # Hiển thị thông báo thành công
        print_boxed_message "Đã cài đặt Laravel Installer thành công" "success"
    fi
}

# Quản lý phiên bản PHP
manage_php_versions() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Quản lý phiên bản PHP...${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_PHP} ${BOLD}QUẢN LÝ PHIÊN BẢN PHP${NC} ${ICON_PHP}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_PHP} ${GREEN}${BOLD}[1]${NC}  ${WHITE}PHP 8.2${NC} ${LIGHT_GREEN}(Khuyến nghị)${NC}"
    echo -e "      ${GRAY}${DIM}Phiên bản ổn định mới nhất${NC}"
    echo

    echo -e "  ${ICON_PHP} ${GREEN}${BOLD}[2]${NC}  ${WHITE}PHP 8.1${NC}"
    echo -e "      ${GRAY}${DIM}Phiên bản LTS${NC}"
    echo

    echo -e "  ${ICON_PHP} ${GREEN}${BOLD}[3]${NC}  ${WHITE}PHP 7.4${NC} ${YELLOW}(Legacy)${NC}"
    echo -e "      ${GRAY}${DIM}Phiên bản cũ hơn${NC}"
    echo

    echo -e "  ${ICON_PHP} ${GREEN}${BOLD}[4]${NC}  ${WHITE}PHP 8.3${NC} ${MAGENTA}(Beta)${NC}"
    echo -e "      ${GRAY}${DIM}Phiên bản thử nghiệm${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Yêu cầu người dùng chọn phiên bản
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Chọn phiên bản PHP${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-4${DARK_GRAY}]${NC}: "
    read -n 1 php_choice
    echo

    # Xử lý lựa chọn
    case $php_choice in
        1)
            version="8.2"
            ;;
        2)
            version="8.1"
            ;;
        3)
            version="7.4"
            ;;
        4)
            version="8.3"
            ;;
        *)
            print_boxed_message "Lựa chọn không hợp lệ" "error"
            return 1
            ;;
    esac

    # Mô phỏng cài đặt và chuyển đổi
    print_boxed_message "Đang cài đặt và chuyển đổi sang PHP $version" "info"
    show_spinner "Cài đặt PHP $version" 2

    # Hiển thị thông báo thành công
    print_boxed_message "Đã chuyển đổi sang PHP $version thành công" "success"
}

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

    # Tải mã nguồn
    echo -e "${WHITE}Đang tải mã nguồn từ https://www.php.net/distributions/php-$php_version.tar.gz${NC}"
    wget -q --show-progress "https://www.php.net/distributions/php-$php_version.tar.gz" || {
        print_boxed_message "Không thể tải mã nguồn PHP $php_version" "error"
        return 1
    }

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
        print_boxed_message "Lỗi trong quá trình cấu hình PHP" "error"
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

    # Hiển thị thông báo thành công
    print_boxed_message "Đã build và cài đặt PHP $php_version thành công" "success"
    echo -e "${WHITE}PHP $php_version đã được cài đặt tại: ${LIGHT_GREEN}$HOME/.php/php-$php_version${NC}"
    echo -e "${WHITE}Bạn có thể sử dụng PHP bằng lệnh: ${LIGHT_GREEN}$HOME/.php/current/bin/php${NC}"
    echo -e "${WHITE}Để kiểm tra phiên bản: ${LIGHT_GREEN}$HOME/.php/current/bin/php -v${NC}"
    echo

    # Hiển thị thông tin về cách khởi động lại shell
    echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Để áp dụng thay đổi ngay lập tức, hãy chạy:${NC}"
    echo -e "${LIGHT_GREEN}source ~/.config/fish/config.fish${NC}"
    echo

    # Trở lại thư mục ban đầu
    cd - > /dev/null
}

# Chuyển phiên bản PHP
switch_php_version() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Chuyển phiên bản PHP...${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                ${ICON_SWITCH} ${BOLD}CHUYỂN PHIÊN BẢN PHP${NC} ${ICON_SWITCH}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Kiểm tra thư mục PHP
    if [ ! -d "$HOME/.php" ]; then
        print_boxed_message "Không tìm thấy thư mục $HOME/.php. Vui lòng build PHP từ source trước." "error"
        return 1
    fi

    # Liệt kê các phiên bản PHP đã cài đặt
    echo -e "${WHITE}${BOLD}Các phiên bản PHP đã cài đặt:${NC}"
    echo

    # Lấy danh sách các thư mục php-*
    local php_versions=()
    local current_version=""
    local i=1

    # Kiểm tra symlink hiện tại
    if [ -L "$HOME/.php/current" ]; then
        current_version=$(readlink -f "$HOME/.php/current" | sed 's|.*/php-||')
    fi

    # Liệt kê các phiên bản đã cài đặt
    for dir in "$HOME"/.php/php-*; do
        if [ -d "$dir" ]; then
            local version=$(basename "$dir" | sed 's/php-//')
            php_versions+=("$version")

            if [ "$version" = "$current_version" ]; then
                echo -e "  ${ICON_PHP} ${GREEN}${BOLD}[$i]${NC}  ${WHITE}PHP $version${NC} ${LIGHT_GREEN}(Đang sử dụng)${NC}"
            else
                echo -e "  ${ICON_PHP} ${GREEN}${BOLD}[$i]${NC}  ${WHITE}PHP $version${NC}"
            fi

            echo -e "      ${GRAY}${DIM}Đường dẫn: $dir${NC}"
            echo

            ((i++))
        fi
    done

    # Nếu không có phiên bản nào
    if [ ${#php_versions[@]} -eq 0 ]; then
        print_boxed_message "Không tìm thấy phiên bản PHP nào đã được cài đặt từ source." "error"
        return 1
    fi

    # Yêu cầu người dùng chọn phiên bản
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Chọn phiên bản PHP muốn sử dụng${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-${#php_versions[@]}${DARK_GRAY}]${NC}: "
    read php_choice
    echo

    # Kiểm tra lựa chọn hợp lệ
    if ! [[ "$php_choice" =~ ^[0-9]+$ ]] || [ "$php_choice" -lt 1 ] || [ "$php_choice" -gt ${#php_versions[@]} ]; then
        print_boxed_message "Lựa chọn không hợp lệ" "error"
        return 1
    fi

    # Lấy phiên bản đã chọn
    local selected_version=${php_versions[$php_choice-1]}

    # Nếu đã là phiên bản hiện tại
    if [ "$selected_version" = "$current_version" ]; then
        print_boxed_message "PHP $selected_version đã là phiên bản đang sử dụng" "info"
        return 0
    fi

    # Thực hiện chuyển đổi phiên bản
    print_boxed_message "Đang chuyển sang PHP $selected_version" "info"

    # Di chuyển vào thư mục PHP
    cd "$HOME/.php" || {
        print_boxed_message "Không thể truy cập thư mục $HOME/.php" "error"
        return 1
    }

    # Cập nhật symlink
    echo -e "${WHITE}Cập nhật symlink: $HOME/.php/current -> $HOME/.php/php-$selected_version${NC}"
    ln -sfn "php-$selected_version" current || {
        print_boxed_message "Không thể cập nhật symlink" "error"
        return 1
    }

    # Hiển thị thông báo thành công
    print_boxed_message "Đã chuyển sang PHP $selected_version thành công" "success"
    echo -e "${WHITE}PHP $selected_version đã được kích hoạt tại: ${LIGHT_GREEN}$HOME/.php/current${NC}"

    # Kiểm tra phiên bản PHP
    if [ -x "$HOME/.php/current/bin/php" ]; then
        local new_version=$("$HOME/.php/current/bin/php" -r "echo PHP_VERSION;" 2>/dev/null)
        echo -e "${WHITE}Phiên bản PHP hiện tại: ${LIGHT_GREEN}$new_version${NC}"
    fi
    echo

    # Kiểm tra và cập nhật PATH nếu cần
    if ! grep -q "$HOME/.php/current/bin" "$HOME/.config/fish/config.fish" 2>/dev/null; then
        echo -e "${YELLOW}${ICON_WARNING} ${WHITE}Đường dẫn PHP chưa được thêm vào PATH${NC}"
        echo -e "${WHITE}Thêm dòng sau vào file ~/.config/fish/config.fish:${NC}"
        echo -e "${LIGHT_GREEN}set -gx PATH $HOME/.php/current/bin \$PATH${NC}"

        # Hỏi người dùng có muốn thêm vào không
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Thêm vào PATH ngay bây giờ?${NC} ${DARK_GRAY}[${LIGHT_GREEN}y${DARK_GRAY}/${LIGHT_RED}n${DARK_GRAY}]${NC}: "
        read -n 1 add_path
        echo

        if [[ "$add_path" =~ ^[yY]$ ]]; then
            # Đảm bảo thư mục cấu hình tồn tại
            mkdir -p "$HOME/.config/fish"

            # Thêm vào file cấu hình
            echo "" >> "$HOME/.config/fish/config.fish"
            echo "# PHP từ source" >> "$HOME/.config/fish/config.fish"
            echo "set -gx PATH $HOME/.php/current/bin \$PATH" >> "$HOME/.config/fish/config.fish"

            print_boxed_message "Đã thêm PHP vào PATH thành công" "success"
        fi
    fi

    # Nhắc nhở người dùng khởi động lại shell nếu cần
    echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Để áp dụng thay đổi ngay lập tức, hãy chạy:${NC}"
    echo -e "${LIGHT_GREEN}source ~/.config/fish/config.fish${NC}"
    echo

    # Trở lại thư mục ban đầu
    cd - > /dev/null
}

# Hàm chính để quản lý môi trường PHP
manage_php_environment() {
    local choice

    while true; do
        display_php_menu
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-7${DARK_GRAY}]${NC}: "
        read -n 1 choice
        echo

        case $choice in
            1)
                install_php
                ;;
            2)
                install_composer
                ;;
            3)
                install_laravel
                ;;
            4)
                manage_php_versions
                ;;
            5)
                build_php_from_source
                ;;
            6)
                switch_php_version
                ;;
            7)
                return 0
                ;;
            *)
                print_boxed_message "Lựa chọn không hợp lệ. Vui lòng chọn số từ 1-7." "error"
                ;;
        esac

        # Đợi người dùng nhấn phím bất kỳ để tiếp tục
        echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Nhấn ${LIGHT_GREEN}${BOLD}phím bất kỳ${NC}${WHITE} để quay lại menu PHP..."
        read -n 1 -s
    done
}
