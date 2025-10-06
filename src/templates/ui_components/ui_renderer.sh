#!/bin/bash

# UI Template Renderer - V2 Architecture
# Provides reusable UI components and templates to eliminate code duplication

# UI Configuration
UI_THEME=${UI_THEME:-default}
UI_WIDTH=${UI_WIDTH:-80}
UI_ANIMATION_ENABLED=${UI_ANIMATION_ENABLED:-true}

# Color definitions (load from existing ui.sh for compatibility)
if [[ -z "${LIGHT_CYAN:-}" ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    WHITE='\033[1;37m'
    GRAY='\033[0;37m'
    DARK_GRAY='\033[1;30m'
    LIGHT_BLUE='\033[1;34m'
    LIGHT_GREEN='\033[1;32m'
    LIGHT_RED='\033[1;31m'
    LIGHT_YELLOW='\033[1;33m'
    LIGHT_MAGENTA='\033[1;35m'
    LIGHT_CYAN='\033[1;36m'
    BOLD='\033[1m'
    DIM='\033[2m'
    UNDERLINE='\033[4m'
    NC='\033[0m'
fi

# Icon definitions (enhanced set)
declare -A ICONS=(
    [CHECK]="✓"
    [CROSS]="✗"
    [INFO]="ℹ"
    [WARNING]="⚠"
    [ARROW]="➤"
    [STAR]="★"
    [GEAR]="⚙"
    [ROCKET]="🚀"
    [PACKAGE]="📦"
    [CONFIG]="⚙️"
    [PHP]="🐘"
    [NODE]="🟢"
    [EXIT]="🚪"
    [CLEAN]="🧹"
    [ORPHAN]="🧩"
    [CACHE]="💾"
    [FOREIGN]="🧭"
    [MANUAL]="📋"
    [AUTO]="🔥"
    [FOLDER]="📁"
    [FILE]="📄"
    [SEARCH]="🔍"
    [SPINNER]="⠋"
)

# Template cache
declare -A TEMPLATE_CACHE=()

# Initialize UI renderer
init_ui_renderer() {
    # Set terminal width dynamically
    if command -v tput >/dev/null 2>&1; then
        UI_WIDTH=$(tput cols)
    fi
    
    # Load theme-specific settings
    load_ui_theme "$UI_THEME"
    
    log_debug "UI_RENDERER" "UI renderer initialized with theme: $UI_THEME, width: $UI_WIDTH"
}

# Load UI theme
load_ui_theme() {
    local theme_name="$1"
    local theme_file="$TEMPLATES_DIR/themes/${theme_name}.theme"
    
    if [[ -f "$theme_file" ]]; then
        source "$theme_file"
        log_debug "UI_RENDERER" "Loaded theme: $theme_name"
    else
        log_debug "UI_RENDERER" "Theme file not found, using defaults: $theme_name"
    fi
}

# Get icon with fallback
get_icon() {
    local icon_name="$1"
    echo "${ICONS[$icon_name]:-$icon_name}"
}

# Create horizontal line/separator
create_separator() {
    local char="${1:-─}"
    local width="${2:-$UI_WIDTH}"
    local color="${3:-$DARK_GRAY}"
    
    printf "${color}"
    printf "%*s" "$width" | tr ' ' "$char"
    printf "${NC}\n"
}

# Create centered text
create_centered_text() {
    local text="$1"
    local width="${2:-$UI_WIDTH}"
    local color="${3:-$WHITE}"
    
    # Remove ANSI codes for length calculation
    local clean_text="${text//\\033\[[0-9;]*m/}"
    local text_length=${#clean_text}
    local padding=$(( (width - text_length) / 2 ))
    
    printf "%*s${color}%s${NC}%*s\n" "$padding" "" "$text" "$padding" ""
}

# Create padded text
create_padded_text() {
    local text="$1"
    local total_width="${2:-$UI_WIDTH}"
    local left_padding="${3:-4}"
    local color="${4:-$WHITE}"
    
    local content_width=$((total_width - left_padding))
    printf "%*s${color}%s${NC}\n" "$left_padding" "" "$text"
}

# Render ASCII art header with caching
render_ascii_header() {
    local header_id="$1"
    local title="${2:-}"
    local color="${3:-$LIGHT_CYAN}"
    
    # Check cache first
    if [[ -n "${TEMPLATE_CACHE[$header_id]:-}" ]]; then
        echo -e "${color}${TEMPLATE_CACHE[$header_id]}${NC}"
        if [[ -n "$title" ]]; then
            create_centered_text "$title" "$UI_WIDTH" "$WHITE$BOLD"
        fi
        return 0
    fi
    
    local ascii_content=""
    case "$header_id" in
        "main")
            ascii_content="    ██╗  ██╗██╗███████╗████████╗███████╗    ██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗
    ██║ ██╔╝██║██╔════╝╚══██╔══╝██╔════╝    ██║     ██║████╗  ██║██║   ██║╚██╗██╔╝
    █████╔╝ ██║█████╗     ██║   ███████╗    ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝ 
    ██╔═██╗ ██║██╔══╝     ██║   ╚════██║    ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗ 
    ██║  ██╗██║███████╗   ██║   ███████║    ███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗
    ╚═╝  ╚═╝╚═╝╚══════╝   ╚═╝   ╚══════╝    ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝"
            ;;
        "package")
            ascii_content="    ██████╗  █████╗  ██████╗██╗  ██╗ █████╗  ██████╗ ███████╗
    ██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔════╝ ██╔════╝
    ██████╔╝███████║██║     █████╔╝ ███████║██║  ███╗█████╗  
    ██╔═══╝ ██╔══██║██║     ██╔═██╗ ██╔══██║██║   ██║██╔══╝  
    ██║     ██║  ██║╚██████╗██║  ██╗██║  ██║╚██████╔╝███████╗
    ╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
            ;;
        "system")
            ascii_content="    ███████╗██╗   ██╗███████╗████████╗███████╗███╗   ███╗
    ██╔════╝╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔════╝████╗ ████║
    ███████╗ ╚████╔╝ ███████╗   ██║   █████╗  ██╔████╔██║
    ╚════██║  ╚██╔╝  ╚════██║   ██║   ██╔══╝  ██║╚██╔╝██║
    ███████║   ██║   ███████║   ██║   ███████╗██║ ╚═╝ ██║
    ╚══════╝   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝╚═╝     ╚═╝"
            ;;
        "cleanup")
            ascii_content="    ██████╗ ██╗      ███████╗ █████╗ ███╗   ██╗██╗   ██╗██████╗ 
    ██╔════╝██║      ██╔════╝██╔══██╗████╗  ██║██║   ██║██╔══██╗
    ██║     ██║      █████╗  ███████║██╔██╗ ██║██║   ██║██████╔╝
    ██║     ██║      ██╔══╝  ██╔══██║██║╚██╗██║██║   ██║██╔═══╝ 
    ╚██████╗███████╗ ███████╗██║  ██║██║ ╚████║╚██████╔╝██║     
     ╚═════╝╚══════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝"
            ;;
        "php")
            ascii_content="    ██████╗ ██╗  ██╗██████╗     ███╗   ███╗ █████╗ ███╗   ██╗ █████╗  ██████╗ ███████╗██████╗ 
    ██╔══██╗██║  ██║██╔══██╗    ████╗ ████║██╔══██╗████╗  ██║██╔══██╗██╔════╝ ██╔════╝██╔══██╗
    ██████╔╝███████║██████╔╝    ██╔████╔██║███████║██╔██╗ ██║███████║██║  ███╗█████╗  ██████╔╝
    ██╔═══╝ ██╔══██║██╔═══╝     ██║╚██╔╝██║██╔══██║██║╚██╗██║██╔══██║██║   ██║██╔══╝  ██╔══██╗
    ██║     ██║  ██║██║         ██║ ╚═╝ ██║██║  ██║██║ ╚████║██║  ██║╚██████╔╝███████╗██║  ██║
    ╚═╝     ╚═╝  ╚═╝╚═╝         ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝"
            ;;
        *)
            ascii_content="    ██╗     ██╗███╗   ██╗██╗   ██╗██╗  ██╗
    ██║     ██║████╗  ██║██║   ██║╚██╗██╔╝
    ██║     ██║██╔██╗ ██║██║   ██║ ╚███╔╝ 
    ██║     ██║██║╚██╗██║██║   ██║ ██╔██╗ 
    ███████╗██║██║ ╚████║╚██████╔╝██╔╝ ██╗
    ╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝"
            ;;
    esac
    
    # Cache the ASCII art
    TEMPLATE_CACHE["$header_id"]="$ascii_content"
    
    # Render with color
    echo -e "${color}${ascii_content}${NC}"
    
    if [[ -n "$title" ]]; then
        echo
        create_centered_text "$title" "$UI_WIDTH" "$WHITE$BOLD"
    fi
}

# Render menu header with separator
render_menu_header() {
    local title="$1"
    local icon="${2:-$(get_icon CONFIG)}"
    local color="${3:-$WHITE}"
    
    echo
    create_separator "─" "$UI_WIDTH" "$DARK_GRAY"
    create_centered_text "$icon $BOLD$title$NC $icon" "$UI_WIDTH" "$color"
    create_separator "─" "$UI_WIDTH" "$DARK_GRAY"
    echo
}

# Render menu option
render_menu_option() {
    local number="$1"
    local title="$2"
    local description="$3"
    local icon="${4:-$(get_icon PACKAGE)}"
    local color="${5:-$GREEN}"
    
    echo -e "  $icon ${color}${BOLD}[$number]${NC}  ${WHITE}$title${NC}"
    if [[ -n "$description" ]]; then
        echo -e "      ${GRAY}${DIM}$description${NC}"
    fi
    echo
}

# Render menu footer
render_menu_footer() {
    local min_choice="${1:-1}"
    local max_choice="${2:-5}"
    
    create_separator "─" "$UI_WIDTH" "$DARK_GRAY"
    create_centered_text "$(get_icon INFO) ${WHITE}Chọn một tùy chọn từ ${LIGHT_GREEN}${BOLD}$min_choice-$max_choice${NC}${WHITE} và nhấn Enter${NC}" "$UI_WIDTH" "$LIGHT_CYAN"
    create_separator "─" "$UI_WIDTH" "$DARK_GRAY"
    echo
}

# Complete menu renderer
render_full_menu() {
    local config_array_name="$1" # Name of associative array variable
    
    # Get array reference (bash 4.3+ feature)
    declare -n menu_config="$config_array_name"
    
    clear
    
    # Render ASCII header if specified
    if [[ -n "${menu_config[ascii_header]:-}" ]]; then
        render_ascii_header "${menu_config[ascii_header]}" "${menu_config[title]:-}"
    fi
    
    # Render menu header
    render_menu_header "${menu_config[header]:-MENU}" "${menu_config[header_icon]:-}"
    
    # Render options
    local option_num=1
    while [[ -n "${menu_config[option_${option_num}_title]:-}" ]]; do
        render_menu_option \
            "$option_num" \
            "${menu_config[option_${option_num}_title]}" \
            "${menu_config[option_${option_num}_description]:-}" \
            "${menu_config[option_${option_num}_icon]:-}"
        ((option_num++))
    done
    
    # Render footer
    local max_option=$((option_num - 1))
    render_menu_footer "1" "$max_option"
}

# Render input prompt
render_input_prompt() {
    local prompt_text="$1"
    local range="${2:-}"
    local color="${3:-$LIGHT_CYAN}"
    
    local range_text=""
    if [[ -n "$range" ]]; then
        range_text=" ${DARK_GRAY}[${LIGHT_GREEN}${range}${DARK_GRAY}]${NC}"
    fi
    
    echo -e -n "${color}$(get_icon ARROW) ${WHITE}${BOLD}${prompt_text}${NC}${range_text}: "
}

# Render status message
render_status_message() {
    local message="$1"
    local type="${2:-info}" # info, success, error, warning
    local show_icon="${3:-true}"
    
    local color icon
    case "$type" in
        "success")
            color="$GREEN"
            icon="$(get_icon CHECK)"
            ;;
        "error")
            color="$LIGHT_RED" 
            icon="$(get_icon CROSS)"
            ;;
        "warning")
            color="$YELLOW"
            icon="$(get_icon WARNING)"
            ;;
        *)
            color="$LIGHT_CYAN"
            icon="$(get_icon INFO)"
            ;;
    esac
    
    if [[ "$show_icon" == "true" ]]; then
        echo -e "${color}${icon} ${WHITE}${message}${NC}"
    else
        echo -e "${color}${message}${NC}"
    fi
}

# Render progress indicator
render_progress() {
    local current="$1"
    local total="$2"
    local description="${3:-Processing}"
    local width="${4:-50}"
    
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    # Create progress bar
    local bar=""
    for ((i = 0; i < filled; i++)); do bar+="█"; done
    for ((i = 0; i < empty; i++)); do bar+="░"; done
    
    echo -ne "\r${LIGHT_CYAN}$(get_icon GEAR) ${WHITE}${description}: ${LIGHT_GREEN}[$bar] ${percentage}%${NC}"
    
    if [[ $current -eq $total ]]; then
        echo -e "\r${GREEN}$(get_icon CHECK) ${WHITE}${description}: Hoàn thành!${NC}                    "
    fi
}

# Render animated spinner
render_spinner() {
    local message="$1"
    local duration="${2:-2}"
    
    if [[ "$UI_ANIMATION_ENABLED" != "true" ]]; then
        echo -e "${LIGHT_CYAN}$(get_icon GEAR) ${message}...${NC}"
        sleep "$duration"
        return 0
    fi
    
    local spinner_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local count=0
    local max_iterations=$((duration * 10))
    
    echo -e "${LIGHT_YELLOW}$(get_icon GEAR) ${message}${NC}"
    
    while [[ $count -lt $max_iterations ]]; do
        for char in "${spinner_chars[@]}"; do
            echo -ne "\r${LIGHT_CYAN}  $char ${WHITE}${DIM}Đang xử lý...${NC}"
            sleep 0.1
            ((count++))
            [[ $count -ge $max_iterations ]] && break
        done
    done
    
    echo -e "\r${GREEN}  $(get_icon CHECK) ${WHITE}Hoàn tất!${NC}                    "
}

# Render confirmation dialog
render_confirmation() {
    local prompt="$1"
    local default="${2:-y}"
    
    local yn_prompt
    if [[ "$default" == "y" ]]; then
        yn_prompt="${LIGHT_GREEN}${BOLD}[Y]${NC}es/${LIGHT_RED}[n]${NC}o"
    else
        yn_prompt="${LIGHT_GREEN}[y]${NC}es/${LIGHT_RED}${BOLD}[N]${NC}o"
    fi
    
    create_separator "─" "$UI_WIDTH" "$DARK_GRAY"
    create_centered_text "$(get_icon ARROW) ${WHITE}${prompt}${NC}" "$UI_WIDTH" "$LIGHT_CYAN"
    create_centered_text "$yn_prompt" "$UI_WIDTH" ""
    create_separator "─" "$UI_WIDTH" "$DARK_GRAY"
}

# Export key functions  
export -f render_ascii_header render_menu_header render_menu_option render_menu_footer
export -f render_full_menu render_input_prompt render_status_message render_progress
export -f render_spinner render_confirmation get_icon
