#!/bin/bash

echo "This is a test output"
printf "Testing printf output\n"
echo "Testing with explicit stdout redirection" >&1
echo "Testing with explicit stderr redirection" >&2

exit 0
