#!/bin/bash

# Form Template Renderer - V2 Architecture
# Provides reusable form components for user input collection

# Form field types
declare -A FIELD_TYPES=(
    [text]="text"
    [password]="password"
    [choice]="choice"
    [multi_choice]="multi_choice"
    [confirm]="confirm"
    [file_path]="file_path"
    [number]="number"
    [email]="email"
    [url]="url"
)

# Form validation patterns
declare -A VALIDATION_PATTERNS=(
    [email]="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    [url]="^https?://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$"
    [number]="^[0-9]+$"
    [path]="^(/[^/\0]+)+/?$"
    [filename]="^[a-zA-Z0-9._-]+$"
)

# Initialize form renderer
init_form_renderer() {
    log_debug "FORM_RENDERER" "Form renderer initialized"
}

# Render form header
render_form_header() {
    local title="$1"
    local description="${2:-}"
    local icon="${3:-$(get_icon CONFIG)}"
    
    echo
    create_separator "=" "$UI_WIDTH" "$LIGHT_CYAN"
    create_centered_text "$icon $BOLD$title$NC $icon" "$UI_WIDTH" "$WHITE"
    
    if [[ -n "$description" ]]; then
        echo
        create_centered_text "$description" "$UI_WIDTH" "$GRAY"
    fi
    
    create_separator "=" "$UI_WIDTH" "$LIGHT_CYAN"
    echo
}

# Render text input field
render_text_field() {
    local field_name="$1"
    local label="$2"
    local placeholder="${3:-}"
    local required="${4:-false}"
    local validation="${5:-}"
    
    local required_marker=""
    if [[ "$required" == "true" ]]; then
        required_marker="${RED}*${NC}"
    fi
    
    echo -e "${WHITE}${BOLD}${label}${required_marker}${NC}"
    if [[ -n "$placeholder" ]]; then
        echo -e "${GRAY}${DIM}  Ví dụ: ${placeholder}${NC}"
    fi
    
    render_input_prompt "Nhập ${label,,}" "" "$LIGHT_CYAN"
}

# Render password field
render_password_field() {
    local field_name="$1"
    local label="$2"
    local required="${3:-true}"
    
    local required_marker=""
    if [[ "$required" == "true" ]]; then
        required_marker="${RED}*${NC}"
    fi
    
    echo -e "${WHITE}${BOLD}${label}${required_marker}${NC}"
    echo -e "${GRAY}${DIM}  Mật khẩu sẽ được ẩn khi nhập${NC}"
    
    render_input_prompt "Nhập ${label,,}" "" "$LIGHT_CYAN"
}

# Render choice field (single selection)
render_choice_field() {
    local field_name="$1"
    local label="$2"
    local choices_array_name="$3"
    local default_choice="${4:-1}"
    
    declare -n choices_ref="$choices_array_name"
    
    echo -e "${WHITE}${BOLD}${label}${NC}"
    echo
    
    local index=1
    for choice in "${choices_ref[@]}"; do
        local marker=" "
        if [[ $index -eq $default_choice ]]; then
            marker="${GREEN}●${NC}"
        else
            marker="${GRAY}○${NC}"
        fi
        echo -e "  $marker ${GREEN}${BOLD}[$index]${NC} ${WHITE}$choice${NC}"
        ((index++))
    done
    
    echo
    render_input_prompt "Chọn tùy chọn" "1-$((${#choices_ref[@]}))" "$LIGHT_CYAN"
}

# Render multi-choice field (multiple selections)
render_multi_choice_field() {
    local field_name="$1"
    local label="$2"
    local choices_array_name="$3"
    local selected_array_name="${4:-}"
    
    declare -n choices_ref="$choices_array_name"
    declare -n selected_ref="$selected_array_name"
    
    echo -e "${WHITE}${BOLD}${label}${NC}"
    echo -e "${GRAY}${DIM}  Sử dụng dấu phẩy để chọn nhiều tùy chọn (ví dụ: 1,3,5)${NC}"
    echo
    
    local index=1
    for choice in "${choices_ref[@]}"; do
        local marker="${GRAY}☐${NC}"
        
        # Check if this choice is selected
        if [[ -n "$selected_array_name" ]]; then
            for selected_index in "${selected_ref[@]}"; do
                if [[ $index -eq $selected_index ]]; then
                    marker="${GREEN}☑${NC}"
                    break
                fi
            done
        fi
        
        echo -e "  $marker ${GREEN}${BOLD}[$index]${NC} ${WHITE}$choice${NC}"
        ((index++))
    done
    
    echo
    render_input_prompt "Chọn các tùy chọn" "1-$((${#choices_ref[@]}))" "$LIGHT_CYAN"
}

# Render confirmation field
render_confirmation_field() {
    local field_name="$1"
    local label="$2"
    local default="${3:-y}"
    
    render_confirmation "$label" "$default"
}

# Render file path field
render_file_path_field() {
    local field_name="$1"
    local label="$2"
    local file_type="${3:-file}" # file, directory, any
    local must_exist="${4:-false}"
    
    echo -e "${WHITE}${BOLD}${label}${NC}"
    
    local hint=""
    case "$file_type" in
        "file")
            hint="Nhập đường dẫn đến file"
            ;;
        "directory")
            hint="Nhập đường dẫn đến thư mục"
            ;;
        *)
            hint="Nhập đường dẫn"
            ;;
    esac
    
    if [[ "$must_exist" == "true" ]]; then
        hint="${hint} (phải tồn tại)"
    fi
    
    echo -e "${GRAY}${DIM}  ${hint}${NC}"
    render_input_prompt "Đường dẫn" "" "$LIGHT_CYAN"
}

# Render number field
render_number_field() {
    local field_name="$1"
    local label="$2"
    local min_value="${3:-}"
    local max_value="${4:-}"
    local default_value="${5:-}"
    
    echo -e "${WHITE}${BOLD}${label}${NC}"
    
    local range_info=""
    if [[ -n "$min_value" && -n "$max_value" ]]; then
        range_info="từ $min_value đến $max_value"
    elif [[ -n "$min_value" ]]; then
        range_info="từ $min_value trở lên"
    elif [[ -n "$max_value" ]]; then
        range_info="từ 0 đến $max_value"
    fi
    
    if [[ -n "$range_info" ]]; then
        echo -e "${GRAY}${DIM}  Nhập số ${range_info}${NC}"
    fi
    
    if [[ -n "$default_value" ]]; then
        echo -e "${GRAY}${DIM}  Mặc định: ${default_value}${NC}"
    fi
    
    render_input_prompt "Nhập số" "$range_info" "$LIGHT_CYAN"
}

# Validate field input
validate_field_input() {
    local field_type="$1"
    local input_value="$2"
    local validation_rule="${3:-}"
    
    # Check if input is empty for required fields
    if [[ -z "$input_value" ]]; then
        return 1
    fi
    
    case "$field_type" in
        "email")
            if [[ ! "$input_value" =~ ${VALIDATION_PATTERNS[email]} ]]; then
                render_status_message "Email không hợp lệ" "error"
                return 1
            fi
            ;;
        "url")
            if [[ ! "$input_value" =~ ${VALIDATION_PATTERNS[url]} ]]; then
                render_status_message "URL không hợp lệ" "error"
                return 1
            fi
            ;;
        "number")
            if [[ ! "$input_value" =~ ${VALIDATION_PATTERNS[number]} ]]; then
                render_status_message "Phải nhập số" "error"
                return 1
            fi
            ;;
        "file_path")
            if [[ "$validation_rule" == "must_exist" && ! -e "$input_value" ]]; then
                render_status_message "Đường dẫn không tồn tại" "error"
                return 1
            fi
            ;;
    esac
    
    return 0
}

# Get user input with validation
get_validated_input() {
    local field_type="$1"
    local field_name="$2"
    local validation_rule="${3:-}"
    local max_attempts="${4:-3}"
    
    local attempt=0
    local input_value
    
    while [[ $attempt -lt $max_attempts ]]; do
        if [[ "$field_type" == "password" ]]; then
            read -s -r input_value
            echo  # New line after hidden input
        else
            read -r input_value
        fi
        
        if validate_field_input "$field_type" "$input_value" "$validation_rule"; then
            echo "$input_value"
            return 0
        fi
        
        ((attempt++))
        if [[ $attempt -lt $max_attempts ]]; then
            render_status_message "Vui lòng thử lại (${attempt}/${max_attempts})" "warning"
            render_input_prompt "Nhập lại" "" "$LIGHT_CYAN"
        fi
    done
    
    render_status_message "Đã vượt quá số lần thử" "error"
    return 1
}

# Render complete form from configuration
render_form() {
    local form_config_name="$1"
    declare -n form_ref="$form_config_name"
    declare -A form_data=()
    
    # Render form header
    render_form_header "${form_ref[title]}" "${form_ref[description]:-}" "${form_ref[icon]:-}"
    
    # Process each field
    local field_index=1
    while [[ -n "${form_ref[field_${field_index}_name]:-}" ]]; do
        local field_name="${form_ref[field_${field_index}_name]}"
        local field_type="${form_ref[field_${field_index}_type]}"
        local field_label="${form_ref[field_${field_index}_label]}"
        local field_required="${form_ref[field_${field_index}_required]:-false}"
        local field_validation="${form_ref[field_${field_index}_validation]:-}"
        
        echo
        create_separator "─" "$UI_WIDTH" "$DARK_GRAY"
        
        case "$field_type" in
            "text")
                render_text_field "$field_name" "$field_label" \
                    "${form_ref[field_${field_index}_placeholder]:-}" \
                    "$field_required" "$field_validation"
                
                local input_value
                input_value=$(get_validated_input "$field_type" "$field_name" "$field_validation")
                if [[ $? -eq 0 ]]; then
                    form_data["$field_name"]="$input_value"
                else
                    render_status_message "Không thể hoàn thành form" "error"
                    return 1
                fi
                ;;
                
            "password")
                render_password_field "$field_name" "$field_label" "$field_required"
                
                local input_value
                input_value=$(get_validated_input "$field_type" "$field_name")
                if [[ $? -eq 0 ]]; then
                    form_data["$field_name"]="$input_value"
                else
                    render_status_message "Không thể hoàn thành form" "error"
                    return 1
                fi
                ;;
                
            "choice")
                local choices_var="${form_ref[field_${field_index}_choices]}"
                local default_choice="${form_ref[field_${field_index}_default]:-1}"
                
                render_choice_field "$field_name" "$field_label" "$choices_var" "$default_choice"
                
                local choice
                read -r choice
                if validate_menu_choice "form_choice" "$choice"; then
                    form_data["$field_name"]="$choice"
                else
                    render_status_message "Lựa chọn không hợp lệ" "error"
                    return 1
                fi
                ;;
                
            "confirm")
                local default_confirm="${form_ref[field_${field_index}_default]:-y}"
                render_confirmation_field "$field_name" "$field_label" "$default_confirm"
                
                local confirm_choice
                read -r confirm_choice
                form_data["$field_name"]="$confirm_choice"
                ;;
        esac
        
        ((field_index++))
    done
    
    # Show form summary
    echo
    create_separator "=" "$UI_WIDTH" "$LIGHT_GREEN"
    create_centered_text "$(get_icon CHECK) TÓM TẮT THÔNG TIN NHẬP" "$UI_WIDTH" "$LIGHT_GREEN$BOLD"
    create_separator "=" "$UI_WIDTH" "$LIGHT_GREEN"
    
    field_index=1
    while [[ -n "${form_ref[field_${field_index}_name]:-}" ]]; do
        local field_name="${form_ref[field_${field_index}_name]}"
        local field_label="${form_ref[field_${field_index}_label]}"
        local field_type="${form_ref[field_${field_index}_type]}"
        
        local display_value="${form_data[$field_name]:-}"
        if [[ "$field_type" == "password" ]]; then
            display_value="********"
        fi
        
        echo -e "  ${WHITE}${BOLD}${field_label}:${NC} ${LIGHT_CYAN}${display_value}${NC}"
        ((field_index++))
    done
    
    echo
    render_confirmation "Xác nhận thông tin trên đúng không?" "y"
    
    local final_confirm
    read -r final_confirm
    
    if [[ "$final_confirm" =~ ^[yY]$ ]]; then
        # Export form data to global associative array
        for key in "${!form_data[@]}"; do
            declare -g "FORM_${key^^}=${form_data[$key]}"
        done
        
        render_status_message "Form đã được xác nhận thành công" "success"
        return 0
    else
        render_status_message "Form đã bị hủy" "warning"
        return 2
    fi
}

# Create sample form configuration for PHP installation
create_php_install_form() {
    declare -gA PHP_INSTALL_FORM=(
        [title]="CÀI ĐẶT MÔI TRƯỜNG PHP"
        [description]="Cấu hình thông số cài đặt PHP từ source code"
        [icon]="🐘"
        
        [field_1_name]="php_version"
        [field_1_type]="text"
        [field_1_label]="Phiên bản PHP"
        [field_1_placeholder]="8.3.0"
        [field_1_required]="true"
        
        [field_2_name]="install_path"
        [field_2_type]="file_path"
        [field_2_label]="Thư mục cài đặt"
        [field_2_validation]="directory"
        [field_2_required]="true"
        
        [field_3_name]="extensions"
        [field_3_type]="multi_choice"
        [field_3_label]="PHP Extensions"
        [field_3_choices]="PHP_EXTENSIONS_LIST"
        
        [field_4_name]="configure_apache"
        [field_4_type]="confirm"
        [field_4_label]="Cấu hình Apache"
        [field_4_default]="y"
        
        [field_5_name]="install_composer"
        [field_5_type]="confirm"
        [field_5_label]="Cài đặt Composer"
        [field_5_default]="y"
    )
    
    declare -ga PHP_EXTENSIONS_LIST=(
        "curl - HTTP client library"
        "mysqli - MySQL database support"
        "pdo - Database abstraction layer"
        "gd - Image processing"
        "mbstring - Multibyte string support"
        "xml - XML parsing support"
        "zip - ZIP archive support"
        "json - JSON support"
        "openssl - SSL/TLS support"
    )
    
    export PHP_INSTALL_FORM PHP_EXTENSIONS_LIST
}

# Export key functions
export -f init_form_renderer render_form_header render_text_field render_password_field
export -f render_choice_field render_multi_choice_field render_confirmation_field
export -f render_file_path_field render_number_field validate_field_input
export -f get_validated_input render_form create_php_install_form
