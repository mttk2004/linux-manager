#!/bin/bash

# Simple test script to verify color output functions work
# This helps debug color escape sequence issues in fish shell

echo "Testing color output functions..."

# Source the UI system
source "$(dirname "$0")/src/core/v2/ui_system.sh" || {
    echo "Failed to source UI system"
    exit 1
}

echo "=== Testing basic color variables ==="
echo "Primary color test: ${UI_COLORS[primary]}This should be cyan${UI_COLORS[reset]}"
echo "Success color test: ${UI_COLORS[success]}This should be green${UI_COLORS[reset]}"
echo "Error color test: ${UI_COLORS[error]}This should be red${UI_COLORS[reset]}"

echo -e "\n=== Testing color_echo function ==="
color_echo "${UI_COLORS[primary]}This uses color_echo - cyan text${UI_COLORS[reset]}"
color_echo "${UI_COLORS[success]}This uses color_echo - green text${UI_COLORS[reset]}"
color_echo "${UI_COLORS[warning]}This uses color_echo - yellow text${UI_COLORS[reset]}"

echo -e "\n=== Testing color_printf function ==="
color_printf "${UI_COLORS[accent]}This uses color_printf - magenta text${UI_COLORS[reset]}\n"
color_printf "${UI_COLORS[info]}This uses color_printf - light gray text${UI_COLORS[reset]}\n"

echo -e "\n=== Testing ui_print_line function ==="
ui_print_line "─" 50 "${UI_COLORS[primary]}"

echo -e "\n=== Testing status messages ==="
ui_show_status "success" "Test success message"
ui_show_status "error" "Test error message"
ui_show_status "warning" "Test warning message"
ui_show_status "info" "Test info message"

echo -e "\n=== Environment Information ==="
echo "TERM: ${TERM:-not set}"
echo "COLORTERM: ${COLORTERM:-not set}"
echo "NO_COLOR: ${NO_COLOR:-not set}"
echo "FORCE_COLOR: ${FORCE_COLOR:-not set}"
echo "Shell: $0"
echo "Is terminal: $([[ -t 1 ]] && echo yes || echo no)"

echo -e "\nColor test completed!"
