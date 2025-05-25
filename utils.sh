#!/bin/bash

# Function to read a single character without requiring Enter key
# Usage: read_single_key "prompt message"
read_single_key() {
    local prompt="$1"
    local key

    # Display the prompt if provided
    if [[ -n "$prompt" ]]; then
        echo -e -n "$prompt"
    fi

    # Read a single character without requiring Enter
    if [ -t 0 ]; then  # Check if stdin is a terminal
        # Save current terminal settings
        local old_tty_settings
        old_tty_settings=$(stty -g)

        # Set terminal to raw mode (-echo: don't echo typed characters, -icanon: disable canonical mode)
        stty -echo -icanon

        # Read a single character
        key=$(dd bs=1 count=1 2>/dev/null)

        # Restore terminal settings
        stty "$old_tty_settings"

        # Echo the character for user feedback
        echo -e "$key"
    else
        # Fall back to standard read if not on a terminal (e.g. pipe)
        read -n 1 key
    fi

    # Return the character
    echo "$key"
}

# Function for yes/no confirmation that doesn't require Enter
# Returns 0 for yes, 1 for no
# Usage: confirm_yn "Do you want to proceed?" && echo "User selected yes" || echo "User selected no"
confirm_yn() {
    local prompt="$1"
    local default="${2:-y}"
    local yn_prompt

    # Create prompt with proper highlight for default option
    if [[ "$default" = "y" ]]; then
        yn_prompt="${DARK_GRAY}[${LIGHT_GREEN}Y${DARK_GRAY}/${LIGHT_RED}n${DARK_GRAY}]${NC}"
    else
        yn_prompt="${DARK_GRAY}[${LIGHT_GREEN}y${DARK_GRAY}/${LIGHT_RED}N${DARK_GRAY}]${NC}"
    fi

    # Full prompt with message
    local full_prompt="${prompt} ${yn_prompt}: "

    # Get the key press
    local key
    key=$(read_single_key "$full_prompt" | tr '[:upper:]' '[:lower:]')

    # Default value if nothing is pressed
    if [[ -z "$key" ]]; then
        key="$default"
    fi

    # Return result (0=success/yes, 1=failure/no)
    if [[ "$key" = "y" ]]; then
        echo -e "\n"
        return 0
    else
        echo -e "\n"
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

    # Spinner characters
    local spinner=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local count=0
    local total_iterations=$((duration * 10))

    echo -e "${LIGHT_YELLOW}${ICON_GEAR} ${message}${NC}"

    while [ $count -lt $total_iterations ]; do
        for i in "${spinner[@]}"; do
            echo -ne "\r${LIGHT_CYAN}${i} ${WHITE}Processing...${NC}"
            sleep 0.1
            ((count++))
            [ $count -ge $total_iterations ] && break
        done
    done
    echo -e "\r${GREEN}${ICON_CHECK} ${WHITE}Ready!${NC}                    "
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
            title="SUCCESS"
            ;;
        "error")
            color="${LIGHT_RED}"
            icon="${ICON_CROSS}"
            title="ERROR"
            ;;
        "warning")
            color="${YELLOW}"
            icon="${ICON_WARNING}"
            title="WARNING"
            ;;
        *)  # default is info
            color="${LIGHT_BLUE}"
            icon="${ICON_INFO}"
            title="INFO"
            ;;
    esac

    echo -e "\n${color}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${color}║  ${icon} ${WHITE}${BOLD}${title}:${NC} ${color}${message}${NC}                                                  ${color}║${NC}"
    echo -e "${color}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
}
