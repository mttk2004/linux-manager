#!/bin/bash

# Menu Template System - V2 Architecture
# Provides standardized menu configurations and templates

# Menu template directory
MENU_TEMPLATES_DIR="${TEMPLATES_DIR}/menus"

# Create menu template for package manager
create_package_menu_template() {
    declare -gA PACKAGE_MENU_CONFIG=(
        [ascii_header]="package"
        [title]="Package Manager"
        [header]="QUẢN LÝ GÓI"
        [header_icon]="📦"
        
        [option_1_title]="Cài đặt gói từ kho chính thức (Pacman)"
        [option_1_description]="Tìm kiếm và cài đặt gói phần mềm từ kho Arch Linux"
        [option_1_icon]="📦"
        [option_1_action]="install_pacman_packages"
        
        [option_2_title]="Cài đặt gói từ AUR"
        [option_2_description]="Cài đặt phần mềm từ Arch User Repository"
        [option_2_icon]="🏗️"
        [option_2_action]="install_aur_packages"
        
        [option_3_title]="Cài đặt gói Flatpak"
        [option_3_description]="Quản lý và cài đặt ứng dụng Flatpak"
        [option_3_icon]="📱"
        [option_3_action]="install_flatpak_packages"
        
        [option_4_title]="Gỡ cài đặt gói"
        [option_4_description]="Xóa các gói phần mềm không cần thiết"
        [option_4_icon]="🗑️"
        [option_4_action]="remove_packages"
        
        [option_5_title]="Quay lại menu chính"
        [option_5_description]="Trở về menu chính của ứng dụng"
        [option_5_icon]="🔙"
        [option_5_action]="return_main"
        
        [min_choice]=1
        [max_choice]=5
        [exit_option]=5
    )
    
    export PACKAGE_MENU_CONFIG
}

# Create menu template for system management
create_system_menu_template() {
    declare -gA SYSTEM_MENU_CONFIG=(
        [ascii_header]="system"
        [title]="System Management"
        [header]="QUẢN LÝ HỆ THỐNG"
        [header_icon]="⚙️"
        
        [option_1_title]="Cấu hình hệ thống"
        [option_1_description]="Tùy chỉnh các cài đặt hệ thống và môi trường"
        [option_1_icon]="⚙️"
        [option_1_action]="configure_system"
        
        [option_2_title]="Dọn dẹp hệ thống"
        [option_2_description]="Xóa file tạm, cache và gói không cần thiết"
        [option_2_icon]="🧹"
        [option_2_action]="cleanup_system"
        
        [option_3_title]="Cập nhật hệ thống"
        [option_3_description]="Cập nhật toàn bộ hệ thống và các gói"
        [option_3_icon]="🔄"
        [option_3_action]="update_system"
        
        [option_4_title]="Sao lưu và phục hồi"
        [option_4_description]="Quản lý sao lưu cấu hình và dữ liệu"
        [option_4_icon]="💾"
        [option_4_action]="backup_restore"
        
        [option_5_title]="Quay lại menu chính"
        [option_5_description]="Trở về menu chính của ứng dụng"
        [option_5_icon]="🔙"
        [option_5_action]="return_main"
        
        [min_choice]=1
        [max_choice]=5
        [exit_option]=5
    )
    
    export SYSTEM_MENU_CONFIG
}

# Create menu template for development environment
create_dev_menu_template() {
    declare -gA DEV_MENU_CONFIG=(
        [ascii_header]="main"
        [title]="Development Environment"
        [header]="MÔI TRƯỜNG PHÁT TRIỂN"
        [header_icon]="💻"
        
        [option_1_title]="Cài đặt môi trường PHP"
        [option_1_description]="Cài đặt PHP, Composer và Laravel development tools"
        [option_1_icon]="🐘"
        [option_1_action]="setup_php_environment"
        
        [option_2_title]="Cài đặt môi trường NodeJS"
        [option_2_description]="Cài đặt NodeJS, NPM và các công cụ development"
        [option_2_icon]="🟢"
        [option_2_action]="setup_nodejs_environment"
        
        [option_3_title]="Cài đặt Docker"
        [option_3_description]="Cài đặt và cấu hình Docker container platform"
        [option_3_icon]="🐳"
        [option_3_action]="setup_docker_environment"
        
        [option_4_title]="Code Editor & IDE"
        [option_4_description]="Cài đặt VSCode, Vim và các editor khác"
        [option_4_icon]="📝"
        [option_4_action]="setup_editors"
        
        [option_5_title]="Git & Version Control"
        [option_5_description]="Cấu hình Git và các công cụ version control"
        [option_5_icon]="🌿"
        [option_5_action]="setup_version_control"
        
        [option_6_title]="Quay lại menu chính"
        [option_6_description]="Trở về menu chính của ứng dụng"
        [option_6_icon]="🔙"
        [option_6_action]="return_main"
        
        [min_choice]=1
        [max_choice]=6
        [exit_option]=6
    )
    
    export DEV_MENU_CONFIG
}

# Create main menu template
create_main_menu_template() {
    declare -gA MAIN_MENU_CONFIG=(
        [ascii_header]="main"
        [title]="Linux Manager - Công cụ quản lý hệ thống Arch Linux"
        [header]="MENU CHÍNH"
        [header_icon]="🏠"
        
        [option_1_title]="Quản lý gói"
        [option_1_description]="Cài đặt, gỡ bỏ và quản lý các gói phần mềm"
        [option_1_icon]="📦"
        [option_1_action]="manage_packages"
        
        [option_2_title]="Quản lý hệ thống"
        [option_2_description]="Cấu hình, dọn dẹp và bảo trì hệ thống"
        [option_2_icon]="⚙️"
        [option_2_action]="manage_system"
        
        [option_3_title]="Môi trường phát triển"
        [option_3_description]="Cài đặt và cấu hình công cụ lập trình"
        [option_3_icon]="💻"
        [option_3_action]="manage_development"
        
        [option_4_title]="Cấu hình người dùng"
        [option_4_description]="Tùy chỉnh shell, dotfiles và môi trường cá nhân"
        [option_4_icon]="👤"
        [option_4_action]="manage_user_config"
        
        [option_5_title]="Thông tin hệ thống"
        [option_5_description]="Xem thông tin phần cứng và trạng thái hệ thống"
        [option_5_icon]="📊"
        [option_5_action]="show_system_info"
        
        [option_6_title]="Thoát"
        [option_6_description]="Thoát khỏi Linux Manager"
        [option_6_icon]="🚪"
        [option_6_action]="exit_application"
        
        [min_choice]=1
        [max_choice]=6
        [exit_option]=6
    )
    
    export MAIN_MENU_CONFIG
}

# Create cleanup menu template
create_cleanup_menu_template() {
    declare -gA CLEANUP_MENU_CONFIG=(
        [ascii_header]="cleanup"
        [title]="System Cleanup"
        [header]="DỌN DẸP HỆ THỐNG"
        [header_icon]="🧹"
        
        [option_1_title]="Dọn dẹp cache Pacman"
        [option_1_description]="Xóa cache gói đã tải về từ Pacman"
        [option_1_icon]="💾"
        [option_1_action]="cleanup_pacman_cache"
        
        [option_2_title]="Loại bỏ gói mồ côi"
        [option_2_description]="Gỡ bỏ các gói không được dependency nào sử dụng"
        [option_2_icon]="🧩"
        [option_2_action]="remove_orphan_packages"
        
        [option_3_title]="Xóa gói foreign"
        [option_3_description]="Quản lý các gói không có trong repository chính thức"
        [option_3_icon]="🧭"
        [option_3_action]="manage_foreign_packages"
        
        [option_4_title]="Xóa file tạm hệ thống"
        [option_4_description]="Dọn dẹp /tmp, logs và các file tạm thời"
        [option_4_icon]="🗑️"
        [option_4_action]="cleanup_temp_files"
        
        [option_5_title]="Dọn dẹp user cache"
        [option_5_description]="Xóa cache ứng dụng và browser của user"
        [option_5_icon]="👤"
        [option_5_action]="cleanup_user_cache"
        
        [option_6_title]="Dọn dẹp toàn diện"
        [option_6_description]="Thực hiện tất cả các tác vụ dọn dẹp trên"
        [option_6_icon]="🔥"
        [option_6_action]="comprehensive_cleanup"
        
        [option_7_title]="Quay lại menu hệ thống"
        [option_7_description]="Trở về menu quản lý hệ thống"
        [option_7_icon]="🔙"
        [option_7_action]="return_system"
        
        [min_choice]=1
        [max_choice]=7
        [exit_option]=7
    )
    
    export CLEANUP_MENU_CONFIG
}

# Create PHP environment menu template
create_php_menu_template() {
    declare -gA PHP_MENU_CONFIG=(
        [ascii_header]="php"
        [title]="PHP Development Environment"
        [header]="MÔI TRƯỜNG PHP"
        [header_icon]="🐘"
        
        [option_1_title]="Cài đặt PHP từ source"
        [option_1_description]="Compile và cài đặt PHP phiên bản mới nhất"
        [option_1_icon]="⚙️"
        [option_1_action]="install_php_from_source"
        
        [option_2_title]="Cài đặt Composer"
        [option_2_description]="Cài đặt Composer dependency manager"
        [option_2_icon]="📦"
        [option_2_action]="install_composer"
        
        [option_3_title]="Cài đặt Laravel"
        [option_3_description]="Cài đặt Laravel framework và CLI tools"
        [option_3_icon]="🚀"
        [option_3_action]="install_laravel"
        
        [option_4_title]="Cấu hình PHP extensions"
        [option_4_description]="Cài đặt và cấu hình các PHP extensions cần thiết"
        [option_4_icon]="🔧"
        [option_4_action]="configure_php_extensions"
        
        [option_5_title]="Quay lại menu phát triển"
        [option_5_description]="Trở về menu môi trường phát triển"
        [option_5_icon]="🔙"
        [option_5_action]="return_dev"
        
        [min_choice]=1
        [max_choice]=5
        [exit_option]=5
    )
    
    export PHP_MENU_CONFIG
}

# Create NodeJS environment menu template
create_nodejs_menu_template() {
    declare -gA NODEJS_MENU_CONFIG=(
        [ascii_header]="main"
        [title]="NodeJS Development Environment"
        [header]="MÔI TRƯỜNG NODEJS"
        [header_icon]="🟢"
        
        [option_1_title]="Cài đặt NVM"
        [option_1_description]="Cài đặt Node Version Manager"
        [option_1_icon]="🔧"
        [option_1_action]="install_nvm"
        
        [option_2_title]="Cài đặt NodeJS LTS"
        [option_2_description]="Cài đặt phiên bản NodeJS ổn định mới nhất"
        [option_2_icon]="🟢"
        [option_2_action]="install_nodejs_lts"
        
        [option_3_title]="Cài đặt NodeJS Latest"
        [option_3_description]="Cài đặt phiên bản NodeJS mới nhất"
        [option_3_icon]="🚀"
        [option_3_action]="install_nodejs_latest"
        
        [option_4_title]="Cấu hình NPM"
        [option_4_description]="Thiết lập NPM registry và global packages"
        [option_4_icon]="📦"
        [option_4_action]="configure_npm"
        
        [option_5_title]="Quay lại menu phát triển"
        [option_5_description]="Trở về menu môi trường phát triển"
        [option_5_icon]="🔙"
        [option_5_action]="return_dev"
        
        [min_choice]=1
        [max_choice]=5
        [exit_option]=5
    )
    
    export NODEJS_MENU_CONFIG
}

# Initialize all menu templates
init_menu_templates() {
    log_info "MENU_TEMPLATES" "Initializing menu templates..."
    
    create_main_menu_template
    create_package_menu_template
    create_system_menu_template
    create_dev_menu_template
    create_cleanup_menu_template
    create_php_menu_template
    create_nodejs_menu_template
    
    log_info "MENU_TEMPLATES" "Menu templates initialized successfully"
}

# Get menu configuration by name
get_menu_config() {
    local menu_name="$1"
    local config_var_name="${menu_name^^}_MENU_CONFIG"
    
    if declare -p "$config_var_name" >/dev/null 2>&1; then
        echo "$config_var_name"
        return 0
    else
        log_error "MENU_TEMPLATES" "Menu template not found: $menu_name"
        return 1
    fi
}

# Render menu by name
render_menu_by_name() {
    local menu_name="$1"
    local config_name
    
    config_name=$(get_menu_config "$menu_name")
    if [[ $? -eq 0 ]]; then
        render_full_menu "$config_name"
        return 0
    else
        log_error "MENU_TEMPLATES" "Failed to render menu: $menu_name"
        return 1
    fi
}

# Get menu action for choice
get_menu_action() {
    local menu_name="$1"
    local choice="$2"
    local config_name
    
    config_name=$(get_menu_config "$menu_name")
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    declare -n menu_ref="$config_name"
    local action_key="option_${choice}_action"
    
    if [[ -n "${menu_ref[$action_key]:-}" ]]; then
        echo "${menu_ref[$action_key]}"
        return 0
    else
        log_warning "MENU_TEMPLATES" "No action defined for menu: $menu_name, choice: $choice"
        return 1
    fi
}

# Validate menu choice
validate_menu_choice() {
    local menu_name="$1"
    local choice="$2"
    local config_name
    
    config_name=$(get_menu_config "$menu_name")
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    declare -n menu_ref="$config_name"
    local min_choice="${menu_ref[min_choice]:-1}"
    local max_choice="${menu_ref[max_choice]:-1}"
    
    if [[ "$choice" -ge "$min_choice" && "$choice" -le "$max_choice" ]]; then
        return 0
    else
        return 1
    fi
}

# Check if choice is exit option
is_exit_choice() {
    local menu_name="$1"
    local choice="$2"
    local config_name
    
    config_name=$(get_menu_config "$menu_name")
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    declare -n menu_ref="$config_name"
    local exit_choice="${menu_ref[exit_option]:-1}"
    
    if [[ "$choice" -eq "$exit_choice" ]]; then
        return 0
    else
        return 1
    fi
}

# Export key functions
export -f init_menu_templates get_menu_config render_menu_by_name
export -f get_menu_action validate_menu_choice is_exit_choice
