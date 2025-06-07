#!/bin/bash

# Function to read a single character without requiring Enter key
# Usage: key=$(read_single_key)
read_single_key() {
    local key

    # Use stty to set terminal to raw mode
    if command -v stty >/dev/null 2>&1; then
        # Save current terminal settings
        local old_stty_cfg
        old_stty_cfg=$(stty -g)

        # Set terminal to raw mode (no echo, no canonical processing)
        stty raw -echo

        # Read exactly one character
        key=$(dd bs=1 count=1 2>/dev/null)

        # Restore terminal settings
        stty "$old_stty_cfg"

    # Fallback to read -n 1 with timeout
    else
        read -n 1 -t 30 key
    fi

    # Return ONLY the key without any echo
    printf "%s" "$key"
}

# Function to read a single character WITH prompt and visual feedback
# Usage: key=$(read_single_key_with_prompt "Enter choice: ")
read_single_key_with_prompt() {
    local prompt="$1"
    local key

    # Display the prompt if provided
    if [[ -n "$prompt" ]]; then
        echo -e -n "$prompt"
    fi

    # Get the key without any echo - DO NOT capture output from echo
    key=$(read_single_key)

    # Echo the character for visual feedback (but don't capture this output)
    echo -n "$key"
    echo  # Add newline

    # Return ONLY the key, not the prompt or any other output
    echo "$key"
}

# Function for yes/no confirmation that doesn't require Enter
# Returns 0 for yes, 1 for no
# Usage: confirm_yn "Do you want to proceed?" && echo "User selected yes" || echo "User selected no"
confirm_yn() {
    local prompt="$1"
    local default="${2:-y}"
    local yn_prompt

    # Tạo prompt với highlight cho option mặc định
    if [[ "$default" = "y" ]]; then
        yn_prompt="${LIGHT_GREEN}${BOLD}[Y]${NC}es/${LIGHT_RED}[n]${NC}o"
    else
        yn_prompt="${LIGHT_GREEN}[y]${NC}es/${LIGHT_RED}${BOLD}[N]${NC}o"
    fi

    # Hiển thị prompt với style tối giản
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"
    echo -e "    ${LIGHT_CYAN}${ICON_ARROW} ${WHITE}${prompt}${NC}"
    echo -e "    ${DARK_GRAY}│${NC}  ${yn_prompt}"
    echo -e "${DARK_GRAY}    ──────────────────────────────────────────────────────────────${NC}"

    # Lấy phím bấm và chuyển sang chữ thường
    local key
    key=$(read_single_key | tr '[:upper:]' '[:lower:]')

    # Giá trị mặc định nếu không có phím nào được bấm
    if [[ -z "$key" ]]; then
        key="$default"
    fi

    # Trả về kết quả (0=yes, 1=no)
    if [[ "$key" = "y" ]]; then
        return 0
    else
        return 1
    fi
}

# Function to center text in terminal
# Usage: center_text "My centered text"
center_text() {
    local text="$1"
    local terminal_width
    terminal_width=$(tput cols)
    local padding=$(( (terminal_width - ${#text}) / 2 ))

    printf "%${padding}s%s%${padding}s\n" "" "$text" ""
}

# Function to show animated spinner
# Usage: show_spinner "Loading..." 3
show_spinner() {
    local message="$1"
    local duration="${2:-2}"

    # Spinner characters with minimalist style
    local spinner=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local count=0
    local total_iterations=$((duration * 10))

    echo -e "${LIGHT_YELLOW}${ICON_GEAR} ${message}${NC}"

    while [ $count -lt $total_iterations ]; do
        for i in "${spinner[@]}"; do
            echo -ne "\r${LIGHT_CYAN}  ${i} ${WHITE}${DIM}Đang xử lý...${NC}"
            sleep 0.1
            ((count++))
            [ $count -ge $total_iterations ] && break
        done
    done

    echo -e "\r${GREEN}  ${ICON_CHECK} ${WHITE}Hoàn tất!${NC}                    "
    sleep 0.5
}

# Function to print boxed messages with different styles
# Usage: print_boxed_message "My message" "info|success|error|warning"
print_boxed_message() {
    local message="$1"
    local type="${2:-info}"
    local color icon

    case "$type" in
        "success")
            color="${GREEN}"
            icon="${ICON_CHECK}"
            ;;
        "error")
            color="${LIGHT_RED}"
            icon="${ICON_CROSS}"
            ;;
        "warning")
            color="${YELLOW}"
            icon="${ICON_WARNING}"
            ;;
        *)  # default is info
            color="${LIGHT_CYAN}"
            icon="${ICON_INFO}"
            ;;
    esac

    echo -e "${color}${icon} ${WHITE}${message}${NC}"
}
