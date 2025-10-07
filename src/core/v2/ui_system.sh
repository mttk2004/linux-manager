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

# Package installation helper functions
install_package_list() {
    local list_type="$1"
    local list_file="$ROOT_DIR/src/data/packages/${list_type}.list"
    
    if [[ ! -f "$list_file" ]]; then
        show_notification "Package list not found: $list_file" "error"
        wait_for_user
        return 1
    fi
    
    display_module_header "INSTALL ${list_type^^} PACKAGES" "📦"
    
    printf "${UI_COLORS[info]}Reading package list from: ${UI_COLORS[success]}$list_file${UI_COLORS[reset]}\n"
    echo
    
    # Read and display packages
    local packages=()
    while IFS= read -r line; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        packages+=("$line")
    done < "$list_file"
    
    if [[ ${#packages[@]} -eq 0 ]]; then
        show_notification "No packages found in list" "warning"
        wait_for_user
        return 1
    fi
    
    printf "${UI_COLORS[info]}Found ${UI_COLORS[success]}${#packages[@]}${UI_COLORS[info]} packages to install:${UI_COLORS[reset]}\n"
    echo
    
    # Display packages in a nice format
    local count=0
    for package in "${packages[@]}"; do
        if [[ $count -eq 0 ]]; then
            printf "  "
        fi
        printf "${UI_COLORS[accent]}$package${UI_COLORS[reset]} "
        ((count++))
        if [[ $count -eq 4 ]]; then
            echo
            count=0
        fi
    done
    [[ $count -ne 0 ]] && echo
    
    echo
    if ui_confirm "Do you want to install these packages?"; then
        echo
        show_progress "Preparing installation" 10
        
        # Use appropriate installer based on list type
        case "$list_type" in
            "pacman"|"dev"|"multimedia")
                install_packages_with_pacman "${packages[@]}"
                ;;
            "aur")
                install_packages_with_aur "${packages[@]}"
                ;;
            *)
                show_notification "Unknown package list type: $list_type" "error"
                ;;
        esac
    else
        show_notification "Installation cancelled by user" "info"
    fi
    
    echo
    wait_for_user
}

install_packages_with_pacman() {
    local packages=("$@")
    
    show_progress "Installing packages with pacman" 30
    
    # Check if packages are available
    local available_packages=()
    local unavailable_packages=()
    
    for package in "${packages[@]}"; do
        if pacman -Si "$package" >/dev/null 2>&1; then
            available_packages+=("$package")
        else
            unavailable_packages+=("$package")
        fi
    done
    
    if [[ ${#unavailable_packages[@]} -gt 0 ]]; then
        printf "${UI_COLORS[warning]}Warning: These packages are not available:${UI_COLORS[reset]}\n"
        for package in "${unavailable_packages[@]}"; do
            printf "  ${UI_COLORS[error]}• $package${UI_COLORS[reset]}\n"
        done
        echo
    fi
    
    if [[ ${#available_packages[@]} -eq 0 ]]; then
        show_notification "No packages available to install" "error"
        return 1
    fi
    
    show_progress "Installing ${#available_packages[@]} packages" 50
    
    # Install packages
    if sudo pacman -S --needed --noconfirm "${available_packages[@]}"; then
        show_progress "Installation completed" 100
        show_notification "Successfully installed ${#available_packages[@]} packages" "success"
        
        # Log installed packages
        log_info "PACKAGES" "Installed pacman packages: ${available_packages[*]}"
    else
        show_notification "Some packages failed to install" "error"
        return 1
    fi
}

install_packages_with_aur() {
    local packages=("$@")
    
    # Check if AUR helper is available
    local aur_helper=""
    if command -v yay >/dev/null 2>&1; then
        aur_helper="yay"
    elif command -v paru >/dev/null 2>&1; then
        aur_helper="paru"
    else
        show_notification "No AUR helper found. Please install yay or paru first." "error"
        return 1
    fi
    
    show_progress "Installing packages with $aur_helper" 30
    
    # Install packages
    if "$aur_helper" -S --needed --noconfirm "${packages[@]}"; then
        show_progress "Installation completed" 100
        show_notification "Successfully installed ${#packages[@]} AUR packages" "success"
        
        # Log installed packages
        log_info "PACKAGES" "Installed AUR packages: ${packages[*]}"
    else
        show_notification "Some AUR packages failed to install" "error"
        return 1
    fi
}

install_custom_package() {
    display_module_header "CUSTOM PACKAGE INSTALLATION" "⚙️"
    
    printf "${UI_COLORS[info]}Enter package name(s) to install (space-separated):${UI_COLORS[reset]}\n"
    printf "${UI_COLORS[dim]}Examples: vim git firefox, google-chrome${UI_COLORS[reset]}\n"
    echo
    
    printf "${UI_COLORS[primary]}Package name(s): ${UI_COLORS[reset]}"
    local package_input
    read -r package_input
    
    if [[ -z "$package_input" ]]; then
        show_notification "No packages specified" "warning"
        wait_for_user
        return 1
    fi
    
    # Convert input to array
    local packages
    IFS=' ' read -ra packages <<< "$package_input"
    
    echo
    printf "${UI_COLORS[info]}Packages to install: ${UI_COLORS[success]}${packages[*]}${UI_COLORS[reset]}\n"
    echo
    
    printf "${UI_COLORS[primary]}Choose installation method:${UI_COLORS[reset]}\n"
    printf "  ${UI_COLORS[accent]}[1]${UI_COLORS[reset]} Pacman (official repositories)\n"
    printf "  ${UI_COLORS[accent]}[2]${UI_COLORS[reset]} AUR (Arch User Repository)\n"
    printf "  ${UI_COLORS[accent]}[0]${UI_COLORS[reset]} Cancel\n"
    echo
    
    printf "${UI_COLORS[primary]}Choice: ${UI_COLORS[reset]}"
    local method_choice
    read -r method_choice
    
    echo
    case "$method_choice" in
        1)
            install_packages_with_pacman "${packages[@]}"
            ;;
        2)
            install_packages_with_aur "${packages[@]}"
            ;;
        0)
            show_notification "Installation cancelled" "info"
            ;;
        *)
            show_notification "Invalid choice" "error"
            ;;
    esac
    
    wait_for_user
}

install_flatpak_apps_interactive() {
    display_module_header "FLATPAK APPLICATIONS" "📱"
    
    if ! command -v flatpak >/dev/null 2>&1; then
        printf "${UI_COLORS[warning]}Flatpak is not installed.${UI_COLORS[reset]}\n"
        echo
        if ui_confirm "Would you like to install Flatpak first?"; then
            if sudo pacman -S --noconfirm flatpak; then
                show_notification "Flatpak installed successfully" "success"
                show_notification "Please restart your session to use Flatpak" "info"
            else
                show_notification "Failed to install Flatpak" "error"
            fi
        fi
        wait_for_user
        return 1
    fi
    
    printf "${UI_COLORS[info]}Popular Flatpak applications:${UI_COLORS[reset]}\n"
    echo
    
    # Common flatpak apps
    local flatpak_apps=(
        "org.mozilla.firefox:Firefox Web Browser"
        "com.google.Chrome:Google Chrome"
        "org.libreoffice.LibreOffice:LibreOffice Suite"
        "com.spotify.Client:Spotify Music"
        "org.videolan.VLC:VLC Media Player"
        "com.discordapp.Discord:Discord"
        "org.telegram.desktop:Telegram"
        "org.gimp.GIMP:GIMP Image Editor"
    )
    
    local i=1
    for app_info in "${flatpak_apps[@]}"; do
        IFS=':' read -r app_id app_name <<< "$app_info"
        printf "  ${UI_COLORS[accent]}[%d]${UI_COLORS[reset]} %s ${UI_COLORS[dim]}(%s)${UI_COLORS[reset]}\n" "$i" "$app_name" "$app_id"
        ((i++))
    done
    
    printf "  ${UI_COLORS[accent]}[9]${UI_COLORS[reset]} Custom Flatpak app (enter App ID)\n"
    printf "  ${UI_COLORS[accent]}[0]${UI_COLORS[reset]} Return\n"
    
    echo
    printf "${UI_COLORS[primary]}Choice: ${UI_COLORS[reset]}"
    local app_choice
    read -r app_choice
    
    echo
    case "$app_choice" in
        [1-8])
            local selected_app="${flatpak_apps[$((app_choice-1))]}"
            IFS=':' read -r app_id app_name <<< "$selected_app"
            
            if flatpak install -y flathub "$app_id"; then
                show_notification "Successfully installed $app_name" "success"
            else
                show_notification "Failed to install $app_name" "error"
            fi
            ;;
        9)
            printf "${UI_COLORS[primary]}Enter Flatpak App ID: ${UI_COLORS[reset]}"
            local custom_app_id
            read -r custom_app_id
            
            if [[ -n "$custom_app_id" ]]; then
                if flatpak install -y flathub "$custom_app_id"; then
                    show_notification "Successfully installed $custom_app_id" "success"
                else
                    show_notification "Failed to install $custom_app_id" "error"
                fi
            fi
            ;;
        0)
            return 0
            ;;
        *)
            show_notification "Invalid choice" "error"
            ;;
    esac
    
    wait_for_user
}

# Package search functions
search_pacman_packages() {
    display_module_header "SEARCH PACMAN PACKAGES" "📦"
    
    printf "${UI_COLORS[primary]}Enter search term: ${UI_COLORS[reset]}"
    local search_term
    read -r search_term
    
    if [[ -z "$search_term" ]]; then
        show_notification "No search term provided" "warning"
        wait_for_user
        return 1
    fi
    
    echo
    printf "${UI_COLORS[info]}Searching for: ${UI_COLORS[success]}$search_term${UI_COLORS[reset]}\n"
    echo
    
    pacman -Ss "$search_term" | head -20
    
    echo
    wait_for_user
}

search_aur_packages() {
    display_module_header "SEARCH AUR PACKAGES" "🏠"
    
    if ! command -v yay >/dev/null 2>&1 && ! command -v paru >/dev/null 2>&1; then
        show_notification "No AUR helper found. Please install yay or paru first." "error"
        wait_for_user
        return 1
    fi
    
    printf "${UI_COLORS[primary]}Enter search term: ${UI_COLORS[reset]}"
    local search_term
    read -r search_term
    
    if [[ -z "$search_term" ]]; then
        show_notification "No search term provided" "warning"
        wait_for_user
        return 1
    fi
    
    echo
    printf "${UI_COLORS[info]}Searching AUR for: ${UI_COLORS[success]}$search_term${UI_COLORS[reset]}\n"
    echo
    
    if command -v yay >/dev/null 2>&1; then
        yay -Ss "$search_term" | head -20
    elif command -v paru >/dev/null 2>&1; then
        paru -Ss "$search_term" | head -20
    fi
    
    echo
    wait_for_user
}

search_flatpak_apps() {
    display_module_header "SEARCH FLATPAK APPS" "📱"
    
    if ! command -v flatpak >/dev/null 2>&1; then
        show_notification "Flatpak is not installed" "error"
        wait_for_user
        return 1
    fi
    
    printf "${UI_COLORS[primary]}Enter search term: ${UI_COLORS[reset]}"
    local search_term
    read -r search_term
    
    if [[ -z "$search_term" ]]; then
        show_notification "No search term provided" "warning"
        wait_for_user
        return 1
    fi
    
    echo
    printf "${UI_COLORS[info]}Searching Flatpak for: ${UI_COLORS[success]}$search_term${UI_COLORS[reset]}\n"
    echo
    
    flatpak search "$search_term" | head -20
    
    echo
    wait_for_user
}

show_installed_packages() {
    display_module_header "INSTALLED PACKAGES" "📊"
    
    printf "${UI_COLORS[primary]}Choose package manager:${UI_COLORS[reset]}\n"
    printf "  ${UI_COLORS[accent]}[1]${UI_COLORS[reset]} Pacman packages\n"
    printf "  ${UI_COLORS[accent]}[2]${UI_COLORS[reset]} AUR packages\n"
    printf "  ${UI_COLORS[accent]}[3]${UI_COLORS[reset]} Flatpak apps\n"
    printf "  ${UI_COLORS[accent]}[4]${UI_COLORS[reset]} All packages (summary)\n"
    printf "  ${UI_COLORS[accent]}[0]${UI_COLORS[reset]} Return\n"
    echo
    
    printf "${UI_COLORS[primary]}Choice: ${UI_COLORS[reset]}"
    local choice
    read -r choice
    
    echo
    case "$choice" in
        1)
            printf "${UI_COLORS[info]}Pacman packages (showing first 20):${UI_COLORS[reset]}\n"
            echo
            pacman -Q | head -20
            printf "\n${UI_COLORS[dim]}Total: $(pacman -Q | wc -l) packages${UI_COLORS[reset]}\n"
            ;;
        2)
            printf "${UI_COLORS[info]}Foreign packages (likely AUR):${UI_COLORS[reset]}\n"
            echo
            pacman -Qm | head -20
            printf "\n${UI_COLORS[dim]}Total: $(pacman -Qm | wc -l) foreign packages${UI_COLORS[reset]}\n"
            ;;
        3)
            if command -v flatpak >/dev/null 2>&1; then
                printf "${UI_COLORS[info]}Flatpak applications:${UI_COLORS[reset]}\n"
                echo
                flatpak list --app
            else
                show_notification "Flatpak is not installed" "error"
            fi
            ;;
        4)
            printf "${UI_COLORS[primary]}${UI_COLORS[bold]}╔══ Package Summary ══╗${UI_COLORS[reset]}\n"
            printf "${UI_COLORS[info]}Pacman packages: ${UI_COLORS[success]}$(pacman -Q | wc -l)${UI_COLORS[reset]}\n"
            printf "${UI_COLORS[info]}Foreign packages: ${UI_COLORS[success]}$(pacman -Qm | wc -l)${UI_COLORS[reset]}\n"
            if command -v flatpak >/dev/null 2>&1; then
                printf "${UI_COLORS[info]}Flatpak apps: ${UI_COLORS[success]}$(flatpak list --app | wc -l)${UI_COLORS[reset]}\n"
            fi
            ;;
        0)
            return 0
            ;;
        *)
            show_notification "Invalid choice" "error"
            ;;
    esac
    
    echo
    wait_for_user
}

# Package management function stubs
manage_package_installation() {
    while true; do
        display_module_header "PACKAGE INSTALLATION" "📦"
        
        printf "  📦 ${UI_COLORS[accent]}${UI_COLORS[bold]}[1]${UI_COLORS[reset]}  ${UI_COLORS[info]}Install Essential Packages${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Basic system packages from Pacman${UI_COLORS[reset]}\n"
        echo
        
        printf "  🛠️  ${UI_COLORS[accent]}${UI_COLORS[bold]}[2]${UI_COLORS[reset]}  ${UI_COLORS[info]}Install Development Packages${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Programming tools and libraries${UI_COLORS[reset]}\n"
        echo
        
        printf "  🎥 ${UI_COLORS[accent]}${UI_COLORS[bold]}[3]${UI_COLORS[reset]}  ${UI_COLORS[info]}Install Multimedia Packages${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Audio, video and graphics tools${UI_COLORS[reset]}\n"
        echo
        
        printf "  🏠 ${UI_COLORS[accent]}${UI_COLORS[bold]}[4]${UI_COLORS[reset]}  ${UI_COLORS[info]}Install AUR Packages${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Packages from Arch User Repository${UI_COLORS[reset]}\n"
        echo
        
        printf "  📱 ${UI_COLORS[accent]}${UI_COLORS[bold]}[5]${UI_COLORS[reset]}  ${UI_COLORS[info]}Install Flatpak Apps${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Applications from Flathub${UI_COLORS[reset]}\n"
        echo
        
        printf "  ⚙️  ${UI_COLORS[accent]}${UI_COLORS[bold]}[6]${UI_COLORS[reset]}  ${UI_COLORS[info]}Custom Package Installation${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Install specific packages by name${UI_COLORS[reset]}\n"
        echo
        
        printf "  ${UI_ICONS[exit]} ${UI_COLORS[error]}${UI_COLORS[bold]}[0]${UI_COLORS[reset]}  ${UI_COLORS[info]}Return to Package Menu${UI_COLORS[reset]}\n"
        echo
        
        display_module_footer "Choose installation type [0-6]"
        
        local choice
        choice=$(read_single_key)
        echo "$choice"
        echo
        
        case "$choice" in
            1) install_package_list "pacman" ;;
            2) install_package_list "dev" ;;
            3) install_package_list "multimedia" ;;
            4) install_package_list "aur" ;;
            5) install_flatpak_apps_interactive ;;
            6) install_custom_package ;;
            0) return 0 ;;
            *) show_notification "Invalid choice: $choice" "error"; sleep 1 ;;
        esac
    done
}

manage_package_search() {
    while true; do
        display_module_header "PACKAGE SEARCH" "🔍"
        
        printf "  📦 ${UI_COLORS[accent]}${UI_COLORS[bold]}[1]${UI_COLORS[reset]}  ${UI_COLORS[info]}Search Pacman Repositories${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Search official Arch Linux repositories${UI_COLORS[reset]}\n"
        echo
        
        printf "  🏠 ${UI_COLORS[accent]}${UI_COLORS[bold]}[2]${UI_COLORS[reset]}  ${UI_COLORS[info]}Search AUR Packages${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Search Arch User Repository${UI_COLORS[reset]}\n"
        echo
        
        printf "  📱 ${UI_COLORS[accent]}${UI_COLORS[bold]}[3]${UI_COLORS[reset]}  ${UI_COLORS[info]}Search Flatpak Apps${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Search Flatpak applications${UI_COLORS[reset]}\n"
        echo
        
        printf "  📊 ${UI_COLORS[accent]}${UI_COLORS[bold]}[4]${UI_COLORS[reset]}  ${UI_COLORS[info]}Show Installed Packages${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}List currently installed packages${UI_COLORS[reset]}\n"
        echo
        
        printf "  ${UI_ICONS[exit]} ${UI_COLORS[error]}${UI_COLORS[bold]}[0]${UI_COLORS[reset]}  ${UI_COLORS[info]}Return to Package Menu${UI_COLORS[reset]}\n"
        echo
        
        display_module_footer "Choose search type [0-4]"
        
        local choice
        choice=$(read_single_key)
        echo "$choice"
        echo
        
        case "$choice" in
            1) search_pacman_packages ;;
            2) search_aur_packages ;;
            3) search_flatpak_apps ;;
            4) show_installed_packages ;;
            0) return 0 ;;
            *) show_notification "Invalid choice: $choice" "error"; sleep 1 ;;
        esac
    done
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
    display_module_header "SYSTEM INFORMATION" "📊"
    
    # System Information
    printf "${UI_COLORS[primary]}${UI_COLORS[bold]}╔══ System Details ══╗${UI_COLORS[reset]}\n"
    printf "${UI_COLORS[info]}Operating System: ${UI_COLORS[success]}$(uname -s)${UI_COLORS[reset]}\n"
    printf "${UI_COLORS[info]}Kernel Version:   ${UI_COLORS[success]}$(uname -r)${UI_COLORS[reset]}\n"
    printf "${UI_COLORS[info]}Architecture:     ${UI_COLORS[success]}$(uname -m)${UI_COLORS[reset]}\n"
    
    if [[ -f "/etc/os-release" ]]; then
        local distro_name distro_version
        distro_name=$(grep '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
        distro_version=$(grep '^VERSION=' /etc/os-release | cut -d= -f2 | tr -d '"' 2>/dev/null || echo "N/A")
        printf "${UI_COLORS[info]}Distribution:     ${UI_COLORS[success]}$distro_name${UI_COLORS[reset]}\n"
        printf "${UI_COLORS[info]}Version:          ${UI_COLORS[success]}$distro_version${UI_COLORS[reset]}\n"
    fi
    
    printf "${UI_COLORS[info]}Hostname:         ${UI_COLORS[success]}$(hostname)${UI_COLORS[reset]}\n"
    printf "${UI_COLORS[info]}Uptime:           ${UI_COLORS[success]}$(uptime -p 2>/dev/null || uptime | cut -d, -f1)${UI_COLORS[reset]}\n"
    echo
    
    # Hardware Information
    printf "${UI_COLORS[primary]}${UI_COLORS[bold]}╔══ Hardware Information ══╗${UI_COLORS[reset]}\n"
    
    # CPU Info
    if [[ -f "/proc/cpuinfo" ]]; then
        local cpu_model cpu_cores
        cpu_model=$(grep "model name" /proc/cpuinfo | head -n1 | cut -d: -f2 | sed 's/^ *//')
        cpu_cores=$(grep "processor" /proc/cpuinfo | wc -l)
        printf "${UI_COLORS[info]}CPU:              ${UI_COLORS[success]}$cpu_model${UI_COLORS[reset]}\n"
        printf "${UI_COLORS[info]}CPU Cores:        ${UI_COLORS[success]}$cpu_cores${UI_COLORS[reset]}\n"
    fi
    
    # Memory Info
    if command -v free >/dev/null 2>&1; then
        local mem_total mem_used mem_free
        mem_total=$(free -h | awk '/^Mem:/ {print $2}')
        mem_used=$(free -h | awk '/^Mem:/ {print $3}')
        mem_free=$(free -h | awk '/^Mem:/ {print $4}')
        printf "${UI_COLORS[info]}Memory Total:     ${UI_COLORS[success]}$mem_total${UI_COLORS[reset]}\n"
        printf "${UI_COLORS[info]}Memory Used:      ${UI_COLORS[warning]}$mem_used${UI_COLORS[reset]}\n"
        printf "${UI_COLORS[info]}Memory Free:      ${UI_COLORS[success]}$mem_free${UI_COLORS[reset]}\n"
    fi
    
    echo
    
    # Storage Information
    printf "${UI_COLORS[primary]}${UI_COLORS[bold]}╔══ Storage Information ══╗${UI_COLORS[reset]}\n"
    if command -v df >/dev/null 2>&1; then
        # Show main filesystem info
        local disk_info
        disk_info=$(df -h / 2>/dev/null | tail -n +2)
        if [[ -n "$disk_info" ]]; then
            local filesystem size used avail use_percent
            read -r filesystem size used avail use_percent _ <<< "$disk_info"
            printf "${UI_COLORS[info]}Root Filesystem:  ${UI_COLORS[success]}$filesystem${UI_COLORS[reset]}\n"
            printf "${UI_COLORS[info]}Total Size:       ${UI_COLORS[success]}$size${UI_COLORS[reset]}\n"
            printf "${UI_COLORS[info]}Used Space:       ${UI_COLORS[warning]}$used${UI_COLORS[reset]}\n"
            printf "${UI_COLORS[info]}Available:        ${UI_COLORS[success]}$avail${UI_COLORS[reset]}\n"
            printf "${UI_COLORS[info]}Usage:            ${UI_COLORS[warning]}$use_percent${UI_COLORS[reset]}\n"
        fi
    fi
    
    echo
    
    # Package Management
    printf "${UI_COLORS[primary]}${UI_COLORS[bold]}╔══ Package Management ══╗${UI_COLORS[reset]}\n"
    
    # Pacman info
    if command -v pacman >/dev/null 2>&1; then
        local installed_packages
        installed_packages=$(pacman -Q 2>/dev/null | wc -l)
        printf "${UI_COLORS[info]}Pacman Packages:  ${UI_COLORS[success]}$installed_packages installed${UI_COLORS[reset]}\n"
        
        # Check for updates
        local updates
        updates=$(pacman -Qu 2>/dev/null | wc -l)
        if [[ $updates -gt 0 ]]; then
            printf "${UI_COLORS[info]}Available Updates:${UI_COLORS[warning]} $updates updates available${UI_COLORS[reset]}\n"
        else
            printf "${UI_COLORS[info]}System Status:    ${UI_COLORS[success]}Up to date${UI_COLORS[reset]}\n"
        fi
    fi
    
    # Flatpak info
    if command -v flatpak >/dev/null 2>&1; then
        local flatpak_apps
        flatpak_apps=$(flatpak list 2>/dev/null | wc -l)
        printf "${UI_COLORS[info]}Flatpak Apps:     ${UI_COLORS[success]}$flatpak_apps installed${UI_COLORS[reset]}\n"
    fi
    
    echo
    
    # Application Information
    printf "${UI_COLORS[primary]}${UI_COLORS[bold]}╔══ Linux Manager Info ══╗${UI_COLORS[reset]}\n"
    printf "${UI_COLORS[info]}Application:      ${UI_COLORS[success]}${APP_NAME:-Linux Manager}${UI_COLORS[reset]}\n"
    printf "${UI_COLORS[info]}Version:          ${UI_COLORS[success]}${APP_VERSION:-2.0.0}${UI_COLORS[reset]}\n"
    printf "${UI_COLORS[info]}Architecture:     ${UI_COLORS[success]}${APP_ARCHITECTURE:-V2}${UI_COLORS[reset]}\n"
    if [[ -n "${STARTUP_TIME:-}" ]]; then
        printf "${UI_COLORS[info]}Started:          ${UI_COLORS[success]}$STARTUP_TIME${UI_COLORS[reset]}\n"
    fi
    if [[ -n "${STARTUP_DURATION:-}" && "$STARTUP_DURATION" != "0" ]]; then
        printf "${UI_COLORS[info]}Startup Time:     ${UI_COLORS[success]}${STARTUP_DURATION}ms${UI_COLORS[reset]}\n"
    fi
    
    echo
    display_module_footer "Press any key to return"
    read_single_key >/dev/null
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

# Configuration management using the config manager
manage_system_configuration() {
    if [[ "$CONFIG_MANAGER_AVAILABLE" == "true" ]]; then
        # Initialize config manager if not already done
        if ! declare -f "init_config_manager" >/dev/null 2>&1 || [[ "${CONFIG_SYSTEM_INITIALIZED:-false}" != "true" ]]; then
            if init_config_manager; then
                log_info "CONFIG" "Configuration manager initialized successfully"
            else
                show_notification "Failed to initialize configuration manager" "error"
                wait_for_user
                return 1
            fi
        fi
        
        # Use the configuration manager interface
        manage_configuration_interactive
    else
        show_notification "Configuration manager not available" "error"
        wait_for_user
    fi
}

# Interactive configuration management
manage_configuration_interactive() {
    while true; do
        display_module_header "CONFIGURATION MANAGEMENT" "⚙️"
        
        printf "  📋 ${UI_COLORS[accent]}${UI_COLORS[bold]}[1]${UI_COLORS[reset]}  ${UI_COLORS[info]}View Current Configuration${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Display all configuration values${UI_COLORS[reset]}\n"
        echo
        
        printf "  ✏️  ${UI_COLORS[accent]}${UI_COLORS[bold]}[2]${UI_COLORS[reset]}  ${UI_COLORS[info]}Edit Configuration${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Modify configuration settings${UI_COLORS[reset]}\n"
        echo
        
        printf "  💾 ${UI_COLORS[accent]}${UI_COLORS[bold]}[3]${UI_COLORS[reset]}  ${UI_COLORS[info]}Save Configuration${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Export current settings to file${UI_COLORS[reset]}\n"
        echo
        
        printf "  🔄 ${UI_COLORS[accent]}${UI_COLORS[bold]}[4]${UI_COLORS[reset]}  ${UI_COLORS[info]}Reset to Defaults${UI_COLORS[reset]}\n"
        printf "      ${UI_COLORS[dim]}Restore default configuration${UI_COLORS[reset]}\n"
        echo
        
        printf "  ${UI_ICONS[exit]} ${UI_COLORS[error]}${UI_COLORS[bold]}[0]${UI_COLORS[reset]}  ${UI_COLORS[info]}Return to System Menu${UI_COLORS[reset]}\n"
        echo
        
        display_module_footer "Choose option [0-4]"
        
        local choice
        choice=$(read_single_key)
        echo "$choice"
        echo
        
        case "$choice" in
            1) view_current_configuration ;;
            2) edit_configuration_interactive ;;
            3) save_configuration_interactive ;;
            4) reset_configuration_interactive ;;
            0) return 0 ;;
            *) show_notification "Invalid choice: $choice" "error"; sleep 1 ;;
        esac
    done
}

# View current configuration
view_current_configuration() {
    display_module_header "CURRENT CONFIGURATION" "📋"
    
    if declare -f "get_config" >/dev/null 2>&1; then
        # Display configuration by category
        local categories=("core" "ui" "performance" "packages" "development" "security")
        
        for category in "${categories[@]}"; do
            printf "${UI_COLORS[primary]}${UI_COLORS[bold]}${category^} Configuration:${UI_COLORS[reset]}\n"
            
            # Find all config keys for this category
            local found_any=false
            for key in "${!CONFIG_CATEGORIES[@]}"; do
                if [[ "${CONFIG_CATEGORIES[$key]}" == "$category" ]]; then
                    local value="${CONFIG_VALUES[$key]:-}"
                    local default="${CONFIG_DEFAULTS[$key]:-}"
                    local description="${CONFIG_DESCRIPTIONS[$key]:-}"
                    
                    if [[ "$value" == "$default" ]]; then
                        printf "  ${UI_COLORS[dim]}$key: ${UI_COLORS[info]}$value${UI_COLORS[reset]}\n"
                    else
                        printf "  ${UI_COLORS[accent]}$key: ${UI_COLORS[success]}$value${UI_COLORS[reset]} ${UI_COLORS[dim]}(default: $default)${UI_COLORS[reset]}\n"
                    fi
                    
                    if [[ -n "$description" ]]; then
                        printf "    ${UI_COLORS[dim]}$description${UI_COLORS[reset]}\n"
                    fi
                    echo
                    found_any=true
                fi
            done
            
            if [[ "$found_any" == "false" ]]; then
                printf "  ${UI_COLORS[dim]}No settings in this category${UI_COLORS[reset]}\n"
            fi
            echo
        done
    else
        show_notification "Configuration system not properly initialized" "error"
    fi
    
    wait_for_user
}

# Edit configuration interactively
edit_configuration_interactive() {
    show_notification "Interactive configuration editing coming soon!" "info"
    printf "${UI_COLORS[info]}Configuration can be manually edited in:${UI_COLORS[reset]}\n"
    printf "  ${UI_COLORS[accent]}User config: ${CONFIG_USER_DIR}/user.conf${UI_COLORS[reset]}\n"
    printf "  ${UI_COLORS[accent]}Override config: ${CONFIG_USER_DIR}/override.conf${UI_COLORS[reset]}\n"
    echo
    wait_for_user
}

# Save configuration interactively  
save_configuration_interactive() {
    display_module_header "SAVE CONFIGURATION" "💾"
    
    local config_file="${CONFIG_USER_DIR}/exported_config.conf"
    
    printf "${UI_COLORS[info]}This will export current configuration to:${UI_COLORS[reset]}\n"
    printf "${UI_COLORS[success]}$config_file${UI_COLORS[reset]}\n"
    echo
    
    if ui_confirm "Export configuration to this file?"; then
        # Create directory if needed
        mkdir -p "$(dirname "$config_file")"
        
        # Export configuration
        {
            echo "# Linux Manager V2 Configuration Export"
            echo "# Generated on $(date)"
            echo 
            
            for category in "core" "ui" "performance" "packages" "development" "security"; do
                echo "# ${category^} Configuration"
                
                for key in "${!CONFIG_CATEGORIES[@]}"; do
                    if [[ "${CONFIG_CATEGORIES[$key]}" == "$category" ]]; then
                        local value="${CONFIG_VALUES[$key]:-}"
                        local description="${CONFIG_DESCRIPTIONS[$key]:-}"
                        
                        if [[ -n "$description" ]]; then
                            echo "# $description"
                        fi
                        echo "$key=$value"
                        echo
                    fi
                done
            done
        } > "$config_file"
        
        if [[ $? -eq 0 ]]; then
            show_notification "Configuration exported successfully" "success"
        else
            show_notification "Failed to export configuration" "error"
        fi
    else
        show_notification "Export cancelled" "info"
    fi
    
    wait_for_user
}

# Reset configuration interactively
reset_configuration_interactive() {
    display_module_header "RESET CONFIGURATION" "🔄"
    
    printf "${UI_COLORS[warning]}This will reset all configuration to default values.${UI_COLORS[reset]}\n"
    printf "${UI_COLORS[warning]}Custom settings will be lost.${UI_COLORS[reset]}\n"
    echo
    
    if ui_confirm "Are you sure you want to reset to defaults?" "n"; then
        # Reset to defaults
        for key in "${!CONFIG_DEFAULTS[@]}"; do
            CONFIG_VALUES["$key"]="${CONFIG_DEFAULTS[$key]}"
        done
        
        show_notification "Configuration reset to defaults" "success"
        
        if ui_confirm "Save default configuration to user file?"; then
            local user_config="${CONFIG_USER_DIR}/user.conf"
            mkdir -p "$(dirname "$user_config")"
            
            {
                echo "# Linux Manager V2 User Configuration"
                echo "# Reset to defaults on $(date)"
                echo
                echo "# Uncomment and modify values as needed"
                
                for key in "${!CONFIG_DEFAULTS[@]}"; do
                    local value="${CONFIG_DEFAULTS[$key]}"
                    local description="${CONFIG_DESCRIPTIONS[$key]:-}"
                    
                    if [[ -n "$description" ]]; then
                        echo "# $description"
                    fi
                    echo "# $key=$value"
                    echo
                done
            } > "$user_config"
            
            show_notification "Default configuration saved to user file" "success"
        fi
    else
        show_notification "Reset cancelled" "info"
    fi
    
    wait_for_user
}

# Load V1 integration layer
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/v1_integration.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/v1_integration.sh"
    V1_INTEGRATION_AVAILABLE=true
else
    V1_INTEGRATION_AVAILABLE=false
fi

# Load configuration manager
if [[ -f "$(dirname "${BASH_SOURCE[0]}")/config_manager.sh" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/config_manager.sh"
    CONFIG_MANAGER_AVAILABLE=true
else
    CONFIG_MANAGER_AVAILABLE=false
fi

# Main V2 handlers called by the main script
handle_packages_v2() {
    # Try V1 integration first if available
    if [[ "$V1_INTEGRATION_AVAILABLE" == "true" ]] && declare -f "manage_packages_v1_integrated" >/dev/null 2>&1; then
        manage_packages_v1_integrated
    # Try to use the actual V2 packages module if available
    elif declare -f "manage_packages_v2" >/dev/null 2>&1; then
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
            printf "  ⚙️  ${UI_COLORS[accent]}${UI_COLORS[bold]}[8]${UI_COLORS[reset]}  ${UI_COLORS[info]}Configuration Management${UI_COLORS[reset]}\n"
            printf "  ${UI_ICONS[exit]} ${UI_COLORS[error]}${UI_COLORS[bold]}[0]${UI_COLORS[reset]}  ${UI_COLORS[info]}Return to Main Menu${UI_COLORS[reset]}\n"
            
            display_module_footer "Choose option [0-8]"
            
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
                8) manage_system_configuration ;;
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

# Export package installation helpers
export -f install_package_list install_packages_with_pacman install_packages_with_aur
export -f install_custom_package install_flatpak_apps_interactive

# Export main V2 handlers
export -f handle_packages_v2 handle_development_v2 handle_system_config_v2
