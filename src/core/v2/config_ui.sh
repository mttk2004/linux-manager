#!/bin/bash

# Configuration UI System - V2 Architecture
# Provides interactive configuration management interface

# Initialize configuration UI system
init_config_ui() {
    log_debug "CONFIG_UI" "Configuration UI system initialized"
}

# Show configuration management menu
show_config_menu() {
    while true; do
        clear
        render_ascii_header "main" "CONFIGURATION MANAGEMENT"
        
        render_menu_header "QUẢN LÝ CẤU HÌNH" "$(get_icon CONFIG)"
        
        render_menu_option "1" "Xem tất cả cấu hình" "Hiển thị toàn bộ cấu hình hệ thống" "$(get_icon SEARCH)"
        render_menu_option "2" "Cấu hình theo danh mục" "Quản lý cấu hình theo từng danh mục" "$(get_icon FOLDER)"
        render_menu_option "3" "Chỉnh sửa cấu hình" "Thay đổi giá trị cấu hình" "$(get_icon GEAR)"
        render_menu_option "4" "Tạo cấu hình mẫu" "Tạo file cấu hình mặc định" "$(get_icon FILE)"
        render_menu_option "5" "Khôi phục mặc định" "Đặt lại cấu hình về giá trị mặc định" "$(get_icon AUTO)"
        render_menu_option "6" "Xuất cấu hình" "Xuất cấu hình sang file hoặc environment" "$(get_icon PACKAGE)"
        render_menu_option "7" "Quay lại menu chính" "Trở về menu chính" "$(get_icon EXIT)"
        
        render_menu_footer "1" "7"
        
        render_input_prompt "Chọn tùy chọn" "1-7"
        
        local choice
        read -r choice
        
        case "$choice" in
            1) show_all_configurations ;;
            2) show_category_configuration_menu ;;
            3) edit_configuration_interactive ;;
            4) create_sample_configurations ;;
            5) reset_configuration_interactive ;;
            6) export_configuration_menu ;;
            7) break ;;
            *) render_status_message "Lựa chọn không hợp lệ: $choice" "error" ;;
        esac
        
        if [[ "$choice" != "7" ]]; then
            echo
            render_input_prompt "Nhấn Enter để tiếp tục"
            read -r
        fi
    done
}

# Show all configurations
show_all_configurations() {
    clear
    render_ascii_header "main" "ALL SYSTEM CONFIGURATIONS"
    
    render_menu_header "TẤT CẢ CẤU HÌNH HỆ THỐNG" "$(get_icon SEARCH)"
    
    # Get all categories
    local categories
    readarray -t categories < <(get_config_categories)
    
    for category in "${categories[@]}"; do
        echo -e "${WHITE}${BOLD}${category^^}:${NC}"
        
        # Get configurations for this category
        while IFS='=' read -r key value; do
            [[ -z "$key" ]] && continue
            
            local description="${CONFIG_DESCRIPTIONS[$key]:-}"
            local default_value="${CONFIG_DEFAULTS[$key]:-}"
            local current_value="$value"
            
            # Color code based on whether value differs from default
            local value_color="$LIGHT_CYAN"
            if [[ "$current_value" != "$default_value" ]]; then
                value_color="$LIGHT_YELLOW"
            fi
            
            echo -e "  ${LIGHT_GREEN}${key}${NC}: ${value_color}${current_value}${NC}"
            if [[ -n "$description" ]]; then
                echo -e "    ${GRAY}${DIM}${description}${NC}"
            fi
            if [[ "$current_value" != "$default_value" ]]; then
                echo -e "    ${GRAY}${DIM}Mặc định: ${default_value}${NC}"
            fi
            echo
        done < <(get_config_by_category "$category")
        
        echo
    done
    
    # Show configuration source priority
    render_menu_header "PRIORITY ORDER" "$(get_icon INFO)"
    echo -e "${WHITE}${BOLD}Thứ tự ưu tiên cấu hình:${NC}"
    echo -e "  ${LIGHT_GREEN}1.${NC} Environment variables (LM_*)"
    echo -e "  ${LIGHT_GREEN}2.${NC} Override file (${CONFIG_OVERRIDE_FILE})"
    echo -e "  ${LIGHT_GREEN}3.${NC} Environment-specific (${CONFIG_USER_DIR}/${DETECTED_ENVIRONMENT}.conf)"
    echo -e "  ${LIGHT_GREEN}4.${NC} User configuration (${CONFIG_USER_FILE})"
    echo -e "  ${LIGHT_GREEN}5.${NC} Global configuration (${CONFIG_GLOBAL_FILE})"
    echo -e "  ${LIGHT_GREEN}6.${NC} Default configuration (${CONFIG_DEFAULT_FILE})"
}

# Show configuration by category menu
show_category_configuration_menu() {
    while true; do
        clear
        render_ascii_header "main" "CONFIGURATION BY CATEGORY"
        
        render_menu_header "CHỌN DANH MỤC CẤU HÌNH" "$(get_icon FOLDER)"
        
        local categories
        readarray -t categories < <(get_config_categories)
        
        local option_num=1
        for category in "${categories[@]}"; do
            local category_display="${category^}"
            local icon="$(get_icon CONFIG)"
            
            # Use specific icons for known categories
            case "$category" in
                "core") icon="$(get_icon GEAR)" ;;
                "ui") icon="$(get_icon STAR)" ;;
                "performance") icon="$(get_icon ROCKET)" ;;
                "packages") icon="$(get_icon PACKAGE)" ;;
                "security") icon="$(get_icon WARNING)" ;;
                "development") icon="$(get_icon PHP)" ;;
            esac
            
            render_menu_option "$option_num" "$category_display" "Cấu hình ${category_display,,}" "$icon"
            ((option_num++))
        done
        
        render_menu_option "$option_num" "Quay lại" "Trở về menu cấu hình chính" "$(get_icon EXIT)"
        
        render_menu_footer "1" "$option_num"
        
        render_input_prompt "Chọn danh mục" "1-$option_num"
        
        local choice
        read -r choice
        
        if [[ "$choice" -eq "$option_num" ]]; then
            break
        elif [[ "$choice" -ge 1 && "$choice" -lt "$option_num" ]]; then
            local selected_category="${categories[$((choice - 1))]}"
            show_category_configurations "$selected_category"
        else
            render_status_message "Lựa chọn không hợp lệ: $choice" "error"
            sleep 1
        fi
    done
}

# Show configurations for a specific category
show_category_configurations() {
    local category="$1"
    
    clear
    render_ascii_header "main" "CATEGORY: ${category^^}"
    
    render_menu_header "CẤU HÌNH ${category^^}" "$(get_icon FOLDER)"
    
    # Show all configurations in this category
    while IFS='=' read -r key value; do
        [[ -z "$key" ]] && continue
        
        local description="${CONFIG_DESCRIPTIONS[$key]:-}"
        local default_value="${CONFIG_DEFAULTS[$key]:-}"
        local validator="${CONFIG_VALIDATORS[$key]:-}"
        local current_value="$value"
        
        echo -e "${WHITE}${BOLD}${key}${NC}"
        echo -e "  ${LIGHT_CYAN}Giá trị hiện tại: ${LIGHT_YELLOW}${current_value}${NC}"
        echo -e "  ${GRAY}Giá trị mặc định: ${default_value}${NC}"
        echo -e "  ${GRAY}Mô tả: ${description}${NC}"
        echo -e "  ${GRAY}Kiểu dữ liệu: ${validator}${NC}"
        
        # Show if value is modified
        if [[ "$current_value" != "$default_value" ]]; then
            echo -e "  ${LIGHT_GREEN}$(get_icon CHECK) Đã tùy chỉnh${NC}"
        fi
        
        echo
    done < <(get_config_by_category "$category")
    
    echo
    render_input_prompt "Nhấn Enter để tiếp tục"
    read -r
}

# Interactive configuration editor
edit_configuration_interactive() {
    while true; do
        clear
        render_ascii_header "main" "CONFIGURATION EDITOR"
        
        render_menu_header "CHỈNH SỬA CẤU HÌNH" "$(get_icon GEAR)"
        
        # List available configuration keys
        echo -e "${WHITE}${BOLD}Các cấu hình có sẵn:${NC}"
        echo
        
        local config_keys=()
        for key in "${!CONFIG_DEFAULTS[@]}"; do
            config_keys+=("$key")
        done
        
        # Sort configuration keys
        IFS=$'\n' config_keys=($(sort <<<"${config_keys[*]}"))
        
        # Display in columns
        local col=0
        for key in "${config_keys[@]}"; do
            printf "%-25s" "$key"
            ((col++))
            if [[ $col -eq 3 ]]; then
                echo
                col=0
            fi
        done
        [[ $col -ne 0 ]] && echo
        
        echo
        render_input_prompt "Nhập tên cấu hình cần chỉnh sửa (hoặc 'exit' để thoát)"
        
        local config_key
        read -r config_key
        
        if [[ "$config_key" == "exit" ]]; then
            break
        fi
        
        if [[ -z "${CONFIG_DEFAULTS[$config_key]:-}" ]]; then
            render_status_message "Cấu hình không tồn tại: $config_key" "error"
            sleep 2
            continue
        fi
        
        edit_single_configuration "$config_key"
    done
}

# Edit a single configuration
edit_single_configuration() {
    local key="$1"
    
    clear
    render_ascii_header "main" "EDIT: $key"
    
    render_menu_header "CHỈNH SỬA CẤU HÌNH: $key" "$(get_icon GEAR)"
    
    local current_value="${CONFIG_VALUES[$key]}"
    local default_value="${CONFIG_DEFAULTS[$key]}"
    local description="${CONFIG_DESCRIPTIONS[$key]}"
    local validator="${CONFIG_VALIDATORS[$key]}"
    
    echo -e "${WHITE}${BOLD}Thông tin cấu hình:${NC}"
    echo -e "  ${LIGHT_GREEN}Tên: ${key}${NC}"
    echo -e "  ${LIGHT_CYAN}Giá trị hiện tại: ${LIGHT_YELLOW}${current_value}${NC}"
    echo -e "  ${GRAY}Giá trị mặc định: ${default_value}${NC}"
    echo -e "  ${GRAY}Mô tả: ${description}${NC}"
    echo -e "  ${GRAY}Kiểu dữ liệu: ${validator}${NC}"
    echo
    
    # Show validation help
    show_validation_help "$validator"
    
    echo
    render_input_prompt "Nhập giá trị mới (hoặc Enter để giữ nguyên)"
    
    local new_value
    read -r new_value
    
    if [[ -z "$new_value" ]]; then
        render_status_message "Giữ nguyên giá trị hiện tại" "info"
        return 0
    fi
    
    # Validate the new value
    if validate_config_value "$key" "$new_value"; then
        # Ask if user wants to persist the change
        echo
        render_confirmation "Lưu thay đổi vào file cấu hình người dùng?" "y"
        
        local persist_choice
        read -r persist_choice
        
        local persist=false
        if [[ "$persist_choice" =~ ^[yY]$ ]]; then
            persist=true
        fi
        
        if set_config "$key" "$new_value" "$persist"; then
            render_status_message "Cấu hình đã được cập nhật thành công!" "success"
        else
            render_status_message "Không thể cập nhật cấu hình" "error"
        fi
    else
        render_status_message "Giá trị không hợp lệ: $new_value" "error"
    fi
    
    echo
    render_input_prompt "Nhấn Enter để tiếp tục"
    read -r
}

# Show validation help for a validator
show_validation_help() {
    local validator="$1"
    
    echo -e "${WHITE}${BOLD}Định dạng giá trị:${NC}"
    
    case "$validator" in
        "boolean")
            echo -e "  ${LIGHT_GREEN}Kiểu boolean: ${LIGHT_CYAN}true${NC} hoặc ${LIGHT_CYAN}false${NC}"
            ;;
        "integer")
            echo -e "  ${LIGHT_GREEN}Kiểu số nguyên: ${LIGHT_CYAN}Ví dụ: 100, 500${NC}"
            ;;
        "integer:"*)
            local range="${validator#integer:}"
            local min="${range%,*}"
            local max="${range#*,}"
            echo -e "  ${LIGHT_GREEN}Kiểu số nguyên từ ${min} đến ${max}: ${LIGHT_CYAN}Ví dụ: $min, $max${NC}"
            ;;
        "enum:"*)
            local options="${validator#enum:}"
            echo -e "  ${LIGHT_GREEN}Chọn một trong các giá trị: ${LIGHT_CYAN}${options//,/, }${NC}"
            ;;
        "version")
            echo -e "  ${LIGHT_GREEN}Kiểu phiên bản: ${LIGHT_CYAN}Ví dụ: 1.0.0, 2.1.5${NC}"
            ;;
        "string")
            echo -e "  ${LIGHT_GREEN}Kiểu chuỗi: ${LIGHT_CYAN}Bất kỳ văn bản nào${NC}"
            ;;
        *)
            echo -e "  ${LIGHT_GREEN}Kiểu tùy chỉnh: ${LIGHT_CYAN}$validator${NC}"
            ;;
    esac
}

# Interactive configuration reset
reset_configuration_interactive() {
    while true; do
        clear
        render_ascii_header "main" "RESET CONFIGURATION"
        
        render_menu_header "KHÔI PHỤC CẤU HÌNH" "$(get_icon AUTO)"
        
        render_menu_option "1" "Khôi phục một cấu hình" "Đặt lại giá trị mặc định cho một cấu hình" "$(get_icon CONFIG)"
        render_menu_option "2" "Khôi phục theo danh mục" "Đặt lại tất cả cấu hình trong một danh mục" "$(get_icon FOLDER)"
        render_menu_option "3" "Khôi phục toàn bộ" "Đặt lại tất cả cấu hình về mặc định" "$(get_icon AUTO)"
        render_menu_option "4" "Quay lại" "Trở về menu cấu hình chính" "$(get_icon EXIT)"
        
        render_menu_footer "1" "4"
        
        render_input_prompt "Chọn tùy chọn" "1-4"
        
        local choice
        read -r choice
        
        case "$choice" in
            1) reset_single_configuration ;;
            2) reset_category_configurations ;;
            3) reset_all_configurations ;;
            4) break ;;
            *) render_status_message "Lựa chọn không hợp lệ: $choice" "error" ;;
        esac
        
        if [[ "$choice" != "4" ]]; then
            echo
            render_input_prompt "Nhấn Enter để tiếp tục"
            read -r
        fi
    done
}

# Reset a single configuration
reset_single_configuration() {
    clear
    render_ascii_header "main" "RESET SINGLE CONFIGURATION"
    
    render_menu_header "KHÔI PHỤC MỘT CẤU HÌNH" "$(get_icon CONFIG)"
    
    render_input_prompt "Nhập tên cấu hình cần khôi phục"
    
    local config_key
    read -r config_key
    
    if [[ -z "${CONFIG_DEFAULTS[$config_key]:-}" ]]; then
        render_status_message "Cấu hình không tồn tại: $config_key" "error"
        return 1
    fi
    
    local current_value="${CONFIG_VALUES[$config_key]}"
    local default_value="${CONFIG_DEFAULTS[$config_key]}"
    
    echo
    echo -e "${WHITE}${BOLD}Thông tin khôi phục:${NC}"
    echo -e "  ${LIGHT_GREEN}Cấu hình: ${config_key}${NC}"
    echo -e "  ${LIGHT_YELLOW}Giá trị hiện tại: ${current_value}${NC}"
    echo -e "  ${LIGHT_CYAN}Giá trị mặc định: ${default_value}${NC}"
    echo
    
    if [[ "$current_value" == "$default_value" ]]; then
        render_status_message "Cấu hình đã ở giá trị mặc định" "info"
        return 0
    fi
    
    render_confirmation "Xác nhận khôi phục cấu hình này?" "y"
    
    local confirm
    read -r confirm
    
    if [[ "$confirm" =~ ^[yY]$ ]]; then
        if reset_config "$config_key" true; then
            render_status_message "Cấu hình đã được khôi phục thành công!" "success"
        else
            render_status_message "Không thể khôi phục cấu hình" "error"
        fi
    else
        render_status_message "Hủy bỏ khôi phục cấu hình" "info"
    fi
}

# Reset all configurations in a category
reset_category_configurations() {
    clear
    render_ascii_header "main" "RESET CATEGORY CONFIGURATIONS"
    
    render_menu_header "CHỌN DANH MỤC KHÔI PHỤC" "$(get_icon FOLDER)"
    
    local categories
    readarray -t categories < <(get_config_categories)
    
    local option_num=1
    for category in "${categories[@]}"; do
        render_menu_option "$option_num" "${category^}" "Khôi phục tất cả cấu hình ${category}" "$(get_icon CONFIG)"
        ((option_num++))
    done
    
    render_menu_footer "1" "$((option_num - 1))"
    
    render_input_prompt "Chọn danh mục" "1-$((option_num - 1))"
    
    local choice
    read -r choice
    
    if [[ "$choice" -ge 1 && "$choice" -lt "$option_num" ]]; then
        local selected_category="${categories[$((choice - 1))]}"
        
        echo
        render_confirmation "Xác nhận khôi phục tất cả cấu hình trong danh mục '$selected_category'?" "y"
        
        local confirm
        read -r confirm
        
        if [[ "$confirm" =~ ^[yY]$ ]]; then
            local reset_count=0
            
            while IFS='=' read -r key value; do
                [[ -z "$key" ]] && continue
                
                if reset_config "$key" true; then
                    ((reset_count++))
                    echo -e "${LIGHT_GREEN}$(get_icon CHECK) Khôi phục: ${key}${NC}"
                else
                    echo -e "${LIGHT_RED}$(get_icon CROSS) Lỗi: ${key}${NC}"
                fi
            done < <(get_config_by_category "$selected_category")
            
            echo
            render_status_message "Đã khôi phục $reset_count cấu hình trong danh mục '$selected_category'" "success"
        else
            render_status_message "Hủy bỏ khôi phục danh mục" "info"
        fi
    else
        render_status_message "Lựa chọn không hợp lệ: $choice" "error"
    fi
}

# Reset all configurations
reset_all_configurations() {
    clear
    render_ascii_header "main" "RESET ALL CONFIGURATIONS"
    
    render_menu_header "KHÔI PHỤC TẤT CẢ CẤU HÌNH" "$(get_icon WARNING)"
    
    echo -e "${LIGHT_RED}${BOLD}CẢNH BÁO:${NC} ${WHITE}Thao tác này sẽ đặt lại tất cả cấu hình về giá trị mặc định!${NC}"
    echo -e "${GRAY}Các tùy chỉnh hiện tại sẽ bị mất.${NC}"
    echo
    
    render_confirmation "Bạn có chắc chắn muốn khôi phục tất cả cấu hình?" "n"
    
    local confirm
    read -r confirm
    
    if [[ "$confirm" =~ ^[yY]$ ]]; then
        echo
        render_confirmation "Xác nhận lần cuối - Khôi phục TẤT CẢ cấu hình?" "n"
        
        local final_confirm
        read -r final_confirm
        
        if [[ "$final_confirm" =~ ^[yY]$ ]]; then
            render_status_message "Đang khôi phục tất cả cấu hình..." "info"
            
            local reset_count=0
            local total_configs=${#CONFIG_DEFAULTS[@]}
            
            for key in "${!CONFIG_DEFAULTS[@]}"; do
                if reset_config "$key" true; then
                    ((reset_count++))
                fi
                
                # Show progress
                render_progress "$reset_count" "$total_configs" "Khôi phục cấu hình"
                sleep 0.1
            done
            
            echo
            render_status_message "Đã khôi phục $reset_count/$total_configs cấu hình thành công!" "success"
        else
            render_status_message "Hủy bỏ khôi phục tất cả cấu hình" "info"
        fi
    else
        render_status_message "Hủy bỏ khôi phục tất cả cấu hình" "info"
    fi
}

# Create sample configuration files
create_sample_configurations() {
    clear
    render_ascii_header "main" "CREATE SAMPLE CONFIGURATIONS"
    
    render_menu_header "TẠO CẤU HÌNH MẪU" "$(get_icon FILE)"
    
    render_menu_option "1" "Tạo file cấu hình mặc định" "Tạo ${CONFIG_DEFAULT_FILE}" "$(get_icon FILE)"
    render_menu_option "2" "Tạo file cấu hình người dùng" "Tạo ${CONFIG_USER_FILE}" "$(get_icon FILE)"
    render_menu_option "3" "Tạo cấu hình môi trường" "Tạo file cấu hình cho môi trường hiện tại" "$(get_icon FILE)"
    render_menu_option "4" "Quay lại" "Trở về menu cấu hình chính" "$(get_icon EXIT)"
    
    render_menu_footer "1" "4"
    
    render_input_prompt "Chọn tùy chọn" "1-4"
    
    local choice
    read -r choice
    
    case "$choice" in
        1) 
            if create_default_config_file; then
                render_status_message "File cấu hình mặc định đã được tạo!" "success"
            else
                render_status_message "Không thể tạo file cấu hình mặc định" "error"
            fi
            ;;
        2) create_user_config_sample ;;
        3) create_environment_config_sample ;;
        4) return ;;
        *) render_status_message "Lựa chọn không hợp lệ: $choice" "error" ;;
    esac
    
    if [[ "$choice" != "4" ]]; then
        echo
        render_input_prompt "Nhấn Enter để tiếp tục"
        read -r
    fi
}

# Create user configuration sample
create_user_config_sample() {
    mkdir -p "$(dirname "$CONFIG_USER_FILE")" 2>/dev/null
    
    cat > "$CONFIG_USER_FILE" << 'EOF'
# Linux Manager User Configuration
# Customize your settings here

# UI Settings
UI_THEME="default"
UI_ANIMATION_ENABLED=true

# Performance Settings  
PERF_CACHE_ENABLED=true
CACHE_TTL=600

# Package Settings
PREFERRED_AUR_HELPER="auto"
PACKAGE_PARALLEL_JOBS=4

# Add your custom settings below:

EOF
    
    render_status_message "File cấu hình người dùng đã được tạo: $CONFIG_USER_FILE" "success"
}

# Create environment configuration sample
create_environment_config_sample() {
    local env_config_file="${CONFIG_USER_DIR}/${DETECTED_ENVIRONMENT}.conf"
    
    mkdir -p "$(dirname "$env_config_file")" 2>/dev/null
    
    cat > "$env_config_file" << EOF
# Linux Manager ${DETECTED_ENVIRONMENT^} Environment Configuration
# Settings specific to ${DETECTED_ENVIRONMENT} environment

EOF
    
    case "$DETECTED_ENVIRONMENT" in
        "development")
            cat >> "$env_config_file" << 'EOF'
# Development Settings
DEBUG_MODE=true
VERBOSE_LOGGING=true
LOG_LEVEL="DEBUG"
DEVELOPMENT_MODE=true

# Performance Settings for Development
PERF_CACHE_ENABLED=false
CACHE_TTL=60
EOF
            ;;
        "testing")
            cat >> "$env_config_file" << 'EOF'
# Testing Settings
DEBUG_MODE=true
VERBOSE_LOGGING=false
LOG_LEVEL="INFO"

# Testing Performance Settings
PERF_CACHE_ENABLED=true
CACHE_TTL=30
EOF
            ;;
        "production")
            cat >> "$env_config_file" << 'EOF'
# Production Settings
DEBUG_MODE=false
VERBOSE_LOGGING=false
LOG_LEVEL="WARNING"

# Production Performance Settings
PERF_CACHE_ENABLED=true
CACHE_TTL=1800
EOF
            ;;
    esac
    
    render_status_message "File cấu hình môi trường đã được tạo: $env_config_file" "success"
}

# Export configuration menu
export_configuration_menu() {
    clear
    render_ascii_header "main" "EXPORT CONFIGURATION"
    
    render_menu_header "XUẤT CẤU HÌNH" "$(get_icon PACKAGE)"
    
    render_menu_option "1" "Xuất sang environment variables" "Export cấu hình thành biến môi trường" "$(get_icon GEAR)"
    render_menu_option "2" "Xuất sang file" "Lưu cấu hình hiện tại ra file" "$(get_icon FILE)"
    render_menu_option "3" "Hiển thị script export" "Tạo script để export cấu hình" "$(get_icon FILE)"
    render_menu_option "4" "Quay lại" "Trở về menu cấu hình chính" "$(get_icon EXIT)"
    
    render_menu_footer "1" "4"
    
    render_input_prompt "Chọn tùy chọn" "1-4"
    
    local choice
    read -r choice
    
    case "$choice" in
        1) 
            export_config_as_env
            render_status_message "Cấu hình đã được export thành environment variables" "success"
            ;;
        2) export_config_to_file ;;
        3) show_export_script ;;
        4) return ;;
        *) render_status_message "Lựa chọn không hợp lệ: $choice" "error" ;;
    esac
    
    if [[ "$choice" != "4" ]]; then
        echo
        render_input_prompt "Nhấn Enter để tiếp tục"
        read -r
    fi
}

# Export configuration to file
export_config_to_file() {
    render_input_prompt "Nhập đường dẫn file xuất (hoặc Enter để sử dụng mặc định)"
    
    local export_file
    read -r export_file
    
    if [[ -z "$export_file" ]]; then
        export_file="${CONFIG_USER_DIR}/exported_config_$(date +%Y%m%d_%H%M%S).conf"
    fi
    
    mkdir -p "$(dirname "$export_file")" 2>/dev/null
    
    {
        echo "# Linux Manager Configuration Export"
        echo "# Generated on $(date)"
        echo "# Environment: $DETECTED_ENVIRONMENT"
        echo
        
        local categories
        readarray -t categories < <(get_config_categories)
        
        for category in "${categories[@]}"; do
            echo "# ${category^^} Configuration"
            
            while IFS='=' read -r key value; do
                [[ -z "$key" ]] && continue
                echo "${key}=\"${value}\""
            done < <(get_config_by_category "$category")
            
            echo
        done
    } > "$export_file"
    
    render_status_message "Cấu hình đã được xuất ra: $export_file" "success"
}

# Show export script
show_export_script() {
    clear
    render_ascii_header "main" "EXPORT SCRIPT"
    
    render_menu_header "SCRIPT EXPORT CẤU HÌNH" "$(get_icon FILE)"
    
    echo -e "${WHITE}${BOLD}Sao chép script sau để export cấu hình:${NC}"
    echo
    
    create_separator "─" "$UI_WIDTH" "$DARK_GRAY"
    
    for key in "${!CONFIG_VALUES[@]}"; do
        echo "export LM_${key}=\"${CONFIG_VALUES[$key]}\""
    done
    
    create_separator "─" "$UI_WIDTH" "$DARK_GRAY"
    
    echo
    render_status_message "Script export đã được tạo" "success"
}

# Export configuration UI functions
export -f init_config_ui show_config_menu show_all_configurations
export -f show_category_configuration_menu show_category_configurations
export -f edit_configuration_interactive edit_single_configuration show_validation_help
export -f reset_configuration_interactive reset_single_configuration
export -f reset_category_configurations reset_all_configurations
export -f create_sample_configurations create_user_config_sample
export -f create_environment_config_sample export_configuration_menu
export -f export_config_to_file show_export_script
