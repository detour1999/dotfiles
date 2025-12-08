#!/usr/bin/env bash
# ABOUTME: Test suite for get-emoji run.sh script
# ABOUTME: Tests work directory detection and emoji selection

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN_SCRIPT="$SCRIPT_DIR/run.sh"
PASSED=0
FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

assert_equals() {
    local expected="$1"
    local actual="$2"
    local test_name="$3"

    if [ "$expected" = "$actual" ]; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $test_name"
        echo "  Expected: $expected"
        echo "  Got:      $actual"
        ((FAILED++))
    fi
}

test_work_directory() {
    cd /Users/dylanr/work/2389
    local output
    output=$(bash "$RUN_SCRIPT")
    assert_equals "💼" "$output" "Work directory (2389)"
}

test_work_subdirectory() {
    mkdir -p /Users/dylanr/work/2389/test-project
    cd /Users/dylanr/work/2389/test-project
    local output
    output=$(bash "$RUN_SCRIPT")
    assert_equals "💼" "$output" "Work subdirectory"
    rm -rf /Users/dylanr/work/2389/test-project
}

test_home_directory() {
    cd /Users/dylanr
    local output
    output=$(bash "$RUN_SCRIPT")
    assert_equals "🎉" "$output" "Home directory"
}

test_tmp_directory() {
    cd /tmp
    local output
    output=$(bash "$RUN_SCRIPT")
    assert_equals "🎉" "$output" "Tmp directory"
}

test_personal_project() {
    mkdir -p /Users/dylanr/projects/personal
    cd /Users/dylanr/projects/personal
    local output
    output=$(bash "$RUN_SCRIPT")
    assert_equals "🎉" "$output" "Personal project directory"
    rm -rf /Users/dylanr/projects/personal
}

# Run all tests
echo "Running get-emoji tests..."
echo

test_work_directory
test_work_subdirectory
test_home_directory
test_tmp_directory
test_personal_project

echo
echo "================================"
echo -e "Tests passed: ${GREEN}$PASSED${NC}"
echo -e "Tests failed: ${RED}$FAILED${NC}"
echo "================================"

exit $FAILED
