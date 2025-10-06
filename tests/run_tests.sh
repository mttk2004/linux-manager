#!/bin/bash

# Test Runner Script for Linux Manager - V2 Architecture
# Provides easy access to run all tests or specific test types

# Set up paths
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$TEST_DIR/.." && pwd)"
FRAMEWORK_DIR="$TEST_DIR/framework"

# Test runner configuration
TEST_VERBOSE=${TEST_VERBOSE:-false}
TEST_PARALLEL=${TEST_PARALLEL:-false}
TEST_COVERAGE=${TEST_COVERAGE:-false}
TEST_OUTPUT_FORMAT=${TEST_OUTPUT_FORMAT:-detailed}

# Color codes
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    WHITE='\033[1;37m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    WHITE=''
    BOLD=''
    NC=''
fi

# Print usage information
print_usage() {
    echo -e "${WHITE}${BOLD}Linux Manager Test Runner${NC}"
    echo -e "${BOLD}Usage:${NC} $0 [OPTIONS] [TEST_TYPE] [PATTERN]"
    echo
    echo -e "${BOLD}Test Types:${NC}"
    echo "  unit         Run unit tests only"
    echo "  integration  Run integration tests only"
    echo "  all          Run all tests (default)"
    echo "  FILE         Run specific test file"
    echo
    echo -e "${BOLD}Options:${NC}"
    echo "  -v, --verbose    Enable verbose output"
    echo "  -p, --parallel   Enable parallel test execution"
    echo "  -c, --coverage   Enable test coverage reporting"
    echo "  -f, --format     Output format (detailed, minimal, json)"
    echo "  -h, --help       Show this help message"
    echo
    echo -e "${BOLD}Pattern:${NC}"
    echo "  Glob pattern to match test files (default: test_*.sh)"
    echo
    echo -e "${BOLD}Examples:${NC}"
    echo "  $0                                    # Run all tests"
    echo "  $0 unit                              # Run unit tests only"
    echo "  $0 -v integration                    # Run integration tests with verbose output"
    echo "  $0 unit test_config*                 # Run config-related unit tests"
    echo "  $0 tests/unit/test_config_manager.sh # Run specific test file"
    echo
    echo -e "${BOLD}Environment Variables:${NC}"
    echo "  TEST_VERBOSE=true      Enable verbose output"
    echo "  TEST_PARALLEL=true     Enable parallel execution"
    echo "  TEST_COVERAGE=true     Enable coverage reporting"
    echo "  ROOT_DIR=/path         Override root directory"
}

# Parse command line arguments
parse_arguments() {
    local test_type="all"
    local test_pattern="test_*.sh"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                TEST_VERBOSE=true
                shift
                ;;
            -p|--parallel)
                TEST_PARALLEL=true
                shift
                ;;
            -c|--coverage)
                TEST_COVERAGE=true
                shift
                ;;
            -f|--format)
                if [[ -n "$2" ]]; then
                    TEST_OUTPUT_FORMAT="$2"
                    shift 2
                else
                    echo -e "${RED}Error: --format requires a value${NC}" >&2
                    exit 1
                fi
                ;;
            -h|--help)
                print_usage
                exit 0
                ;;
            unit|integration|all)
                test_type="$1"
                shift
                ;;
            *.sh)
                # Specific test file
                test_type="$1"
                shift
                ;;
            test_*)
                # Pattern for test files
                test_pattern="$1"
                shift
                ;;
            *)
                echo -e "${RED}Unknown argument: $1${NC}" >&2
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    printf "%s\n%s\n" "$test_type" "$test_pattern"
}

# Check prerequisites
check_prerequisites() {
    # Check if we're in the right directory structure
    if [[ ! -d "$ROOT_DIR/src" ]]; then
        echo -e "${RED}Error: Could not find source directory. Make sure you're running from the correct location.${NC}" >&2
        exit 1
    fi
    
    # Check if test framework exists
    if [[ ! -f "$FRAMEWORK_DIR/test_runner.sh" ]]; then
        echo -e "${RED}Error: Test framework not found at $FRAMEWORK_DIR/test_runner.sh${NC}" >&2
        exit 1
    fi
    
    # Check for required tools
    local missing_tools=()
    
    if ! command -v mktemp >/dev/null 2>&1; then
        missing_tools+=("mktemp")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo -e "${RED}Error: Missing required tools: ${missing_tools[*]}${NC}" >&2
        exit 1
    fi
}

# Set up test environment
setup_test_environment() {
    echo -e "${CYAN}Setting up test environment...${NC}"
    
    # Export configuration for test framework
    export TEST_VERBOSE
    export TEST_PARALLEL
    export TEST_COVERAGE
    export TEST_OUTPUT_FORMAT
    export ROOT_DIR
    
    # Set testing environment variables
    export TESTING=true
    export ENVIRONMENT="testing"
    
    # Create temporary directories for testing
    export TEST_TEMP_BASE=$(mktemp -d -t "linux_manager_tests.XXXXXX")
    export TEST_CONFIG_DIR="$TEST_TEMP_BASE/config"
    export TEST_LOGS_DIR="$TEST_TEMP_BASE/logs"
    export TEST_CACHE_DIR="$TEST_TEMP_BASE/cache"
    
    mkdir -p "$TEST_CONFIG_DIR" "$TEST_LOGS_DIR" "$TEST_CACHE_DIR"
    
    # Log test environment info
    if [[ "$TEST_VERBOSE" == "true" ]]; then
        echo -e "${BLUE}Test Environment:${NC}"
        echo "  Root Directory: $ROOT_DIR"
        echo "  Test Directory: $TEST_DIR"
        echo "  Temp Directory: $TEST_TEMP_BASE"
        echo "  Test Verbose: $TEST_VERBOSE"
        echo "  Test Parallel: $TEST_PARALLEL"
        echo "  Test Coverage: $TEST_COVERAGE"
        echo
    fi
}

# Clean up test environment
cleanup_test_environment() {
    if [[ -n "${TEST_TEMP_BASE:-}" && -d "$TEST_TEMP_BASE" ]]; then
        echo -e "${CYAN}Cleaning up test environment...${NC}"
        rm -rf "$TEST_TEMP_BASE"
    fi
    
    # Reset environment variables
    unset TESTING
    unset ENVIRONMENT
    unset TEST_TEMP_BASE
    unset TEST_CONFIG_DIR
    unset TEST_LOGS_DIR
    unset TEST_CACHE_DIR
}

# Run tests with coverage if enabled
run_tests_with_coverage() {
    local test_type="$1"
    local test_pattern="$2"
    
    if [[ "$TEST_COVERAGE" == "true" ]]; then
        # Note: Bash doesn't have built-in coverage tools like other languages
        # This is a placeholder for future coverage implementation
        echo -e "${YELLOW}Coverage reporting is not yet implemented for Bash${NC}"
        echo -e "${YELLOW}Running tests without coverage...${NC}"
        echo
    fi
    
    # Run the actual tests
    bash "$FRAMEWORK_DIR/test_runner.sh" "$test_type" "$test_pattern"
    return $?
}

# Generate test report
generate_test_report() {
    local exit_code="$1"
    local results_dir="$TEST_DIR/results"
    
    if [[ -d "$results_dir" ]]; then
        local latest_results
        latest_results=$(find "$results_dir" -name "test_results_*.json" -type f -exec ls -t {} + | head -1)
        
        if [[ -n "$latest_results" && -f "$latest_results" ]]; then
            echo -e "${CYAN}Test results saved to: $latest_results${NC}"
            
            if [[ "$TEST_OUTPUT_FORMAT" == "json" ]]; then
                cat "$latest_results"
            fi
        fi
    fi
    
    # Print final status
    if [[ $exit_code -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}✅ All tests completed successfully!${NC}"
    else
        echo -e "${RED}${BOLD}❌ Some tests failed!${NC}"
    fi
    
    return $exit_code
}

# Signal handler for cleanup
cleanup_on_exit() {
    echo -e "${YELLOW}\nTest execution interrupted. Cleaning up...${NC}"
    cleanup_test_environment
    exit 130
}

# Main function
main() {
    # Set up signal handlers
    trap cleanup_on_exit INT TERM
    
    # Parse arguments
    local parse_result
    parse_result=$(parse_arguments "$@")
    local test_type
    local test_pattern
    test_type=$(echo "$parse_result" | head -n1)
    test_pattern=$(echo "$parse_result" | tail -n1)
    
    # Print header
    echo -e "${WHITE}${BOLD}════════════════════════════════════════════${NC}"
    echo -e "${WHITE}${BOLD}    Linux Manager Test Suite - V2           ${NC}"
    echo -e "${WHITE}${BOLD}════════════════════════════════════════════${NC}"
    echo
    
    # Check prerequisites
    check_prerequisites
    
    # Set up test environment
    setup_test_environment
    
    # Run tests
    echo -e "${CYAN}Running tests: $test_type${NC}"
    echo -e "${CYAN}Pattern: $test_pattern${NC}"
    echo
    
    local exit_code
    run_tests_with_coverage "$test_type" "$test_pattern"
    exit_code=$?
    
    # Generate report
    echo
    generate_test_report "$exit_code"
    
    # Clean up
    cleanup_test_environment
    
    # Exit with test result code
    exit $exit_code
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
