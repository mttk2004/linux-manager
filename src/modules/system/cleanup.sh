#!/bin/bash

# Module dọn dẹp hệ thống - Dọn sạch các gói không cần thiết và cache
# Tải utils từ core
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "${SCRIPT_DIR}/../../core" && pwd)"

# Chỉ tải các module core nếu chưa được tải
if ! declare -f log_info >/dev/null 2>&1; then
    source "${CORE_DIR}/config.sh"
fi

if ! declare -f read_single_key >/dev/null 2>&1; then
    source "${CORE_DIR}/utils.sh"
fi

if ! declare -f print_boxed_message >/dev/null 2>&1; then
    source "${CORE_DIR}/ui.sh"
fi

# Biểu tượng bổ sung
ICON_CLEAN="🧹"
ICON_ORPHAN="🧩"
ICON_CACHE="💾"
ICON_FOREIGN="🧭"
ICON_MANUAL="📋"
ICON_AUTO="🔥"

# Hiển thị menu dọn dẹp hệ thống
display_cleanup_menu() {
    clear
    echo -e "${LIGHT_CYAN}"
    echo "    ██████╗ ██╗      ███████╗ █████╗ ███╗   ██╗██╗   ██╗██████╗ "
    echo "    ██╔════╝██║      ██╔════╝██╔══██╗████╗  ██║██║   ██║██╔══██╗"
    echo "    ██║     ██║      █████╗  ███████║██╔██╗ ██║██║   ██║██████╔╝"
    echo "    ██║     ██║      ██╔══╝  ██╔══██║██║╚██╗██║██║   ██║██╔═══╝ "
    echo "    ╚██████╗███████╗ ███████╗██║  ██║██║ ╚████║╚██████╔╝██║     "
    echo "     ╚═════╝╚══════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     "
    echo -e "${NC}"

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_CLEAN} ${BOLD}DỌN DẸP HỆ THỐNG${NC} ${ICON_CLEAN}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_ORPHAN} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Dọn gói mồ côi (Orphaned Packages)${NC}"
    echo -e "      ${GRAY}${DIM}Gỡ các gói không còn được phụ thuộc${NC}"
    echo

    echo -e "  ${ICON_CACHE} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Dọn cache Pacman${NC}"
    echo -e "      ${GRAY}${DIM}Xóa các phiên bản cũ trong cache${NC}"
    echo

    echo -e "  ${ICON_MANUAL} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Xem gói cài thủ công${NC}"
    echo -e "      ${GRAY}${DIM}Hiển thị các gói được cài bằng tay${NC}"
    echo

    echo -e "  ${ICON_PACKAGE} ${GREEN}${BOLD}[4]${NC}  ${WHITE}Dọn AUR và cache${NC}"
    echo -e "      ${GRAY}${DIM}Dọn sạch gói AUR mồ côi và cache${NC}"
    echo

    echo -e "  ${ICON_FOREIGN} ${GREEN}${BOLD}[5]${NC}  ${WHITE}Kiểm tra gói ngoại lai${NC}"
    echo -e "      ${GRAY}${DIM}Gói không còn trong repository${NC}"
    echo

    echo -e "  ${ICON_AUTO} ${GREEN}${BOLD}[6]${NC}  ${WHITE}Dọn dẹp tự động (Safe Mode)${NC}"
    echo -e "      ${GRAY}${DIM}Chạy tất cả các thao tác dọn dẹp an toàn${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[7]${NC}  ${WHITE}Quay lại menu chính${NC}"
    echo -e "      ${GRAY}${DIM}Trở về menu chính${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_INFO} ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}1-7${NC}${WHITE} và nhấn Enter${NC}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo
}

# Kiểm tra gói mồ côi
check_orphaned_packages() {
    display_section_header "KIỂM TRA GÓI MỒ CÔI" "${ICON_ORPHAN}"
    
    print_boxed_message "Đang tìm kiếm các gói mồ côi..." "info"
    
    # Kiểm tra gói mồ côi
    local orphans=$(pacman -Qdtq)
    
    if [ -z "$orphans" ]; then
        print_boxed_message "Không tìm thấy gói mồ côi nào. Hệ thống đã sạch!" "success"
        return 0
    fi
    
    echo -e "${YELLOW}${BOLD}Các gói mồ côi được tìm thấy:${NC}"
    echo -e "${DARK_GRAY}────────────────────────────────────────${NC}"
    pacman -Qdt
    echo -e "${DARK_GRAY}────────────────────────────────────────${NC}"
    
    local count=$(echo "$orphans" | wc -l)
    echo -e "${LIGHT_CYAN}${ICON_INFO} Tổng cộng: ${WHITE}${BOLD}$count${NC} ${LIGHT_CYAN}gói mồ côi${NC}"
    echo
    
    if confirm_yn "Bạn có muốn gỡ tất cả các gói mồ côi này không?" "n"; then
        print_boxed_message "Đang gỡ các gói mồ côi..." "info"
        
        if sudo pacman -Rns $orphans; then
            log_info "Đã gỡ thành công các gói mồ côi"
            print_boxed_message "Đã gỡ thành công tất cả gói mồ côi!" "success"
        else
            log_error "Lỗi khi gỡ các gói mồ côi"
            print_boxed_message "Có lỗi xảy ra khi gỡ gói mồ côi!" "error"
        fi
    else
        print_boxed_message "Đã hủy việc gỡ gói mồ côi" "info"
    fi
}

# Dọn cache Pacman
cleanup_pacman_cache() {
    display_section_header "DỌN CACHE PACMAN" "${ICON_CACHE}"
    
    # Kiểm tra xem paccache có được cài đặt không
    if ! command -v paccache >/dev/null 2>&1; then
        print_boxed_message "paccache không được cài đặt. Đang cài đặt pacman-contrib..." "info"
        if sudo pacman -S --noconfirm pacman-contrib; then
            print_boxed_message "Đã cài đặt pacman-contrib thành công!" "success"
        else
            print_boxed_message "Không thể cài đặt pacman-contrib. Hủy thao tác." "error"
            return 1
        fi
    fi
    
    # Hiển thị thông tin cache hiện tại
    local cache_size=$(du -sh /var/cache/pacman/pkg 2>/dev/null | cut -f1)
    echo -e "${YELLOW}${BOLD}Thông tin cache hiện tại:${NC}"
    echo -e "${LIGHT_CYAN}  📁 Đường dẫn: ${WHITE}/var/cache/pacman/pkg${NC}"
    echo -e "${LIGHT_CYAN}  📏 Kích thước: ${WHITE}$cache_size${NC}"
    echo
    
    echo -e "${WHITE}${BOLD}Tùy chọn dọn cache:${NC}"
    echo -e "  ${GREEN}[1]${NC} Giữ lại 3 phiên bản gần nhất (khuyến nghị)"
    echo -e "  ${GREEN}[2]${NC} Giữ lại 1 phiên bản gần nhất"
    echo -e "  ${GREEN}[3]${NC} Xóa toàn bộ cache (cực đoan)"
    echo -e "  ${GREEN}[4]${NC} Hủy"
    echo
    
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}Chọn tùy chọn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-4${DARK_GRAY}]${NC}: "
    local choice=$(read_single_key)
    echo "$choice"
    echo
    
    case $choice in
        1)
            print_boxed_message "Đang dọn cache, giữ lại 3 phiên bản gần nhất..." "info"
            if sudo paccache -r; then
                log_info "Đã dọn cache pacman thành công (giữ 3 phiên bản)"
                print_boxed_message "Đã dọn cache thành công!" "success"
            else
                log_error "Lỗi khi dọn cache pacman"
                print_boxed_message "Có lỗi xảy ra khi dọn cache!" "error"
            fi
            ;;
        2)
            print_boxed_message "Đang dọn cache, giữ lại 1 phiên bản gần nhất..." "info"
            if sudo paccache -rk1; then
                log_info "Đã dọn cache pacman thành công (giữ 1 phiên bản)"
                print_boxed_message "Đã dọn cache thành công!" "success"
            else
                log_error "Lỗi khi dọn cache pacman"
                print_boxed_message "Có lỗi xảy ra khi dọn cache!" "error"
            fi
            ;;
        3)
            if confirm_yn "CẢNH BÁO: Xóa toàn bộ cache có thể khiến bạn không thể downgrade gói. Tiếp tục?" "n"; then
                print_boxed_message "Đang xóa toàn bộ cache..." "info"
                if sudo paccache -rk0; then
                    log_info "Đã xóa toàn bộ cache pacman"
                    print_boxed_message "Đã xóa toàn bộ cache thành công!" "success"
                else
                    log_error "Lỗi khi xóa toàn bộ cache pacman"
                    print_boxed_message "Có lỗi xảy ra khi xóa cache!" "error"
                fi
            else
                print_boxed_message "Đã hủy việc xóa toàn bộ cache" "info"
            fi
            ;;
        4|*)
            print_boxed_message "Đã hủy việc dọn cache" "info"
            ;;
    esac
    
    # Hiển thị kích thước cache sau khi dọn
    local new_cache_size=$(du -sh /var/cache/pacman/pkg 2>/dev/null | cut -f1)
    echo -e "${LIGHT_GREEN}${ICON_INFO} Kích thước cache sau khi dọn: ${WHITE}$new_cache_size${NC}"
}

# Xem gói cài thủ công
review_manual_packages() {
    display_section_header "GÓI CÀI THỦ CÔNG" "${ICON_MANUAL}"
    
    print_boxed_message "Đang tìm kiếm các gói được cài thủ công..." "info"
    
    echo -e "${YELLOW}${BOLD}Các gói được cài thủ công (không tính dependencies):${NC}"
    echo -e "${DARK_GRAY}────────────────────────────────────────────────────────────${NC}"
    pacman -Qent
    echo -e "${DARK_GRAY}────────────────────────────────────────────────────────────${NC}"
    
    local count=$(pacman -Qentq | wc -l)
    echo -e "${LIGHT_CYAN}${ICON_INFO} Tổng cộng: ${WHITE}${BOLD}$count${NC} ${LIGHT_CYAN}gói được cài thủ công${NC}"
    echo
    
    print_boxed_message "Hãy rà soát danh sách để tìm gói không còn sử dụng" "info"
    echo -e "${GRAY}${DIM}Để gỡ gói cụ thể, sử dụng: ${WHITE}sudo pacman -Rns <tên_gói>${DIM}${NC}"
}

# Dọn AUR
cleanup_aur() {
    display_section_header "DỌN AUR VÀ CACHE" "${ICON_PACKAGE}"
    
    # Kiểm tra AUR helper
    local aur_helper=""
    if command -v yay >/dev/null 2>&1; then
        aur_helper="yay"
    elif command -v paru >/dev/null 2>&1; then
        aur_helper="paru"
    else
        print_boxed_message "Không tìm thấy AUR helper (yay hoặc paru). Bỏ qua bước này." "warning"
        return 0
    fi
    
    echo -e "${LIGHT_CYAN}${ICON_INFO} Tìm thấy AUR helper: ${WHITE}${BOLD}$aur_helper${NC}"
    echo
    
    if [ "$aur_helper" = "yay" ]; then
        echo -e "${WHITE}${BOLD}Tùy chọn dọn AUR:${NC}"
        echo -e "  ${GREEN}[1]${NC} Dọn gói AUR mồ côi và dependencies không dùng (yay -Yc)"
        echo -e "  ${GREEN}[2]${NC} Dọn cache của yay (yay -Sc)"
        echo -e "  ${GREEN}[3]${NC} Thực hiện cả hai"
        echo -e "  ${GREEN}[4]${NC} Hủy"
        echo
        
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}Chọn tùy chọn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-4${DARK_GRAY}]${NC}: "
        local choice=$(read_single_key)
        echo "$choice"
        echo
        
        case $choice in
            1)
                print_boxed_message "Đang dọn gói AUR mồ côi..." "info"
                if yay -Yc; then
                    log_info "Đã dọn gói AUR mồ côi thành công"
                    print_boxed_message "Đã dọn gói AUR mồ côi thành công!" "success"
                else
                    log_error "Lỗi khi dọn gói AUR mồ côi"
                    print_boxed_message "Có lỗi xảy ra khi dọn AUR!" "error"
                fi
                ;;
            2)
                print_boxed_message "Đang dọn cache yay..." "info"
                if yay -Sc; then
                    log_info "Đã dọn cache yay thành công"
                    print_boxed_message "Đã dọn cache yay thành công!" "success"
                else
                    log_error "Lỗi khi dọn cache yay"
                    print_boxed_message "Có lỗi xảy ra khi dọn cache yay!" "error"
                fi
                ;;
            3)
                print_boxed_message "Đang dọn gói AUR mồ côi và cache..." "info"
                if yay -Yc && yay -Sc; then
                    log_info "Đã dọn AUR và cache thành công"
                    print_boxed_message "Đã dọn AUR và cache thành công!" "success"
                else
                    log_error "Lỗi khi dọn AUR và cache"
                    print_boxed_message "Có lỗi xảy ra khi dọn AUR!" "error"
                fi
                ;;
            4|*)
                print_boxed_message "Đã hủy việc dọn AUR" "info"
                ;;
        esac
    else
        # paru
        print_boxed_message "Đang dọn với paru..." "info"
        if paru -c; then
            log_info "Đã dọn AUR với paru thành công"
            print_boxed_message "Đã dọn AUR thành công!" "success"
        else
            log_error "Lỗi khi dọn AUR với paru"
            print_boxed_message "Có lỗi xảy ra khi dọn AUR!" "error"
        fi
    fi
}

# Kiểm tra gói ngoại lai
check_foreign_packages() {
    display_section_header "KIỂM TRA GÓI NGOẠI LAI" "${ICON_FOREIGN}"
    
    print_boxed_message "Đang tìm kiếm gói không còn trong repository..." "info"
    
    local foreign_packages=$(pacman -Qmq)
    
    if [ -z "$foreign_packages" ]; then
        print_boxed_message "Không tìm thấy gói ngoại lai nào." "success"
        return 0
    fi
    
    echo -e "${YELLOW}${BOLD}Các gói ngoại lai (không còn trong repository):${NC}"
    echo -e "${DARK_GRAY}────────────────────────────────────────────────────${NC}"
    pacman -Qm
    echo -e "${DARK_GRAY}────────────────────────────────────────────────────${NC}"
    
    local count=$(echo "$foreign_packages" | wc -l)
    echo -e "${LIGHT_CYAN}${ICON_INFO} Tổng cộng: ${WHITE}${BOLD}$count${NC} ${LIGHT_CYAN}gói ngoại lai${NC}"
    echo
    
    print_boxed_message "Hãy kiểm tra xem gói nào không còn cần thiết" "info"
    echo -e "${GRAY}${DIM}Để gỡ gói cụ thể, sử dụng: ${WHITE}sudo pacman -Rns <tên_gói>${DIM}${NC}"
}

# Dọn dẹp tự động (Safe Mode)
auto_cleanup_safe() {
    display_section_header "DỌN DẸP TỰ ĐỘNG (SAFE MODE)" "${ICON_AUTO}"
    
    print_boxed_message "Chế độ dọn dẹp tự động sẽ thực hiện:" "info"
    echo -e "${LIGHT_CYAN}  • ${WHITE}Gỡ gói mồ côi${NC}"
    echo -e "${LIGHT_CYAN}  • ${WHITE}Dọn cache pacman (giữ 2 phiên bản)${NC}"
    echo -e "${LIGHT_CYAN}  • ${WHITE}Dọn AUR mồ côi (nếu có yay/paru)${NC}"
    echo
    
    if ! confirm_yn "Bạn có muốn tiếp tục với chế độ dọn dẹp tự động không?" "y"; then
        print_boxed_message "Đã hủy dọn dẹp tự động" "info"
        return 0
    fi
    
    log_info "Bắt đầu dọn dẹp tự động hệ thống"
    
    # 1. Dọn gói mồ côi
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Bước 1: Dọn gói mồ côi...${NC}"
    local orphans=$(pacman -Qdtq)
    if [ -n "$orphans" ]; then
        if sudo pacman -Rns $orphans; then
            print_boxed_message "✓ Đã gỡ gói mồ côi thành công" "success"
            log_info "Auto cleanup: Đã gỡ gói mồ côi thành công"
        else
            print_boxed_message "✗ Lỗi khi gỡ gói mồ côi" "error"
            log_error "Auto cleanup: Lỗi khi gỡ gói mồ côi"
        fi
    else
        print_boxed_message "✓ Không có gói mồ côi" "success"
    fi
    
    # 2. Dọn cache pacman
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Bước 2: Dọn cache pacman...${NC}"
    if command -v paccache >/dev/null 2>&1; then
        if sudo paccache -rk2; then
            print_boxed_message "✓ Đã dọn cache pacman thành công" "success"
            log_info "Auto cleanup: Đã dọn cache pacman thành công"
        else
            print_boxed_message "✗ Lỗi khi dọn cache pacman" "error"
            log_error "Auto cleanup: Lỗi khi dọn cache pacman"
        fi
    else
        print_boxed_message "⚠ paccache không có sẵn, bỏ qua" "warning"
    fi
    
    # 3. Dọn AUR
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Bước 3: Dọn AUR...${NC}"
    if command -v yay >/dev/null 2>&1; then
        if yay -Yc --noconfirm; then
            print_boxed_message "✓ Đã dọn AUR với yay thành công" "success"
            log_info "Auto cleanup: Đã dọn AUR với yay thành công"
        else
            print_boxed_message "✗ Lỗi khi dọn AUR với yay" "error"
            log_error "Auto cleanup: Lỗi khi dọn AUR với yay"
        fi
    elif command -v paru >/dev/null 2>&1; then
        if paru -c --noconfirm; then
            print_boxed_message "✓ Đã dọn AUR với paru thành công" "success"
            log_info "Auto cleanup: Đã dọn AUR với paru thành công"
        else
            print_boxed_message "✗ Lỗi khi dọn AUR với paru" "error"
            log_error "Auto cleanup: Lỗi khi dọn AUR với paru"
        fi
    else
        print_boxed_message "⚠ Không tìm thấy AUR helper, bỏ qua" "warning"
    fi
    
    echo
    print_boxed_message "🎉 Hoàn tất dọn dẹp tự động!" "success"
    log_info "Hoàn tất dọn dẹp tự động hệ thống"
}

# Hàm chính để quản lý dọn dẹp hệ thống
manage_system_cleanup() {
    local choice

    while true; do
        display_cleanup_menu
        echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập lựa chọn của bạn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-7${DARK_GRAY}]${NC}: "
        choice=$(read_single_key)
        echo "$choice"
        echo

        case $choice in
            1)
                check_orphaned_packages
                ;;
            2)
                cleanup_pacman_cache
                ;;
            3)
                review_manual_packages
                ;;
            4)
                cleanup_aur
                ;;
            5)
                check_foreign_packages
                ;;
            6)
                auto_cleanup_safe
                ;;
            7)
                return 0
                ;;
            *)
                print_boxed_message "Lựa chọn không hợp lệ. Vui lòng chọn số từ 1-7." "error"
                ;;
        esac

        wait_for_user
    done
}
