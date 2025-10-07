#!/bin/bash

# UI System - V2 Architecture
# Enhanced user interface with better menus, progress indicators, and user experience
#
# @VERSION: 2.0.0
# @DESCRIPTION: Advanced UI system for Linux Manager V2
# @AUTHOR: Linux Manager Team
# @LICENSE: MIT

# Define stub logging functions for testing environment
if [[ "${TESTING:-false}" == "true" ]]; then
    log_debug() { [[ "${TEST_VERBOSE:-false}" == "true" ]] && echo "[DEBUG] $*" >&2 || true; }
    log_info() { echo "[INFO] $*" >&2; }
    log_warning() { echo "[WARNING] $*" >&2; }
    log_error() { echo "[ERROR] $*" >&2; }
fi

# UI System Configuration
declare -g UI_SYSTEM_INITIALIZED=false
declare -g UI_TERMINAL_WIDTH=80
declare -g UI_TERMINAL_HEIGHT=24
declare -g UI_ANIMATION_ENABLED=true
declare -g UI_SOUND_ENABLED=false
declare -g UI_LANGUAGE="vi"

# Color scheme configuration
declare -gA UI_COLORS=(
    ["primary"]='\033[0;36m'      # Cyan
    ["secondary"]='\033[0;34m'    # Blue  
    ["success"]='\033[0;32m'      # Green
    ["warning"]='\033[1;33m'      # Yellow
    ["error"]='\033[0;31m'        # Red
    ["info"]='\033[0;37m'         # Light Gray
    ["accent"]='\033[1;35m'       # Magenta
    ["bold"]='\033[1m'            # Bold
    ["dim"]='\033[2m'             # Dim
    ["reset"]='\033[0m'           # Reset
)

# UI Icons and symbols
declare -gA UI_ICONS=(
    ["success"]="✅"
    ["error"]="❌"
    ["warning"]="⚠️"
    ["info"]="ℹ️"
    ["loading"]="🔄"
    ["arrow"]="➤"
    ["bullet"]="•"
    ["check"]="✓"
    ["cross"]="✗"
    ["star"]="⭐"
    ["gear"]="⚙️"
    ["package"]="📦"
    ["tools"]="🛠️"
    ["stats"]="📊"
    ["exit"]="🚪"
    ["linux"]="🐧"
)

# Menu state management
declare -gA UI_MENU_STATE=(
    ["current_menu"]="main"
    ["selected_item"]=0
    ["total_items"]=0
    ["menu_title"]=""
    ["menu_description"]=""
)

# Progress bar configuration
declare -g UI_PROGRESS_WIDTH=50
declare -g UI_PROGRESS_CHAR="█"
declare -g UI_PROGRESS_EMPTY="░"

# Initialize the UI system
init_ui_system() {
    log_info "UI_SYSTEM" "Initializing enhanced UI system"
    
    # Detect terminal capabilities
    detect_terminal_capabilities
    
    # Load UI configuration
    load_ui_configuration
    
    # Initialize color support
    init_color_support
    
    # Set up signal handlers for UI
    setup_ui_signal_handlers
    
    UI_SYSTEM_INITIALIZED=true
    log_info "UI_SYSTEM" "Enhanced UI system initialized"
    
    return 0
}

# Detect terminal capabilities
detect_terminal_capabilities() {
    # Get terminal size
    if command -v tput >/dev/null 2>&1; then
        UI_TERMINAL_WIDTH=$(tput cols 2>/dev/null || echo 80)
        UI_TERMINAL_HEIGHT=$(tput lines 2>/dev/null || echo 24)
    else
        UI_TERMINAL_WIDTH=${COLUMNS:-80}
        UI_TERMINAL_HEIGHT=${LINES:-24}
    fi
    
    # Check for color support
    if [[ ! -t 1 ]] || [[ "${TERM:-}" == "dumb" ]]; then
        # Disable colors for non-interactive or dumb terminals
        for key in "${!UI_COLORS[@]}"; do
            UI_COLORS["$key"]=""
        done
    fi
    
    # Check for Unicode support
    if [[ "${LANG:-}" =~ UTF-8 ]] || [[ "${LC_ALL:-}" =~ UTF-8 ]]; then
        log_debug "UI_SYSTEM" "Unicode support detected"
    else
        # Fallback to ASCII icons
        UI_ICONS["success"]="[OK]"
        UI_ICONS["error"]="[ERR]"
        UI_ICONS["warning"]="[WARN]"
        UI_ICONS["info"]="[INFO]"
        UI_ICONS["loading"]="[...]"
        UI_ICONS["arrow"]=">"
        UI_ICONS["bullet"]="*"
        UI_ICONS["check"]="+"
        UI_ICONS["cross"]="x"
    fi
    
    log_debug "UI_SYSTEM" "Terminal: ${UI_TERMINAL_WIDTH}x${UI_TERMINAL_HEIGHT}"
}

# Load UI configuration from config system
load_ui_configuration() {
    # Try to load from configuration system if available
    if declare -f "get_config" >/dev/null 2>&1; then
        UI_ANIMATION_ENABLED=$(get_config "UI_ANIMATION_ENABLED" "true" 2>/dev/null || echo "true")
        UI_LANGUAGE=$(get_config "UI_LANGUAGE" "vi" 2>/dev/null || echo "vi")
        UI_SOUND_ENABLED=$(get_config "UI_SOUND_ENABLED" "false" 2>/dev/null || echo "false")
        
        # Get theme preference
        local ui_theme
        ui_theme=$(get_config "UI_THEME" "default" 2>/dev/null || echo "default")
        apply_ui_theme "$ui_theme"
    fi
    
    log_debug "UI_SYSTEM" "UI configuration loaded"
}

# Apply UI theme
apply_ui_theme() {
    local theme="$1"
    
    case "$theme" in
        "dark")
            UI_COLORS["primary"]='\033[1;36m'
            UI_COLORS["secondary"]='\033[1;34m'
            UI_COLORS["accent"]='\033[1;35m'
            ;;
        "minimal")
            # Minimal color scheme
            for key in "${!UI_COLORS[@]}"; do
                if [[ "$key" != "reset" && "$key" != "bold" ]]; then
                    UI_COLORS["$key"]='\033[0m'
                fi
            done
            ;;
        *)
            # Default theme - already set
            ;;
    esac
    
    log_debug "UI_SYSTEM" "Applied theme: $theme"
}

# Initialize color support
init_color_support() {
    # Test color output capability
    if [[ -t 1 ]]; then
        # Terminal supports colors
        log_debug "UI_SYSTEM" "Color support enabled"
    else
        # Disable all colors
        for key in "${!UI_COLORS[@]}"; do
            UI_COLORS["$key"]=""
        done
        log_debug "UI_SYSTEM" "Color support disabled (non-terminal)"
    fi
}

# Set up signal handlers for UI
setup_ui_signal_handlers() {
    # Handle window resize
    trap 'detect_terminal_capabilities' WINCH
    
    # Handle cleanup on exit
    trap 'cleanup_ui' EXIT
}

# Clear screen with optional animation
ui_clear_screen() {
    local with_animation="${1:-false}"
    
    if [[ "$with_animation" == "true" && "$UI_ANIMATION_ENABLED" == "true" ]]; then
        # Animated clear
        local i
        for ((i=0; i<UI_TERMINAL_HEIGHT; i++)); do
            echo
            sleep 0.01
        done
    else
        clear
    fi
}

# Print a centered title
ui_print_title() {
    local title="$1"
    local subtitle="${2:-}"
    local width="${3:-$UI_TERMINAL_WIDTH}"
    
    echo
    ui_center_text "$title" "$width" "${UI_COLORS[primary]}${UI_COLORS[bold]}" "${UI_COLORS[reset]}"
    
    if [[ -n "$subtitle" ]]; then
        ui_center_text "$subtitle" "$width" "${UI_COLORS[dim]}" "${UI_COLORS[reset]}"
    fi
    echo
}

# Center text in terminal
ui_center_text() {
    local text="$1"
    local width="${2:-$UI_TERMINAL_WIDTH}"
    local prefix="${3:-}"
    local suffix="${4:-}"
    
    # Calculate padding
    local text_length=${#text}
    local padding=$(( (width - text_length) / 2 ))
    
    # Print centered text
    printf "%*s%s%s%s\n" "$padding" "" "$prefix" "$text" "$suffix"
}

# Print a horizontal line
ui_print_line() {
    local char="${1:-─}"
    local width="${2:-$UI_TERMINAL_WIDTH}"
    local color="${3:-${UI_COLORS[dim]}}"
    
    printf "%s" "$color"
    printf "%*s\n" "$width" | sed "s/ /$char/g"
    printf "%s" "${UI_COLORS[reset]}"
}

# Print a box around text
ui_print_box() {
    local text="$1"
    local width="${2:-$UI_TERMINAL_WIDTH}"
    local color="${3:-${UI_COLORS[primary]}}"
    
    local content_width=$((width - 4))
    
    # Top border
    printf "%s╔%*s╗%s\n" "$color" "$((width-2))" | sed 's/ /═/g' "${UI_COLORS[reset]}"
    
    # Content with side borders
    while IFS= read -r line; do
        printf "%s║ %-*s ║%s\n" "$color" "$content_width" "$line" "${UI_COLORS[reset]}"
    done <<< "$text"
    
    # Bottom border
    printf "%s╚%*s╝%s\n" "$color" "$((width-2))" | sed 's/ /═/g' "${UI_COLORS[reset]}"
}

# Enhanced menu display
ui_show_menu() {
    local menu_title="$1"
    local menu_description="$2"
    shift 2
    local menu_items=("$@")
    
    UI_MENU_STATE["menu_title"]="$menu_title"
    UI_MENU_STATE["menu_description"]="$menu_description"
    UI_MENU_STATE["total_items"]=${#menu_items[@]}
    
    ui_clear_screen
    
    # Print application header
    print_app_header_enhanced
    
    # Print menu title
    ui_print_title "$menu_title" "$menu_description"
    
    # Print menu items
    local i=0
    for item in "${menu_items[@]}"; do
        local icon_key=""
        local display_text="$item"
        
        # Extract icon and text if formatted as "icon:text"
        if [[ "$item" =~ ^([^:]+):(.+)$ ]]; then
            icon_key="${BASH_REMATCH[1]}"
            display_text="${BASH_REMATCH[2]}"
        fi
        
        # Get icon
        local icon="${UI_ICONS[$icon_key]:-${UI_ICONS[bullet]}}"
        
        # Format menu item
        printf "  %s%s%s %s%s%s\n" \
            "${UI_COLORS[accent]}" "$((i+1))." "${UI_COLORS[reset]}" \
            "$icon" " " "$display_text"
        
        ((i++))
    done
    
    echo
    ui_print_line
    printf "\n%s%sLựa chọn của bạn:%s " "${UI_COLORS[bold]}" "${UI_COLORS[primary]}" "${UI_COLORS[reset]}"
}

# Enhanced application header
print_app_header_enhanced() {
    local header_width=$((UI_TERMINAL_WIDTH - 4))
    
    printf "%s" "${UI_COLORS[primary]}"
    
    # Top border
    printf "╔%*s╗\n" "$((header_width))" | sed 's/ /═/g'
    
    # Title line
    local title="🐧 Linux Manager V2"
    ui_center_text "║ $title ║" "$((header_width + 2))"
    
    # Empty line
    printf "║%*s║\n" "$header_width" ""
    
    # Subtitle
    local subtitle="Công cụ quản lý hệ thống Arch Linux"
    ui_center_text "║ $subtitle ║" "$((header_width + 2))"
    
    # Version line
    local version_line="Modern • Modular • Powerful"
    ui_center_text "║ $version_line ║" "$((header_width + 2))"
    
    # Empty line
    printf "║%*s║\n" "$header_width" ""
    
    # Version
    local version_text="Version ${APP_VERSION:-2.0.0}"
    ui_center_text "║ $version_text ║" "$((header_width + 2))"
    
    # Bottom border
    printf "╚%*s╝\n" "$header_width" | sed 's/ /═/g'
    
    printf "%s" "${UI_COLORS[reset]}"
}

# Enhanced progress bar
ui_show_progress() {
    local current="$1"
    local total="$2"
    local message="${3:-Processing...}"
    local show_percentage="${4:-true}"
    
    # Calculate progress
    local percentage=$((current * 100 / total))
    local filled_width=$((UI_PROGRESS_WIDTH * current / total))
    local empty_width=$((UI_PROGRESS_WIDTH - filled_width))
    
    # Build progress bar
    local progress_bar=""
    local i
    
    # Filled portion
    for ((i=0; i<filled_width; i++)); do
        progress_bar+="${UI_PROGRESS_CHAR}"
    done
    
    # Empty portion
    for ((i=0; i<empty_width; i++)); do
        progress_bar+="${UI_PROGRESS_EMPTY}"
    done
    
    # Print progress bar
    printf "\r%s[%s%s%s] " \
        "$message " \
        "${UI_COLORS[success]}" \
        "$progress_bar" \
        "${UI_COLORS[reset]}"
    
    # Show percentage if requested
    if [[ "$show_percentage" == "true" ]]; then
        printf "%3d%% (%d/%d)" "$percentage" "$current" "$total"
    fi
    
    # Flush output
    printf "%s" ""
}

# Status message with icon
ui_show_status() {
    local status="$1"    # success, error, warning, info, loading
    local message="$2"
    local newline="${3:-true}"
    
    local icon="${UI_ICONS[$status]:-${UI_ICONS[info]}}"
    local color=""
    
    case "$status" in
        "success") color="${UI_COLORS[success]}" ;;
        "error") color="${UI_COLORS[error]}" ;;
        "warning") color="${UI_COLORS[warning]}" ;;
        "loading") color="${UI_COLORS[primary]}" ;;
        *) color="${UI_COLORS[info]}" ;;
    esac
    
    printf "%s%s %s%s" "$color" "$icon" "$message" "${UI_COLORS[reset]}"
    
    if [[ "$newline" == "true" ]]; then
        echo
    fi
}

# Animated loading indicator
ui_show_loading() {
    local message="$1"
    local duration="${2:-3}"
    
    local spinner="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local i=0
    local start_time=$(date +%s)
    
    while (( $(date +%s) - start_time < duration )); do
        local char="${spinner:$((i % ${#spinner})):1}"
        printf "\r%s%s %s%s" "${UI_COLORS[primary]}" "$char" "$message" "${UI_COLORS[reset]}"
        sleep 0.1
        ((i++))
    done
    
    printf "\r%s%s %s%s\n" "${UI_COLORS[success]}" "${UI_ICONS[success]}" "$message" "${UI_COLORS[reset]}"
}

# Confirmation dialog
ui_confirm() {
    local message="$1"
    local default="${2:-y}"  # y or n
    
    local prompt=""
    if [[ "$default" == "y" ]]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    
    printf "%s%s %s %s " "${UI_COLORS[warning]}" "${UI_ICONS[warning]}" "$message" "$prompt"
    
    local response
    read -r response
    
    # Handle empty response (use default)
    if [[ -z "$response" ]]; then
        response="$default"
    fi
    
    # Check response
    case "${response,,}" in
        y|yes|có|ok) return 0 ;;
        *) return 1 ;;
    esac
}

# Input field with validation
ui_input() {
    local prompt="$1"
    local validation_pattern="${2:-.*}"  # Regex pattern
    local error_message="${3:-Giá trị không hợp lệ}"
    local default_value="${4:-}"
    
    while true; do
        printf "%s%s%s" "${UI_COLORS[primary]}" "$prompt" "${UI_COLORS[reset]}"
        
        if [[ -n "$default_value" ]]; then
            printf " [%s]: " "$default_value"
        else
            printf ": "
        fi
        
        local input
        read -r input
        
        # Use default if empty
        if [[ -z "$input" && -n "$default_value" ]]; then
            input="$default_value"
        fi
        
        # Validate input
        if [[ "$input" =~ $validation_pattern ]]; then
            echo "$input"
            return 0
        else
            ui_show_status "error" "$error_message"
            echo
        fi
    done
}

# Selection menu
ui_select() {
    local prompt="$1"
    shift
    local options=("$@")
    
    echo "$prompt"
    echo
    
    local i=0
    for option in "${options[@]}"; do
        printf "  %s%d.%s %s\n" "${UI_COLORS[accent]}" "$((i+1))" "${UI_COLORS[reset]}" "$option"
        ((i++))
    done
    
    echo
    
    while true; do
        printf "%sLựa chọn (1-%d): %s" "${UI_COLORS[primary]}" "${#options[@]}" "${UI_COLORS[reset]}"
        local choice
        read -r choice
        
        # Validate choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 && $choice -le ${#options[@]} ]]; then
            echo "$((choice - 1))"  # Return 0-based index
            return 0
        else
            ui_show_status "error" "Lựa chọn không hợp lệ. Vui lòng chọn từ 1 đến ${#options[@]}"
        fi
    done
}

# Table display
ui_show_table() {
    local -n headers_ref=$1
    local -n data_ref=$2
    local max_width="${3:-$UI_TERMINAL_WIDTH}"
    
    # Calculate column widths
    local num_cols=${#headers_ref[@]}
    local col_width=$((max_width / num_cols - 3))
    
    # Print headers
    printf "%s" "${UI_COLORS[bold]}"
    local i
    for ((i=0; i<num_cols; i++)); do
        printf "%-*s" "$col_width" "${headers_ref[i]}"
        if [[ $i -lt $((num_cols - 1)) ]]; then
            printf " | "
        fi
    done
    printf "%s\n" "${UI_COLORS[reset]}"
    
    # Print separator
    for ((i=0; i<max_width; i++)); do
        printf "─"
    done
    echo
    
    # Print data rows
    for row in "${data_ref[@]}"; do
        IFS='|' read -ra cols <<< "$row"
        for ((i=0; i<num_cols && i<${#cols[@]}; i++)); do
            printf "%-*s" "$col_width" "${cols[i]}"
            if [[ $i -lt $((num_cols - 1)) ]]; then
                printf " | "
            fi
        done
        echo
    done
}

# Notification display
ui_show_notification() {
    local type="$1"      # info, success, warning, error
    local title="$2"
    local message="$3"
    local duration="${4:-3}"
    
    local color=""
    local icon=""
    
    case "$type" in
        "success")
            color="${UI_COLORS[success]}"
            icon="${UI_ICONS[success]}"
            ;;
        "error")
            color="${UI_COLORS[error]}"
            icon="${UI_ICONS[error]}"
            ;;
        "warning")
            color="${UI_COLORS[warning]}"
            icon="${UI_ICONS[warning]}"
            ;;
        *)
            color="${UI_COLORS[info]}"
            icon="${UI_ICONS[info]}"
            ;;
    esac
    
    # Create notification box
    local notification_text="$icon $title"
    if [[ -n "$message" ]]; then
        notification_text="$notification_text\n$message"
    fi
    
    printf "\n%s" "$color"
    ui_print_box "$notification_text" "$((UI_TERMINAL_WIDTH - 10))"
    printf "%s\n" "${UI_COLORS[reset]}"
    
    # Auto-dismiss if duration > 0
    if [[ $duration -gt 0 ]]; then
        sleep "$duration"
    fi
}

# Pause with message
ui_pause() {
    local message="${1:-Nhấn phím bất kỳ để tiếp tục...}"
    
    printf "\n%s%s%s" "${UI_COLORS[dim]}" "$message" "${UI_COLORS[reset]}"
    read -r -n1
    echo
}

# Cleanup UI resources
cleanup_ui() {
    # Reset terminal
    printf "%s" "${UI_COLORS[reset]}"
    
    # Clear any remaining escape sequences
    if command -v reset >/dev/null 2>&1; then
        reset 2>/dev/null
    fi
}

# Get user choice with enhanced input handling
ui_get_choice() {
    local max_choice="$1"
    local prompt="${2:-Lựa chọn của bạn: }"
    
    while true; do
        printf "%s%s%s" "${UI_COLORS[bold]}" "$prompt" "${UI_COLORS[reset]}"
        local choice
        read -r choice
        
        # Validate choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 0 && $choice -le $max_choice ]]; then
            echo "$choice"
            return 0
        else
            ui_show_status "error" "Lựa chọn không hợp lệ. Vui lòng chọn từ 0 đến $max_choice"
            echo
        fi
    done
}

# Show main menu using V2 system
show_main_menu() {
    ui_clear_screen
    print_app_header_enhanced
    
    echo
    printf "${UI_COLORS[primary]}${UI_COLORS[bold]}═══ MENU CHÍNH ═══${UI_COLORS[reset]}\n\n"
    
    printf "${UI_COLORS[accent]}1.${UI_COLORS[reset]} ${UI_ICONS[package]} Quản lý gói (Packages)\n"
    printf "${UI_COLORS[accent]}2.${UI_COLORS[reset]} ${UI_ICONS[tools]} Môi trường phát triển (Development)\n" 
    printf "${UI_COLORS[accent]}3.${UI_COLORS[reset]} ${UI_ICONS[gear]} Cấu hình hệ thống (System Config)\n"
    printf "${UI_COLORS[accent]}4.${UI_COLORS[reset]} ${UI_ICONS[stats]} Thống kê hệ thống (System Stats)\n"
    printf "${UI_COLORS[accent]}5.${UI_COLORS[reset]} ${UI_ICONS[gear]} Quản lý module (Module Management)\n"
    printf "${UI_COLORS[accent]}6.${UI_COLORS[reset]} ${UI_ICONS[info]} Thông tin ứng dụng (About)\n"
    printf "${UI_COLORS[accent]}0.${UI_COLORS[reset]} ${UI_ICONS[exit]} Thoát (Exit)\n"
    
    echo
    printf "${UI_COLORS[bold]}${UI_COLORS[primary]}Lựa chọn của bạn: ${UI_COLORS[reset]}"
}

# Basic input function for compatibility
read_user_choice() {
    local choice
    read -r choice
    echo "$choice"
}

# Module UI functions - compatibility layer for V2 modules
display_module_header() {
    local title="$1"
    local icon="${2:-📦}"
    
    ui_clear_screen
    print_app_header_enhanced
    
    echo
    printf "${UI_COLORS[primary]}${UI_COLORS[bold]}═══ $icon $title ═══${UI_COLORS[reset]}\n\n"
}

display_module_footer() {
    local prompt="$1"
    
    echo
    ui_print_line "─" "$UI_TERMINAL_WIDTH" "${UI_COLORS[dim]}"
    printf "${UI_COLORS[bold]}${UI_COLORS[primary]}$prompt: ${UI_COLORS[reset]}"
}

display_section_header() {
    local title="$1"
    local icon="${2:-⚙️}"
    
    echo
    printf "${UI_COLORS[primary]}${UI_COLORS[bold]}$icon $title${UI_COLORS[reset]}\n"
    ui_print_line "─" "$((${#title} + 3))" "${UI_COLORS[primary]}"
    echo
}

show_notification() {
    local message="$1"
    local type="${2:-info}"
    
    ui_show_status "$type" "$message"
}

show_progress() {
    local message="$1"
    local percent="${2:-0}"
    
    ui_show_progress "$percent" "100" "$message"
}

read_single_key() {
    local key
    # Try to use the utils.sh version if available
    if declare -f "read_single_key" >/dev/null 2>&1 && [[ "${BASH_SOURCE[0]}" != *"ui_system.sh" ]]; then
        # Call the original function from utils.sh
        command read_single_key
    else
        # Fallback implementation
        if command -v stty >/dev/null 2>&1; then
            local old_stty_cfg
            old_stty_cfg=$(stty -g)
            stty raw -echo
            key=$(dd bs=1 count=1 2>/dev/null)
            stty "$old_stty_cfg"
        else
            read -r -n1 key
        fi
        printf "%s" "$key"
    fi
}

wait_for_user() {
    ui_pause
}

# Event system stubs
publish_event() {
    local event="$1"
    local data="${2:-}"
    log_debug "EVENT" "Publishing event: $event with data: $data"
}

subscribe_to_event() {
    local event="$1"
    local handler="$2"
    log_debug "EVENT" "Subscribed to event: $event with handler: $handler"
}

# Icon helper function
get_icon() {
    local icon_name="$1"
    echo "${UI_ICONS[${icon_name,,}]:-●}"
}

# V1 compatibility functions
print_boxed_message() {
    local message="$1"
    local type="${2:-info}"
    show_notification "$message" "$type"
}

confirm_yn() {
    local prompt="$1"
    local default="${2:-y}"
    ui_confirm "$prompt" "$default"
}

get_user_choice() {
    local min="$1"
    local max="$2"
    local prompt="${3:-Nhập lựa chọn của bạn}"
    ui_get_choice "$max" "$prompt"
}

show_spinner() {
    local message="$1"
    local duration="${2:-2}"
    ui_show_loading "$message" "$duration"
}

center_text() {
    local text="$1"
    ui_center_text "$text"
}

wait_return_to_main() {
    echo -e "${UI_COLORS[warning]}Nhấn phím bất kỳ để quay lại menu chính...${UI_COLORS[reset]}"
    read_single_key >/dev/null
}

# Additional missing functions found in modules
print_fancy_header() {
    print_app_header_enhanced
}

display_menu() {
    show_main_menu
}

show_exit_message() {
    echo
    ui_center_text "Cảm ơn bạn đã sử dụng Linux Manager!" "$UI_TERMINAL_WIDTH" "${UI_COLORS[primary]}${UI_COLORS[bold]}" "${UI_COLORS[reset]}"
    ui_center_text "Hẹn gặp lại! 👋" "$UI_TERMINAL_WIDTH" "${UI_COLORS[success]}" "${UI_COLORS[reset]}"
    echo
}

# Module management stubs
source_v1_modules() {
    log_debug "MODULE" "source_v1_modules called"
    return 0
}

init_package_cache() {
    log_debug "MODULE" "init_package_cache called"
    return 0
}

# Additional stubs for missing functions
log_performance() {
    local component="$1"
    local message="$2"
    local duration="${3:-0}"
    log_info "$component" "$message (${duration}ms)"
}

get_timestamp_ms() {
    date +%s%3N
}

# Package management function stubs
manage_package_installation() {
    show_notification "Package installation management coming soon!" "info"
    wait_for_user
}

manage_package_search() {
    show_notification "Package search management coming soon!" "info"
    wait_for_user
}

manage_package_removal() {
    show_notification "Package removal management coming soon!" "info"
    wait_for_user
}

show_package_statistics() {
    show_notification "Package statistics coming soon!" "info"
    wait_for_user
}

manage_package_settings() {
    show_notification "Package settings management coming soon!" "info"
    wait_for_user
}

# System management function stubs
manage_shell_configuration_v2() {
    show_notification "Shell configuration management coming soon!" "info"
    wait_for_user
}

manage_editor_configuration_v2() {
    show_notification "Editor configuration management coming soon!" "info"
    wait_for_user
}

manage_network_configuration_v2() {
    show_notification "Network configuration management coming soon!" "info"
    wait_for_user
}

manage_system_services_v2() {
    show_notification "System services management coming soon!" "info"
    wait_for_user
}

manage_system_backup_v2() {
    show_notification "System backup management coming soon!" "info"
    wait_for_user
}

manage_window_manager_v2() {
    show_notification "Window manager setup coming soon!" "info"
    wait_for_user
}

manage_terminal_configuration_v2() {
    show_notification "Terminal configuration management coming soon!" "info"
    wait_for_user
}

manage_system_cleanup_v2() {
    show_notification "System cleanup management coming soon!" "info"
    wait_for_user
}

show_system_information() {
    show_notification "System information display coming soon!" "info"
    wait_for_user
}

# Development management function stubs
manage_php_environment_v2() {
    show_notification "PHP environment management coming soon!" "info"
    wait_for_user
}

manage_nodejs_environment_v2() {
    show_notification "Node.js environment management coming soon!" "info"
    wait_for_user
}

manage_python_environment_v2() {
    show_notification "Python environment management coming soon!" "info"
    wait_for_user
}

manage_docker_environment_v2() {
    show_notification "Docker environment management coming soon!" "info"
    wait_for_user
}

manage_git_configuration_v2() {
    show_notification "Git configuration management coming soon!" "info"
    wait_for_user
}

# Main V2 handlers called by the main script
handle_packages_v2() {
    # Try to use the actual V2 packages module if available
    if declare -f "manage_packages_v2" >/dev/null 2>&1; then
        manage_packages_v2
    else
        # Fallback implementation
        while true; do
            display_module_header "PACKAGE MANAGEMENT" "📦"
            
            printf "  📦 ${UI_COLORS[accent]}${UI_COLORS[bold]}[1]${UI_COLORS[reset]}  ${UI_COLORS[info]}Install Packages${UI_COLORS[reset]}\n"
            printf "  🔍 ${UI_COLORS[accent]}${UI_COLORS[bold]}[2]${UI_COLORS[reset]}  ${UI_COLORS[info]}Search Packages${UI_COLORS[reset]}\n"
            printf "  ⬆️  ${UI_COLORS[accent]}${UI_COLORS[bold]}[3]${UI_COLORS[reset]}  ${UI_COLORS[info]}Update System${UI_COLORS[reset]}\n"
            printf "  ❌ ${UI_COLORS[accent]}${UI_COLORS[bold]}[4]${UI_COLORS[reset]}  ${UI_COLORS[info]}Remove Packages${UI_COLORS[reset]}\n"
            printf "  📊 ${UI_COLORS[accent]}${UI_COLORS[bold]}[5]${UI_COLORS[reset]}  ${UI_COLORS[info]}Package Statistics${UI_COLORS[reset]}\n"
            printf "  ${UI_ICONS[exit]} ${UI_COLORS[error]}${UI_COLORS[bold]}[0]${UI_COLORS[reset]}  ${UI_COLORS[info]}Return to Main Menu${UI_COLORS[reset]}\n"
            
            display_module_footer "Choose option [0-5]"
            
            local choice
            choice=$(read_single_key)
            echo "$choice"
            echo
            
            case "$choice" in
                1) manage_package_installation ;;
                2) manage_package_search ;;
                3) show_notification "System update coming soon!" "info"; wait_for_user ;;
                4) manage_package_removal ;;
                5) show_package_statistics ;;
                0) return 0 ;;
                *) show_notification "Invalid choice: $choice" "error" ;;
            esac
        done
    fi
}

handle_development_v2() {
    # Try to use the actual V2 development module if available
    if declare -f "manage_development_v2" >/dev/null 2>&1; then
        manage_development_v2
    else
        # Fallback implementation
        while true; do
            display_module_header "DEVELOPMENT ENVIRONMENT" "💻"
            
            printf "  🐘 ${UI_COLORS[accent]}${UI_COLORS[bold]}[1]${UI_COLORS[reset]}  ${UI_COLORS[info]}PHP Environment${UI_COLORS[reset]}\n"
            printf "  🟢 ${UI_COLORS[accent]}${UI_COLORS[bold]}[2]${UI_COLORS[reset]}  ${UI_COLORS[info]}Node.js Environment${UI_COLORS[reset]}\n"
            printf "  🐍 ${UI_COLORS[accent]}${UI_COLORS[bold]}[3]${UI_COLORS[reset]}  ${UI_COLORS[info]}Python Environment${UI_COLORS[reset]}\n"
            printf "  🐳 ${UI_COLORS[accent]}${UI_COLORS[bold]}[4]${UI_COLORS[reset]}  ${UI_COLORS[info]}Docker Environment${UI_COLORS[reset]}\n"
            printf "  🌿 ${UI_COLORS[accent]}${UI_COLORS[bold]}[5]${UI_COLORS[reset]}  ${UI_COLORS[info]}Git Configuration${UI_COLORS[reset]}\n"
            printf "  ${UI_ICONS[exit]} ${UI_COLORS[error]}${UI_COLORS[bold]}[0]${UI_COLORS[reset]}  ${UI_COLORS[info]}Return to Main Menu${UI_COLORS[reset]}\n"
            
            display_module_footer "Choose option [0-5]"
            
            local choice
            choice=$(read_single_key)
            echo "$choice"
            echo
            
            case "$choice" in
                1) manage_php_environment_v2 ;;
                2) manage_nodejs_environment_v2 ;;
                3) manage_python_environment_v2 ;;
                4) manage_docker_environment_v2 ;;
                5) manage_git_configuration_v2 ;;
                0) return 0 ;;
                *) show_notification "Invalid choice: $choice" "error" ;;
            esac
        done
    fi
}

handle_system_config_v2() {
    # Try to use the actual V2 system module if available
    if declare -f "manage_system_v2" >/dev/null 2>&1; then
        manage_system_v2
    else
        # Fallback implementation
        while true; do
            display_module_header "SYSTEM CONFIGURATION" "⚙️"
            
            printf "  🗺️  ${UI_COLORS[accent]}${UI_COLORS[bold]}[1]${UI_COLORS[reset]}  ${UI_COLORS[info]}Shell Configuration${UI_COLORS[reset]}\n"
            printf "  📝 ${UI_COLORS[accent]}${UI_COLORS[bold]}[2]${UI_COLORS[reset]}  ${UI_COLORS[info]}Editor Configuration${UI_COLORS[reset]}\n"
            printf "  🌐 ${UI_COLORS[accent]}${UI_COLORS[bold]}[3]${UI_COLORS[reset]}  ${UI_COLORS[info]}Network Configuration${UI_COLORS[reset]}\n"
            printf "  🔧 ${UI_COLORS[accent]}${UI_COLORS[bold]}[4]${UI_COLORS[reset]}  ${UI_COLORS[info]}System Services${UI_COLORS[reset]}\n"
            printf "  💾 ${UI_COLORS[accent]}${UI_COLORS[bold]}[5]${UI_COLORS[reset]}  ${UI_COLORS[info]}System Backup${UI_COLORS[reset]}\n"
            printf "  🧹 ${UI_COLORS[accent]}${UI_COLORS[bold]}[6]${UI_COLORS[reset]}  ${UI_COLORS[info]}System Cleanup${UI_COLORS[reset]}\n"
            printf "  📊 ${UI_COLORS[accent]}${UI_COLORS[bold]}[7]${UI_COLORS[reset]}  ${UI_COLORS[info]}System Information${UI_COLORS[reset]}\n"
            printf "  ${UI_ICONS[exit]} ${UI_COLORS[error]}${UI_COLORS[bold]}[0]${UI_COLORS[reset]}  ${UI_COLORS[info]}Return to Main Menu${UI_COLORS[reset]}\n"
            
            display_module_footer "Choose option [0-7]"
            
            local choice
            choice=$(read_single_key)
            echo "$choice"
            echo
            
            case "$choice" in
                1) manage_shell_configuration_v2 ;;
                2) manage_editor_configuration_v2 ;;
                3) manage_network_configuration_v2 ;;
                4) manage_system_services_v2 ;;
                5) manage_system_backup_v2 ;;
                6) manage_system_cleanup_v2 ;;
                7) show_system_information ;;
                0) return 0 ;;
                *) show_notification "Invalid choice: $choice" "error" ;;
            esac
        done
    fi
}

# Export UI functions
export -f init_ui_system detect_terminal_capabilities load_ui_configuration
export -f apply_ui_theme init_color_support setup_ui_signal_handlers
export -f ui_clear_screen ui_print_title ui_center_text ui_print_line
export -f ui_print_box ui_show_menu print_app_header_enhanced ui_show_progress
export -f ui_show_status ui_show_loading ui_confirm ui_input ui_select
export -f ui_show_table ui_show_notification ui_pause cleanup_ui ui_get_choice
export -f show_main_menu read_user_choice

# Export V2 module compatibility functions
export -f display_module_header display_module_footer display_section_header
export -f show_notification show_progress read_single_key wait_for_user
export -f publish_event subscribe_to_event get_icon

# Export V1 compatibility functions
export -f print_boxed_message confirm_yn get_user_choice show_spinner center_text
export -f wait_return_to_main print_fancy_header display_menu show_exit_message
export -f source_v1_modules init_package_cache log_performance get_timestamp_ms

# Export module management function stubs
export -f manage_package_installation manage_package_search manage_package_removal
export -f show_package_statistics manage_package_settings
export -f manage_shell_configuration_v2 manage_editor_configuration_v2
export -f manage_network_configuration_v2 manage_system_services_v2
export -f manage_system_backup_v2 manage_window_manager_v2
export -f manage_terminal_configuration_v2 manage_system_cleanup_v2
export -f show_system_information manage_php_environment_v2
export -f manage_nodejs_environment_v2 manage_python_environment_v2
export -f manage_docker_environment_v2 manage_git_configuration_v2

# Export main V2 handlers
export -f handle_packages_v2 handle_development_v2 handle_system_config_v2
