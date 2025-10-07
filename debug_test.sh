#!/bin/bash

echo "DEBUG: Starting test script"

# Test basic variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)" 2>/dev/null || ROOT_DIR="$SCRIPT_DIR"
CORE_V2_DIR="$ROOT_DIR/src/core/v2"
LOGS_DIR="$ROOT_DIR/logs"

echo "DEBUG: SCRIPT_DIR = $SCRIPT_DIR"
echo "DEBUG: ROOT_DIR = $ROOT_DIR" 
echo "DEBUG: CORE_V2_DIR = $CORE_V2_DIR"
echo "DEBUG: LOGS_DIR = $LOGS_DIR"

# Test directory existence
echo "DEBUG: Checking directories..."
[[ -d "$CORE_V2_DIR" ]] && echo "DEBUG: CORE_V2_DIR exists" || echo "DEBUG: CORE_V2_DIR missing"
[[ -d "$LOGS_DIR" ]] && echo "DEBUG: LOGS_DIR exists" || echo "DEBUG: LOGS_DIR missing"

# Test logger file
LOGGER_FILE="$CORE_V2_DIR/logger.sh"
echo "DEBUG: Logger file: $LOGGER_FILE"
[[ -f "$LOGGER_FILE" ]] && echo "DEBUG: Logger file exists" || echo "DEBUG: Logger file missing"

# Try to source logger
if [[ -f "$LOGGER_FILE" ]]; then
    echo "DEBUG: Attempting to source logger..."
    if source "$LOGGER_FILE" 2>&1; then
        echo "DEBUG: Logger sourced successfully"
        if declare -f "init_logger" >/dev/null 2>&1; then
            echo "DEBUG: init_logger function found"
            mkdir -p "$LOGS_DIR"
            echo "DEBUG: Attempting to initialize logger..."
            if init_logger 2>&1; then
                echo "DEBUG: Logger initialized successfully"
            else
                echo "DEBUG: Logger initialization failed"
            fi
        else
            echo "DEBUG: init_logger function not found"
        fi
    else
        echo "DEBUG: Failed to source logger"
    fi
else
    echo "DEBUG: Logger file not found"
fi

echo "DEBUG: Test script completed"
