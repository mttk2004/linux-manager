#!/bin/bash

# Simple test script to verify the Linux Manager V2 fixes
cd "$(dirname "$0")"

echo "Testing Linux Manager V2 fixes..."
echo

# Test syntax errors
echo "1. Testing syntax errors..."
if bash -n bin/linux-manager-v2; then
    echo "   ✅ Main script syntax OK"
else
    echo "   ❌ Main script syntax ERROR"
    exit 1
fi

if bash -n src/core/v2/module_registry.sh; then
    echo "   ✅ Module registry syntax OK"
else
    echo "   ❌ Module registry syntax ERROR"
    exit 1
fi

if bash -n src/core/v2/config_manager.sh; then
    echo "   ✅ Config manager syntax OK"
else
    echo "   ❌ Config manager syntax ERROR"
    exit 1
fi

if bash -n src/modules/v2/packages/manager.sh; then
    echo "   ✅ Packages manager syntax OK"
else
    echo "   ❌ Packages manager syntax ERROR"
    exit 1
fi

echo
echo "2. Testing config key fixes..."

# Test that config keys don't contain dots (which cause arithmetic errors)
if grep -r "get_config.*\." src/modules/v2/ | grep -v "get_config.*\"[A-Z_]*\""; then
    echo "   ❌ Found config keys with dots that may cause arithmetic errors"
    exit 1
else
    echo "   ✅ No problematic config keys with dots found"
fi

echo
echo "3. Testing show_main_menu function exists..."

if grep -q "show_main_menu()" src/core/v2/ui_system.sh; then
    echo "   ✅ show_main_menu function exists in V2 UI system"
else
    echo "   ❌ show_main_menu function missing"
    exit 1
fi

echo
echo "🎉 All fixes verified successfully!"
echo "The application should now work without the previous errors."
