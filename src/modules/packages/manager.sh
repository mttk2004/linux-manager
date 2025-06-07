#!/bin/bash

# Module quản lý gói chính - Tích hợp tất cả các trình quản lý gói

# Lấy đường dẫn hiện tại của script
CURRENT_DIR="$(dirname "${BASH_SOURCE[0]}")"
CORE_DIR="$CURRENT_DIR/../../../src/core"

# Tải các module core cần thiết trước
source "$CORE_DIR/config.sh"
source "$CORE_DIR/ui.sh"
source "$CORE_DIR/utils.sh"

# Tải các module quản lý gói sau khi đã có config
source "$CURRENT_DIR/pacman.sh"
source "$CURRENT_DIR/aur.sh"
source "$CURRENT_DIR/flatpak.sh"

# Hiển thị menu quản lý gói
display_package_menu() {
    clear
    echo -e "${LIGHT_CYAN}"
    echo "    ██████╗  █████╗  ██████╗██╗  ██╗ █████╗  ██████╗ ███████╗"
    echo "    ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔════╝ ██╔════╝"
    echo "    ██████╔╝███████║██║     █████╔╝ ███████║██║  ███╗█████╗  "
    echo "    ██╔═══╝ ██╔══██║██║     ██╔═██╗ ██╔══██║██║   ██║██╔══╝  "
    echo "    ██║     ██║  ██║╚██████╗██║  ██╗██║  ██║╚██████╔╝███████╗"
    echo "    ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
    echo -e "${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_PACKAGE} ${BOLD}QUẢN LÝ GÓI PHẦN MỀM${NC} ${ICON_PACKAGE}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_PACKAGE} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Cài đặt gói Pacman${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt từ kho chính thức Arch Linux${NC}"
    echo

    echo -e "  ${ICON_PACKAGE} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Cài đặt gói AUR${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt từ AUR (Arch User Repository)${NC}"
    echo

    echo -e "  ${ICON_PACKAGE} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Cài đặt ứng dụng Flatpak${NC}"
    echo -e "      ${GRAY}${DIM}Cài đặt từ Flathub${NC}"
    echo

    echo -e "  ${ICON_PACKAGE} ${GREEN}${BOLD}[4]${NC}  ${WHITE}Cập nhật hệ thống${NC}"
    echo -e "      ${GRAY}${DIM}Cập nhật tất cả các gói${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[5]${NC}  ${WHITE}Gỡ cài đặt gói${NC}"
    echo -e "      ${GRAY}${DIM}Gỡ bỏ gói đã cài đặt${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[6]${NC}  ${WHITE}Quay lại menu chính${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu chính của ứng dụng${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-6${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
}

# Hiển thị menu cài đặt gói Pacman
display_pacman_package_menu() {
    clear
    echo -e "${LIGHT_CYAN}"
    echo "    ██████╗  █████╗  ██████╗███╗   ███╗ █████╗ ███╗   ██╗"
    echo "    ██╔══██╗██╔══██╗██╔════╝████╗ ████║██╔══██╗████╗  ██║"
    echo "    ██████╔╝███████║██║     ██╔████╔██║███████║██╔██╗ ██║"
    echo "    ██╔═══╝ ██╔══██║██║     ██║╚██╔╝██║██╔══██║██║╚██╗██║"
    echo "    ██║     ██║  ██║╚██████╗██║ ╚═╝ ██║██║  ██║██║ ╚████║"
    echo "    ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝"
    echo -e "${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                     ${ICON_PACKAGE} ${BOLD}CÀI ĐẶT GÓI PACMAN${NC} ${ICON_PACKAGE}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_PACKAGE} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Cài đặt gói thiết yếu${NC}"
    echo -e "      ${GRAY}${DIM}Các gói cơ bản cần thiết cho hệ thống${NC}"
    echo

    echo -e "  ${ICON_PACKAGE} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Cài đặt gói phát triển${NC}"
    echo -e "      ${GRAY}${DIM}Công cụ lập trình và development${NC}"
    echo

    echo -e "  ${ICON_PACKAGE} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Cài đặt gói đa phương tiện${NC}"
    echo -e "      ${GRAY}${DIM}Âm thanh, video và hình ảnh${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[4]${NC}  ${WHITE}Cài đặt gói tùy chỉnh${NC}"
    echo -e "      ${GRAY}${DIM}Nhập tên gói muốn cài đặt${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[5]${NC}  ${WHITE}Quay lại${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu quản lý gói${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-5${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
}

# Hiển thị menu cài đặt gói AUR
display_aur_package_menu() {
    clear
    echo -e "${LIGHT_CYAN}"
    echo "     █████╗ ██╗   ██╗██████╗     ███╗   ███╗███████╗███╗   ██╗██╗   ██╗"
    echo "    ██╔══██╗██║   ██║██╔══██╗    ████╗ ████║██╔════╝████╗  ██║██║   ██║"
    echo "    ███████║██║   ██║██████╔╝    ██╔████╔██║█████╗  ██╔██╗ ██║██║   ██║"
    echo "    ██╔══██║██║   ██║██╔══██╗    ██║╚██╔╝██║██╔══╝  ██║╚██╗██║██║   ██║"
    echo "    ██║  ██║╚██████╔╝██║  ██║    ██║ ╚═╝ ██║███████╗██║ ╚████║╚██████╔╝"
    echo "    ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ "
    echo -e "${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_PACKAGE} ${BOLD}CÀI ĐẶT GÓI AUR${NC} ${ICON_PACKAGE}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_PACKAGE} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Cài đặt gói AUR thiết yếu${NC}"
    echo -e "      ${GRAY}${DIM}Các gói phổ biến từ AUR${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Cài đặt gói AUR tùy chỉnh${NC}"
    echo -e "      ${GRAY}${DIM}Nhập tên gói AUR muốn cài đặt${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[3]${NC}  ${WHITE}Quay lại${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu quản lý gói${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-3${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
}

# Hiển thị menu cài đặt ứng dụng Flatpak
display_flatpak_package_menu() {
    clear
    echo -e "${LIGHT_CYAN}"
    echo "    ███████╗██╗      █████╗ ████████╗██████╗  █████╗ ██╗  ██╗"
    echo "    ██╔════╝██║     ██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██║ ██╔╝"
    echo "    █████╗  ██║     ███████║   ██║   ██████╔╝███████║█████╔╝ "
    echo "    ██╔══╝  ██║     ██╔══██║   ██║   ██╔═══╝ ██╔══██║██╔═██╗ "
    echo "    ██║     ███████╗██║  ██║   ██║   ██║     ██║  ██║██║  ██╗"
    echo "    ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝"
    echo -e "${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_PACKAGE} ${BOLD}CÀI ĐẶT ỨNG DỤNG FLATPAK${NC} ${ICON_PACKAGE}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_PACKAGE} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Cài đặt ứng dụng phổ biến${NC}"
    echo -e "      ${GRAY}${DIM}Các ứng dụng nổi tiếng từ Flathub${NC}"
    echo

    echo -e "  ${ICON_CONFIG} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Cài đặt ứng dụng tùy chỉnh${NC}"
    echo -e "      ${GRAY}${DIM}Nhập ID ứng dụng muốn cài đặt${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[3]${NC}  ${WHITE}Quay lại${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu quản lý gói${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-3${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
}

# Hàm cài đặt gói tùy chỉnh Pacman
install_custom_pacman_package() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Cài đặt gói tùy chỉnh${NC}"

    # Yêu cầu người dùng nhập tên gói
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}Nhập tên gói cần cài đặt (hoặc nhập 'q' để hủy):${NC} "
    read package_name

    # Kiểm tra nếu người dùng muốn hủy
    if [ "$package_name" = "q" ] || [ -z "$package_name" ]; then
        print_boxed_message "Đã hủy cài đặt gói tùy chỉnh" "info"
        return 0
    fi

    # Cài đặt gói
    install_pacman_package "$package_name"

    return 0
}

# Hàm tìm kiếm gói
search_package() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Tìm kiếm gói${NC}"

    # Yêu cầu người dùng nhập từ khóa tìm kiếm
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}Nhập từ khóa tìm kiếm (hoặc nhập 'q' để hủy):${NC} "
    read keyword

    # Kiểm tra nếu người dùng muốn hủy
    if [ "$keyword" = "q" ] || [ -z "$keyword" ]; then
        print_boxed_message "Đã hủy tìm kiếm gói" "info"
        return 0
    fi

    # Hiển thị header kết quả tìm kiếm
    display_section_header "KẾT QUẢ TÌM KIẾM" "${ICON_SEARCH}"
    echo -e "  ${YELLOW}Từ khóa:${NC} ${WHITE}${BOLD}$keyword${NC}"
    echo

    # Tìm kiếm trong Pacman
    echo -e "  ${LIGHT_CYAN}${BOLD}=== Kết quả từ kho chính thức (Pacman) ===${NC}"
    search_pacman_package "$keyword"

    # Tìm kiếm trong AUR
    echo -e "\n  ${LIGHT_CYAN}${BOLD}=== Kết quả từ AUR ===${NC}"
    search_aur_package "$keyword"

    # Tìm kiếm trong Flatpak
    echo -e "\n  ${LIGHT_CYAN}${BOLD}=== Kết quả từ Flathub (Flatpak) ===${NC}"
    search_flatpak_app "$keyword"

    # Đợi người dùng nhấn phím để tiếp tục
    wait_for_user
    return 0
}

# Hàm cập nhật tất cả các gói
update_all_packages() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cập nhật tất cả các gói...${NC}"

    # Cập nhật Pacman
    update_pacman_database
    upgrade_all_pacman_packages

    # Cập nhật AUR
    if check_aur_helper; then
        upgrade_all_aur_packages
    else
        print_boxed_message "Bỏ qua cập nhật AUR (trình trợ giúp AUR không được cài đặt)" "info"
    fi

    # Cập nhật Flatpak
    if check_flatpak_installed; then
        update_flatpak_apps
    else
        print_boxed_message "Bỏ qua cập nhật Flatpak (Flatpak không được cài đặt)" "info"
    fi

    print_boxed_message "Đã hoàn tất cập nhật tất cả các gói" "success"

    return 0
}

# Hàm chính để quản lý gói
manage_packages() {
    local choice

    while true; do
        display_package_menu
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-6${DARK_GRAY}]${NC}: "
        read -n 1 choice
        echo

        case $choice in
            1)
                # Menu cài đặt gói Pacman
                local pacman_choice
                while true; do
                    display_pacman_package_menu
                    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-5${DARK_GRAY}]${NC}: "
                    read -n 1 pacman_choice
                    echo

                    case $pacman_choice in
                        1)
                            # Cài đặt gói thiết yếu
                            install_pacman_packages "${PACMAN_PACKAGES_TO_INSTALL[@]}"
                            ;;
                        2)
                            # Cài đặt gói phát triển
                            install_pacman_packages "${DEV_PACKAGES[@]}"
                            ;;
                        3)
                            # Cài đặt gói đa phương tiện
                            install_pacman_packages "${MULTIMEDIA_PACKAGES[@]}"
                            ;;
                        4)
                            # Cài đặt gói tùy chỉnh
                            install_custom_pacman_package
                            ;;
                        5)
                            # Quay lại
                            break
                            ;;
                        *)
                            print_boxed_message "Lựa chọn không hợp lệ. Vui lòng chọn số từ 1-5." "error"
                            ;;
                    esac

                    # Đợi người dùng nhấn phím bất kỳ để tiếp tục
                    echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Nhấn ${LIGHT_GREEN}${BOLD}phím bất kỳ${NC}${WHITE} để tiếp tục..."
                    read -n 1 -s
                done
                ;;
            2)
                # Cài đặt gói AUR
                install_aur_packages "${AUR_PACKAGES_TO_INSTALL[@]}"
                ;;
            3)
                # Cài đặt ứng dụng Flatpak
                # TODO: Thêm danh sách ứng dụng Flatpak phổ biến
                local flatpak_apps=(
                    "com.spotify.Client"
                    "com.discordapp.Discord"
                    "org.telegram.desktop"
                    "com.google.Chrome"
                    "com.visualstudio.code"
                )
                install_flatpak_apps "${flatpak_apps[@]}"
                ;;
            4)
                # Cập nhật tất cả gói
                update_all_packages
                ;;
            5)
                # Tìm kiếm gói
                search_package
                ;;
            6)
                # Quay lại menu chính
                return 0
                ;;
            *)
                print_boxed_message "Lựa chọn không hợp lệ. Vui lòng chọn số từ 1-6." "error"
                ;;
        esac

        # Đợi người dùng nhấn phím bất kỳ để tiếp tục
        echo -e "${LIGHT_YELLOW}${ICON_INFO} ${WHITE}Nhấn ${LIGHT_GREEN}${BOLD}phím bất kỳ${NC}${WHITE} để quay lại menu quản lý gói..."
        read -n 1 -s
    done
}

# Hàm chính để cài đặt gói (được gọi từ menu chính)
install_packages() {
    manage_packages
}
