#!/bin/bash

# Test script to verify missing function fixes in Linux Manager V2
cd "$(dirname "$0")"

echo "Testing Linux Manager V2 - Missing Function Fixes"
echo "=================================================="
echo

# Source the V2 UI system to check if functions are available
if source src/core/v2/ui_system.sh 2>/dev/null; then
    echo "✅ V2 UI system loaded successfully"
else
    echo "❌ Failed to load V2 UI system"
    exit 1
fi

# Test essential UI functions
echo
echo "1. Testing essential UI functions..."

essential_functions=(
    "display_module_header"
    "display_module_footer" 
    "display_section_header"
    "show_notification"
    "show_progress"
    "read_single_key"
    "wait_for_user"
    "publish_event"
    "subscribe_to_event"
    "get_icon"
)

for func in "${essential_functions[@]}"; do
    if declare -f "$func" >/dev/null 2>&1; then
        echo "   ✅ $func"
    else
        echo "   ❌ $func MISSING"
    fi
done

# Test V1 compatibility functions
echo
echo "2. Testing V1 compatibility functions..."

v1_functions=(
    "print_boxed_message"
    "confirm_yn" 
    "get_user_choice"
    "show_spinner"
    "center_text"
    "wait_return_to_main"
    "print_fancy_header"
    "display_menu"
    "show_exit_message"
)

for func in "${v1_functions[@]}"; do
    if declare -f "$func" >/dev/null 2>&1; then
        echo "   ✅ $func"
    else
        echo "   ❌ $func MISSING"
    fi
done

# Test main V2 handlers
echo
echo "3. Testing main V2 handler functions..."

handler_functions=(
    "handle_packages_v2"
    "handle_development_v2"
    "handle_system_config_v2"
)

for func in "${handler_functions[@]}"; do
    if declare -f "$func" >/dev/null 2>&1; then
        echo "   ✅ $func"
    else
        echo "   ❌ $func MISSING"
    fi
done

# Test module management stubs
echo
echo "4. Testing module management function stubs..."

module_functions=(
    "manage_package_installation"
    "manage_package_search"
    "manage_package_removal"
    "show_package_statistics"
    "manage_package_settings"
)

for func in "${module_functions[@]}"; do
    if declare -f "$func" >/dev/null 2>&1; then
        echo "   ✅ $func"
    else
        echo "   ❌ $func MISSING"
    fi
done

# Test utility stubs
echo
echo "5. Testing utility function stubs..."

utility_functions=(
    "source_v1_modules"
    "init_package_cache"
    "log_performance"
    "get_timestamp_ms"
)

for func in "${utility_functions[@]}"; do
    if declare -f "$func" >/dev/null 2>&1; then
        echo "   ✅ $func"
    else
        echo "   ❌ $func MISSING"
    fi
done

echo
echo "🎉 Function availability test completed!"
echo "All essential functions should now be available to prevent 'command not found' errors."
echo
echo "Note: Functions marked as 'coming soon' are placeholder stubs that prevent"
echo "crashes but will show informational messages to users."
