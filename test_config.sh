#!/bin/bash

echo "Testing configuration loading step by step..."

# Set basic environment
export ROOT_DIR="/home/kiet/projects/linux-manager"
export LOGS_DIR="$ROOT_DIR/logs"
export MODULES_DIR="$ROOT_DIR/src/modules"
export CORE_DIR="$ROOT_DIR/src/core"

# Create logs directory if needed
mkdir -p "$LOGS_DIR"

echo "1. Testing config.sh loading..."
if [[ -f "$CORE_DIR/config.sh" ]]; then
    echo "   config.sh exists, attempting to source..."
    if source "$CORE_DIR/config.sh"; then
        echo "   ✓ config.sh loaded successfully"
    else
        echo "   ✗ Failed to source config.sh"
        exit 1
    fi
else
    echo "   ✗ config.sh not found at $CORE_DIR/config.sh"
    exit 1
fi

echo "2. Testing logging functions..."
if declare -f log_info >/dev/null 2>&1; then
    log_info "TEST" "Logging function works"
    echo "   ✓ log_info function available"
else
    echo "   ✗ log_info function not available"
fi

echo "3. Testing UI system loading..."
if [[ -f "$CORE_DIR/v2/ui_system.sh" ]]; then
    echo "   ui_system.sh exists, attempting to source..."
    if source "$CORE_DIR/v2/ui_system.sh"; then
        echo "   ✓ ui_system.sh loaded successfully"
    else
        echo "   ✗ Failed to source ui_system.sh"
        exit 1
    fi
else
    echo "   ✗ ui_system.sh not found"
    exit 1
fi

echo "4. Testing UI initialization..."
if declare -f init_ui_system >/dev/null 2>&1; then
    echo "   init_ui_system function available, testing..."
    if timeout 10 bash -c 'init_ui_system'; then
        echo "   ✓ UI system initialized successfully"
    else
        echo "   ✗ UI system initialization failed or timed out"
    fi
else
    echo "   ✗ init_ui_system function not available"
fi

echo "Configuration test completed!"
