#!/bin/bash

# Simple test to verify our test framework works
echo "Starting simple test..."

# Check if test framework exists
if [[ -f "tests/framework/test_runner.sh" ]]; then
    echo "✅ Test framework found"
else
    echo "❌ Test framework not found"
    exit 1
fi

# Try to run the test framework directly
echo "Running test framework directly..."
if bash tests/framework/test_runner.sh unit test_*.sh 2>/dev/null; then
    echo "✅ Test framework executed"
else
    echo "❌ Test framework failed"
    exit 1
fi

echo "Simple test completed successfully!"
