#!/bin/bash

# Template System Initialization - V2 Architecture
# Sets up the complete template system with all components

# Template system directories
TEMPLATES_DIR="${ROOT_DIR}/src/templates"
TEMPLATES_UI_DIR="${TEMPLATES_DIR}/ui_components"
TEMPLATES_MENU_DIR="${TEMPLATES_DIR}/menus"
TEMPLATES_FORMS_DIR="${TEMPLATES_DIR}/forms"
TEMPLATES_THEMES_DIR="${TEMPLATES_DIR}/themes"

# Template system status
TEMPLATES_INITIALIZED=false

# Initialize template system
init_template_system() {
    local start_time
    start_time=$(get_timestamp_ms)
    
    log_info "TEMPLATE_SYSTEM" "Initializing template system..."
    
    # Verify template system directory structure
    if ! verify_template_directories; then
        log_error "TEMPLATE_SYSTEM" "Failed to verify template directories"
        return 1
    fi
    
    # Load core template components
    if ! load_template_components; then
        log_error "TEMPLATE_SYSTEM" "Failed to load template components"
        return 1
    fi
    
    # Initialize UI renderer
    if ! init_ui_renderer; then
        log_error "TEMPLATE_SYSTEM" "Failed to initialize UI renderer"
        return 1
    fi
    
    # Initialize menu templates
    if ! init_menu_templates; then
        log_error "TEMPLATE_SYSTEM" "Failed to initialize menu templates"
        return 1
    fi
    
    # Initialize form renderer
    if ! init_form_renderer; then
        log_error "TEMPLATE_SYSTEM" "Failed to initialize form renderer"
        return 1
    fi
    
    # Set initialization flag
    TEMPLATES_INITIALIZED=true
    
    local end_time duration
    end_time=$(get_timestamp_ms)
    duration=$((end_time - start_time))
    
    log_performance "TEMPLATE_SYSTEM" "Template system initialized" "$duration"
    log_info "TEMPLATE_SYSTEM" "Template system ready for use"
    
    return 0
}

# Verify template directory structure
verify_template_directories() {
    local directories=(
        "$TEMPLATES_DIR"
        "$TEMPLATES_UI_DIR"
        "$TEMPLATES_MENU_DIR" 
        "$TEMPLATES_FORMS_DIR"
        "$TEMPLATES_THEMES_DIR"
    )
    
    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            log_warning "TEMPLATE_SYSTEM" "Creating missing directory: $dir"
            if ! mkdir -p "$dir"; then
                log_error "TEMPLATE_SYSTEM" "Failed to create directory: $dir"
                return 1
            fi
        fi
    done
    
    log_debug "TEMPLATE_SYSTEM" "All template directories verified"
    return 0
}

# Load template components
load_template_components() {
    local components=(
        "ui_components/ui_renderer.sh"
        "menus/menu_templates.sh"
        "forms/form_renderer.sh"
    )
    
    for component in "${components[@]}"; do
        local component_path="${TEMPLATES_DIR}/${component}"
        
        if [[ -f "$component_path" ]]; then
            log_debug "TEMPLATE_SYSTEM" "Loading template component: $component"
            
            if ! source "$component_path"; then
                log_error "TEMPLATE_SYSTEM" "Failed to load component: $component"
                return 1
            fi
        else
            log_error "TEMPLATE_SYSTEM" "Component file not found: $component_path"
            return 1
        fi
    done
    
    log_debug "TEMPLATE_SYSTEM" "All template components loaded"
    return 0
}

# Get available themes
get_available_themes() {
    local themes=()
    
    if [[ -d "$TEMPLATES_THEMES_DIR" ]]; then
        while IFS= read -r -d '' theme_file; do
            local theme_name
            theme_name=$(basename "$theme_file" .theme)
            themes+=("$theme_name")
        done < <(find "$TEMPLATES_THEMES_DIR" -name "*.theme" -type f -print0)
    fi
    
    if [[ ${#themes[@]} -eq 0 ]]; then
        themes=("default")
    fi
    
    printf '%s\n' "${themes[@]}"
}

# Set UI theme
set_ui_theme() {
    local theme_name="$1"
    local theme_file="${TEMPLATES_THEMES_DIR}/${theme_name}.theme"
    
    if [[ -f "$theme_file" ]]; then
        UI_THEME="$theme_name"
        
        # Reload UI renderer with new theme
        if [[ "$TEMPLATES_INITIALIZED" == "true" ]]; then
            load_ui_theme "$theme_name"
            log_info "TEMPLATE_SYSTEM" "UI theme changed to: $theme_name"
        fi
        
        return 0
    else
        log_error "TEMPLATE_SYSTEM" "Theme not found: $theme_name"
        return 1
    fi
}

# Show template system status
show_template_status() {
    echo
    create_separator "─" "$UI_WIDTH" "$DARK_GRAY"
    create_centered_text "$(get_icon INFO) TEMPLATE SYSTEM STATUS" "$UI_WIDTH" "$LIGHT_CYAN$BOLD"
    create_separator "─" "$UI_WIDTH" "$DARK_GRAY"
    
    echo -e "  ${WHITE}${BOLD}Trạng thái hệ thống:${NC} ${LIGHT_GREEN}$(get_icon CHECK) Đã khởi tạo${NC}"
    echo -e "  ${WHITE}${BOLD}Theme hiện tại:${NC} ${LIGHT_CYAN}${UI_THEME}${NC}"
    echo -e "  ${WHITE}${BOLD}Chiều rộng UI:${NC} ${LIGHT_CYAN}${UI_WIDTH} ký tự${NC}"
    echo -e "  ${WHITE}${BOLD}Animation:${NC} ${LIGHT_CYAN}${UI_ANIMATION_ENABLED}${NC}"
    echo
    
    echo -e "  ${WHITE}${BOLD}Các theme có sẵn:${NC}"
    local themes
    readarray -t themes < <(get_available_themes)
    
    for theme in "${themes[@]}"; do
        local status=""
        if [[ "$theme" == "$UI_THEME" ]]; then
            status="${GREEN}$(get_icon CHECK) Đang sử dụng${NC}"
        else
            status="${GRAY}Có sẵn${NC}"
        fi
        echo -e "    ${LIGHT_CYAN}● ${theme}${NC} - ${status}"
    done
    
    echo
    create_separator "─" "$UI_WIDTH" "$DARK_GRAY"
}

# Demonstrate template system capabilities
demo_template_system() {
    if [[ "$TEMPLATES_INITIALIZED" != "true" ]]; then
        render_status_message "Template system chưa được khởi tạo" "error"
        return 1
    fi
    
    clear
    
    # Demo ASCII headers
    render_ascii_header "main" "DEMO TEMPLATE SYSTEM"
    
    # Demo status messages
    echo -e "${WHITE}${BOLD}Demo các loại thông báo:${NC}"
    render_status_message "Thông báo thành công" "success"
    render_status_message "Thông báo cảnh báo" "warning" 
    render_status_message "Thông báo lỗi" "error"
    render_status_message "Thông báo thông tin" "info"
    
    echo
    
    # Demo progress bar
    echo -e "${WHITE}${BOLD}Demo thanh tiến trình:${NC}"
    for i in {1..10}; do
        render_progress "$i" "10" "Đang xử lý"
        sleep 0.2
    done
    
    echo
    echo
    
    # Demo spinner
    echo -e "${WHITE}${BOLD}Demo spinner:${NC}"
    render_spinner "Đang tải dữ liệu" "2"
    
    echo
    
    # Demo confirmation
    render_confirmation "Bạn có muốn tiếp tục demo không?" "y"
    
    local choice
    read -r choice
    
    if [[ "$choice" =~ ^[yY]$ ]]; then
        # Demo menu template
        render_menu_by_name "main"
        
        render_input_prompt "Nhập lựa chọn để kết thúc demo" "1-6"
        read -r choice
        
        render_status_message "Demo hoàn thành!" "success"
    else
        render_status_message "Demo đã bị hủy" "warning"
    fi
}

# Cleanup template system
cleanup_template_system() {
    log_info "TEMPLATE_SYSTEM" "Cleaning up template system..."
    
    # Clear template caches
    unset TEMPLATE_CACHE
    
    # Reset initialization flag
    TEMPLATES_INITIALIZED=false
    
    # Reset theme to default
    UI_THEME="default"
    
    log_info "TEMPLATE_SYSTEM" "Template system cleanup completed"
}

# Check if template system is ready
is_template_system_ready() {
    [[ "$TEMPLATES_INITIALIZED" == "true" ]]
}

# Export template system variables
export TEMPLATES_DIR TEMPLATES_UI_DIR TEMPLATES_MENU_DIR 
export TEMPLATES_FORMS_DIR TEMPLATES_THEMES_DIR
export TEMPLATES_INITIALIZED

# Export key functions
export -f init_template_system verify_template_directories load_template_components
export -f get_available_themes set_ui_theme show_template_status
export -f demo_template_system cleanup_template_system is_template_system_ready
