#!/bin/bash

# Xác định đường dẫn thư mục hiện tại
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="$(cd "${SCRIPT_DIR}/../../../core" && pwd)"

# Tải các module cần thiết
source "${SCRIPT_DIR}/utils.sh"
source "${CORE_DIR}/utils.sh"
source "${CORE_DIR}/ui.sh"

# Cài đặt Node.js
install_nodejs() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Đang cài đặt Node.js...${NC}"

    # Kiểm tra xem NVM đã được cài đặt chưa
    if ! check_nvm_installed; then
        print_boxed_message "NVM chưa được cài đặt. Vui lòng cài đặt NVM trước." "error"
        return 1
    fi

    show_spinner "Chuẩn bị cài đặt Node.js" 1

    # Hiển thị menu lựa chọn phiên bản Node.js
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_NODE} ${BOLD}CÀI ĐẶT NODE.JS${NC} ${ICON_NODE}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Node.js LTS${NC} ${LIGHT_GREEN}(Khuyến nghị)${NC}"
    echo -e "      ${GRAY}${DIM}Phiên bản LTS mới nhất${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Node.js Latest${NC}"
    echo -e "      ${GRAY}${DIM}Phiên bản mới nhất${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Node.js Cụ thể${NC}"
    echo -e "      ${GRAY}${DIM}Chọn phiên bản cụ thể${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Yêu cầu người dùng chọn phiên bản
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Chọn phiên bản Node.js${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-3${DARK_GRAY}]${NC}: "
    read -n 1 node_choice
    echo

    # Xử lý lựa chọn
    case $node_choice in
        1)
            version="--lts"
            version_desc="LTS"
            ;;
        2)
            version="node"
            version_desc="Latest"
            ;;
        3)
            echo
            echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập phiên bản Node.js (ví dụ: 18, 20.10.0)${NC}: "
            read version
            version_desc="$version"
            ;;
        *)
            print_boxed_message "Lựa chọn không hợp lệ" "error"
            return 1
            ;;
    esac

    # Cài đặt Node.js thông qua NVM
    print_boxed_message "Đang cài đặt Node.js phiên bản $version_desc thông qua NVM" "info"
    show_spinner "Cài đặt Node.js" 2

    # Thực hiện cài đặt thông qua NVM
    if is_fish_shell; then
        # Với Fish shell, sử dụng nvm.fish
        if [ "$version" == "--lts" ]; then
            run_with_fish "nvm install --lts"
        else
            run_with_fish "nvm install $version"
        fi
    else
        # Với Bash hoặc shells khác
        run_with_bash "nvm install $version"
    fi

    # Kiểm tra kết quả cài đặt
    if [ $? -ne 0 ]; then
        print_boxed_message "Cài đặt Node.js không thành công. Vui lòng thử lại." "error"
        return 1
    fi

    # Đặt phiên bản mặc định
    if is_fish_shell; then
        if [ "$version" == "--lts" ]; then
            run_with_fish "nvm use --lts"
            run_with_fish "nvm alias default 'lts/*'"
        else
            run_with_fish "nvm use $version"
            run_with_fish "nvm alias default $version"
        fi
    else
        if [ "$version" == "--lts" ]; then
            run_with_bash "nvm use --lts"
            run_with_bash "nvm alias default 'lts/*'"
        else
            run_with_bash "nvm use $version"
            run_with_bash "nvm alias default $version"
        fi
    fi

    # Lấy phiên bản đã cài đặt
    local installed_version=$(get_nodejs_version)

    # Hiển thị thông báo thành công
    print_boxed_message "Đã cài đặt Node.js phiên bản $installed_version thành công" "success"
    print_boxed_message "NPM đã được cài đặt kèm theo Node.js" "info"
}

# Quản lý phiên bản Node.js
manage_nodejs_versions() {
    echo -e "${LIGHT_YELLOW}${ICON_GEAR} Quản lý phiên bản Node.js...${NC}"

    # Kiểm tra xem NVM đã được cài đặt chưa
    if ! check_nvm_installed; then
        print_boxed_message "NVM chưa được cài đặt. Vui lòng cài đặt NVM trước." "error"
        return 1
    fi

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}                    ${ICON_NODE} ${BOLD}QUẢN LÝ PHIÊN BẢN NODE.JS${NC} ${ICON_NODE}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Menu items với style đơn giản và hiện đại
    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[1]${NC}  ${WHITE}Liệt kê phiên bản đã cài đặt${NC}"
    echo -e "      ${GRAY}${DIM}Xem các phiên bản Node.js đã cài đặt${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[2]${NC}  ${WHITE}Liệt kê phiên bản có sẵn${NC}"
    echo -e "      ${GRAY}${DIM}Xem các phiên bản Node.js có thể cài đặt${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[3]${NC}  ${WHITE}Chuyển đổi phiên bản${NC}"
    echo -e "      ${GRAY}${DIM}Chọn phiên bản Node.js để sử dụng${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[4]${NC}  ${WHITE}Đặt phiên bản mặc định${NC}"
    echo -e "      ${GRAY}${DIM}Đặt phiên bản Node.js mặc định${NC}"
    echo

    echo -e "  ${ICON_NODE} ${GREEN}${BOLD}[5]${NC}  ${WHITE}Gỡ cài đặt phiên bản${NC}"
    echo -e "      ${GRAY}${DIM}Xóa phiên bản Node.js đã cài đặt${NC}"
    echo

    echo -e "  ${ICON_EXIT} ${LIGHT_RED}${BOLD}[6]${NC}  ${WHITE}Quay lại${NC}"
    echo -e "      ${GRAY}${DIM}Quay lại menu trước${NC}"
    echo

    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo

    # Yêu cầu người dùng chọn tùy chọn
    echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Chọn tùy chọn${NC} ${DARK_GRAY}[${LIGHT_GREEN}1-6${DARK_GRAY}]${NC}: "
    read -n 1 version_choice
    echo

    # Xử lý lựa chọn
    case $version_choice in
        1)
            # Liệt kê phiên bản đã cài đặt
            print_boxed_message "Đang liệt kê các phiên bản Node.js đã cài đặt" "info"

            if is_fish_shell; then
                run_with_fish "nvm list"
            else
                run_with_bash "nvm ls"
            fi

            echo
            print_boxed_message "Đã liệt kê các phiên bản Node.js đã cài đặt" "success"
            ;;

        2)
            # Liệt kê phiên bản có sẵn
            print_boxed_message "Đang liệt kê các phiên bản Node.js có sẵn (LTS)" "info"
            print_boxed_message "Quá trình này có thể mất một chút thời gian" "info"

            if is_fish_shell; then
                run_with_fish "nvm ls-remote --lts | grep -i 'lts' | tail -n 10"
            else
                run_with_bash "nvm ls-remote --lts | grep -i 'lts' | tail -n 10"
            fi

            echo
            print_boxed_message "Đã liệt kê các phiên bản Node.js có sẵn" "success"
            ;;

        3)
            # Chuyển đổi phiên bản
            echo
            echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập phiên bản Node.js muốn sử dụng${NC} (ví dụ: 18, 20, --lts): "
            read version_to_use

            print_boxed_message "Đang chuyển đổi sang Node.js phiên bản $version_to_use" "info"

            if is_fish_shell; then
                run_with_fish "nvm use $version_to_use"
            else
                run_with_bash "nvm use $version_to_use"
            fi

            if [ $? -eq 0 ]; then
                print_boxed_message "Đã chuyển đổi sang Node.js phiên bản $version_to_use thành công" "success"
            else
                print_boxed_message "Không thể chuyển đổi sang phiên bản $version_to_use. Phiên bản này có thể chưa được cài đặt." "error"
            fi
            ;;

        4)
            # Đặt phiên bản mặc định
            echo
            echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập phiên bản Node.js muốn đặt làm mặc định${NC} (ví dụ: 18, 20, lts/*): "
            read default_version

            print_boxed_message "Đang đặt Node.js phiên bản $default_version làm mặc định" "info"

            if is_fish_shell; then
                run_with_fish "nvm alias default $default_version"
            else
                run_with_bash "nvm alias default $default_version"
            fi

            if [ $? -eq 0 ]; then
                print_boxed_message "Đã đặt Node.js phiên bản $default_version làm mặc định thành công" "success"
            else
                print_boxed_message "Không thể đặt phiên bản $default_version làm mặc định. Phiên bản này có thể chưa được cài đặt." "error"
            fi
            ;;

        5)
            # Gỡ cài đặt phiên bản
            echo
            echo -e -n "${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${BOLD}Nhập phiên bản Node.js muốn gỡ cài đặt${NC} (ví dụ: 18, 20.10.0): "
            read version_to_uninstall

            print_boxed_message "Đang gỡ cài đặt Node.js phiên bản $version_to_uninstall" "info"

            if is_fish_shell; then
                run_with_fish "nvm uninstall $version_to_uninstall"
            else
                run_with_bash "nvm uninstall $version_to_uninstall"
            fi

            if [ $? -eq 0 ]; then
                print_boxed_message "Đã gỡ cài đặt Node.js phiên bản $version_to_uninstall thành công" "success"
            else
                print_boxed_message "Không thể gỡ cài đặt phiên bản $version_to_uninstall. Phiên bản này có thể không tồn tại hoặc đang được sử dụng." "error"
            fi
            ;;

        6)
            # Quay lại menu trước
            return 0
            ;;

        *)
            print_boxed_message "Lựa chọn không hợp lệ. Vui lòng chọn số từ 1-6." "error"
            ;;
    esac

    return 0
}
