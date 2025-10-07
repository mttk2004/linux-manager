#!/bin/bash

# Linux Manager V2 - Module Integration Helper
# Loads and integrates V2 modules with the main application
#
# @VERSION: 2.0.0
# @DESCRIPTION: Helper functions to load and manage V2 modules
# @AUTHOR: Linux Manager Team

# Load a V2 module
load_v2_module() {
    local module_name="$1"
    local module_dir="$ROOT_DIR/src/modules/v2/$module_name"
    local module_metadata="$module_dir/module.json"
    local module_manager="$module_dir/manager.sh"
    
    # Check if module exists
    if [[ ! -d "$module_dir" ]]; then
        log_error "V2 module directory not found: $module_dir"
        return 1
    fi
    
    if [[ ! -f "$module_metadata" ]]; then
        log_error "V2 module metadata not found: $module_metadata"
        return 1
    fi
    
    if [[ ! -f "$module_manager" ]]; then
        log_error "V2 module manager not found: $module_manager"
        return 1
    fi
    
    # Source the module manager
    if source "$module_manager" 2>/dev/null; then
        log_debug "Loaded V2 module: $module_name"
        
        # Initialize module if init function exists
        local init_function="init_${module_name}_module"
        if declare -f "$init_function" >/dev/null 2>&1; then
            if "$init_function"; then
                log_info "Initialized V2 module: $module_name"
                return 0
            else
                log_error "Failed to initialize V2 module: $module_name"
                return 1
            fi
        else
            log_debug "No init function found for V2 module: $module_name"
            return 0
        fi
    else
        log_error "Failed to load V2 module: $module_name"
        return 1
    fi
}

# Check if a V2 module is available
is_v2_module_available() {
    local module_name="$1"
    local module_dir="$ROOT_DIR/src/modules/v2/$module_name"
    
    [[ -d "$module_dir" && -f "$module_dir/module.json" && -f "$module_dir/manager.sh" ]]
}

# Load all available V2 modules
load_all_v2_modules() {
    log_info "Loading all available V2 modules"
    
    local modules_v2_dir="$ROOT_DIR/src/modules/v2"
    local loaded_count=0
    local failed_count=0
    
    if [[ ! -d "$modules_v2_dir" ]]; then
        log_warning "V2 modules directory not found: $modules_v2_dir"
        return 1
    fi
    
    # Find all V2 modules
    for module_dir in "$modules_v2_dir"/*; do
        if [[ -d "$module_dir" ]]; then
            local module_name=$(basename "$module_dir")
            
            if load_v2_module "$module_name"; then
                ((loaded_count++))
                log_info "Successfully loaded V2 module: $module_name"
            else
                ((failed_count++))
                log_warning "Failed to load V2 module: $module_name"
            fi
        fi
    done
    
    log_info "V2 module loading complete: $loaded_count loaded, $failed_count failed"
    
    if [[ $loaded_count -gt 0 ]]; then
        return 0
    else
        return 1
    fi
}

# Enhanced package management with V2
handle_packages_v2() {
    if is_v2_module_available "packages"; then
        if load_v2_module "packages"; then
            # Use V2 packages module
            if declare -f "manage_packages_v2" >/dev/null 2>&1; then
                manage_packages_v2
                return 0
            elif declare -f "manage_packages_environment" >/dev/null 2>&1; then
                manage_packages_environment
                return 0
            fi
        fi
    fi
    
    # Fallback to V1 if V2 not available
    handle_packages_v1_fallback
}

# Enhanced development environments with V2
handle_development_v2() {
    if is_v2_module_available "development"; then
        if load_v2_module "development"; then
            # Use V2 development module
            if declare -f "manage_development_v2" >/dev/null 2>&1; then
                manage_development_v2
                return 0
            elif declare -f "manage_development_environment" >/dev/null 2>&1; then
                manage_development_environment
                return 0
            fi
        fi
    fi
    
    # Fallback to V1 if V2 not available
    handle_development_v1_fallback
}

# Enhanced system configuration with V2
handle_system_config_v2() {
    if is_v2_module_available "system"; then
        if load_v2_module "system"; then
            # Use V2 system module
            if declare -f "manage_system_v2" >/dev/null 2>&1; then
                manage_system_v2
                return 0
            elif declare -f "manage_system_configurations" >/dev/null 2>&1; then
                manage_system_configurations
                return 0
            fi
        fi
    fi
    
    # Fallback to V1 if V2 not available
    handle_system_config_v1_fallback
}

# V1 Fallback functions
handle_packages_v1_fallback() {
    clear  
    print_app_header
    
    printf "${WHITE}${BOLD}═══ QUẢN LÝ GÓI (V1 FALLBACK) ═══${NC}\\n\\n"
    printf "${YELLOW}Sử dụng chế độ tương thích V1...${NC}\\n\\n"
    
    # Try to load V1 packages module
    local v1_packages_manager="$ROOT_DIR/src/modules/packages/manager.sh"
    if [[ -f "$v1_packages_manager" ]]; then
        # Load V1 core modules first
        local v1_core_dir="$ROOT_DIR/src/core"
        if [[ -f "$v1_core_dir/config.sh" ]]; then
            source "$v1_core_dir/config.sh" 2>/dev/null
        fi
        if [[ -f "$v1_core_dir/ui.sh" ]]; then
            source "$v1_core_dir/ui.sh" 2>/dev/null
        fi
        if [[ -f "$v1_core_dir/utils.sh" ]]; then
            source "$v1_core_dir/utils.sh" 2>/dev/null
        fi
        
        # Load V1 packages module
        if source "$v1_packages_manager" 2>/dev/null; then
            if declare -f "manage_packages" >/dev/null 2>&1; then
                manage_packages
                return 0
            fi
        fi
    fi
    
    # Ultimate fallback
    printf "${CYAN}1.${NC} Cài đặt gói cơ bản\\n"
    printf "${CYAN}2.${NC} Cài đặt gói phát triển\\n" 
    printf "${CYAN}3.${NC} Cài đặt gói multimedia\\n"
    printf "${CYAN}0.${NC} Quay lại\\n"
    
    echo
    printf "${BOLD}Lựa chọn của bạn: ${NC}"
    
    local choice
    choice=$(read_user_choice)
    
    case "$choice" in
        "1"|"2"|"3")
            printf "${YELLOW}Chức năng V1 fallback - cần cài đặt V2 modules...${NC}\\n"
            printf "${YELLOW}Nhấn phím bất kỳ để tiếp tục...${NC}"
            read -r
            ;;
        "0")
            return 0
            ;;
    esac
}

handle_development_v1_fallback() {
    clear
    print_app_header
    
    printf "${WHITE}${BOLD}═══ MÔI TRƯỜNG PHÁT TRIỂN (V1 FALLBACK) ═══${NC}\\n\\n"
    printf "${YELLOW}Sử dụng chế độ tương thích V1...${NC}\\n\\n"
    
    # Try to load V1 development modules
    local v1_php_manager="$ROOT_DIR/src/modules/dev/php/manager.sh"
    local v1_nodejs_manager="$ROOT_DIR/src/modules/dev/nodejs/manager.sh"
    
    if [[ -f "$v1_php_manager" ]] || [[ -f "$v1_nodejs_manager" ]]; then
        # Load V1 core modules first
        local v1_core_dir="$ROOT_DIR/src/core"
        if [[ -f "$v1_core_dir/config.sh" ]]; then
            source "$v1_core_dir/config.sh" 2>/dev/null
        fi
        if [[ -f "$v1_core_dir/ui.sh" ]]; then
            source "$v1_core_dir/ui.sh" 2>/dev/null
        fi
        if [[ -f "$v1_core_dir/utils.sh" ]]; then
            source "$v1_core_dir/utils.sh" 2>/dev/null
        fi
        
        printf "${CYAN}1.${NC} Môi trường PHP (PHP + Composer + Laravel)\\n"
        printf "${CYAN}2.${NC} Môi trường Node.js (Node + NPM + NVM)\\n"
        printf "${CYAN}3.${NC} Môi trường Python (sắp có)\\n"
        printf "${CYAN}0.${NC} Quay lại\\n"
        
        echo
        printf "${BOLD}Lựa chọn của bạn: ${NC}"
        
        local choice
        choice=$(read_user_choice)
        
        case "$choice" in
            "1")
                if [[ -f "$v1_php_manager" ]]; then
                    if source "$v1_php_manager" 2>/dev/null; then
                        if declare -f "manage_php_environment" >/dev/null 2>&1; then
                            manage_php_environment
                            return 0
                        fi
                    fi
                fi
                printf "${YELLOW}PHP module không khả dụng...${NC}\\n"
                ;;
            "2")
                if [[ -f "$v1_nodejs_manager" ]]; then
                    if source "$v1_nodejs_manager" 2>/dev/null; then
                        if declare -f "manage_nodejs_environment" >/dev/null 2>&1; then
                            manage_nodejs_environment
                            return 0
                        fi
                    fi
                fi
                printf "${YELLOW}Node.js module không khả dụng...${NC}\\n"
                ;;
            "3")
                printf "${YELLOW}Python environment sắp được hỗ trợ trong V2...${NC}\\n"
                ;;
            "0")
                return 0
                ;;
        esac
    else
        printf "${CYAN}1.${NC} Cài đặt PHP + Composer\\n"
        printf "${CYAN}2.${NC} Cài đặt Node.js + NPM\\n"
        printf "${CYAN}3.${NC} Cài đặt Python + Pip\\n"
        printf "${CYAN}0.${NC} Quay lại\\n"
        
        echo
        printf "${BOLD}Lựa chọn của bạn: ${NC}"
        
        local choice
        choice=$(read_user_choice)
        
        case "$choice" in
            "1"|"2"|"3")
                printf "${YELLOW}Chức năng V1 fallback - cần cài đặt V2 modules...${NC}\\n"
                ;;
            "0")
                return 0
                ;;
        esac
    fi
    
    printf "${YELLOW}Nhấn phím bất kỳ để tiếp tục...${NC}"
    read -r
}

handle_system_config_v1_fallback() {
    clear
    print_app_header
    
    printf "${WHITE}${BOLD}═══ CẤU HÌNH HỆ THỐNG (V1 FALLBACK) ═══${NC}\\n\\n"
    printf "${YELLOW}Sử dụng chế độ tương thích V1...${NC}\\n\\n"
    
    # Try to load V1 system module
    local v1_system_manager="$ROOT_DIR/src/modules/system/manager.sh"
    if [[ -f "$v1_system_manager" ]]; then
        # Load V1 core modules first
        local v1_core_dir="$ROOT_DIR/src/core"
        if [[ -f "$v1_core_dir/config.sh" ]]; then
            source "$v1_core_dir/config.sh" 2>/dev/null
        fi
        if [[ -f "$v1_core_dir/ui.sh" ]]; then
            source "$v1_core_dir/ui.sh" 2>/dev/null
        fi
        if [[ -f "$v1_core_dir/utils.sh" ]]; then
            source "$v1_core_dir/utils.sh" 2>/dev/null
        fi
        
        # Load V1 system module
        if source "$v1_system_manager" 2>/dev/null; then
            if declare -f "manage_system_configurations" >/dev/null 2>&1; then
                manage_system_configurations
                return 0
            fi
        fi
    fi
    
    # Ultimate fallback
    printf "${CYAN}1.${NC} Cấu hình Bash\\n"
    printf "${CYAN}2.${NC} Cấu hình Fish Shell\\n"
    printf "${CYAN}3.${NC} Cấu hình Vim\\n"
    printf "${CYAN}4.${NC} Dọn dẹp hệ thống\\n"
    printf "${CYAN}0.${NC} Quay lại\\n"
    
    echo
    printf "${BOLD}Lựa chọn của bạn: ${NC}"
    
    local choice
    choice=$(read_user_choice)
    
    case "$choice" in
        "1"|"2"|"3"|"4")
            printf "${YELLOW}Chức năng V1 fallback - cần cài đặt V2 modules...${NC}\\n"
            printf "${YELLOW}Nhấn phím bất kỳ để tiếp tục...${NC}"
            read -r
            ;;
        "0")
            return 0
            ;;
    esac
}
