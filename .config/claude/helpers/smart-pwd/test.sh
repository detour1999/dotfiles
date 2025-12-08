#!/usr/bin/env bash
# ABOUTME: Test suite for smart-pwd run.sh script
# ABOUTME: Tests all scenarios: git root, subdirs, worktrees, non-git paths

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUN_SCRIPT="$SCRIPT_DIR/run.sh"
TEST_DIR="/tmp/smart-pwd-test-$$"
PASSED=0
FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

setup() {
    rm -rf "$TEST_DIR"
    mkdir -p "$TEST_DIR"
    export TERMINAL_TITLE_EMOJI="💼"
    export HOME="/tmp/fake-home-$$"
    mkdir -p "$HOME"
}

teardown() {
    rm -rf "$TEST_DIR"
    rm -rf "$HOME"
}

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

test_git_root() {
    cd "$TEST_DIR"
    mkdir -p test-repo
    cd test-repo
    git init --quiet

    local output
    output=$(bash "$RUN_SCRIPT")
    assert_equals "💼 test-repo" "$output" "Git root directory"
}

test_git_subdirectory() {
    cd "$TEST_DIR/test-repo" || { echo "Failed to cd to $TEST_DIR/test-repo"; return 1; }
    mkdir -p src/components
    cd src/components

    local output
    output=$(bash "$RUN_SCRIPT")
    assert_equals "💼 test-repo/src/components" "$output" "Git subdirectory"
}

test_git_worktree_root() {
    cd "$TEST_DIR/test-repo"
    git worktree add --quiet .worktrees/feature-branch
    cd .worktrees/feature-branch

    local output
    output=$(bash "$RUN_SCRIPT")
    assert_equals "💼 - test-repo 🌳 - feature-branch" "$output" "Worktree root"
}

test_git_worktree_subdirectory() {
    cd "$TEST_DIR/test-repo/.worktrees/feature-branch"
    mkdir -p src/utils
    cd src/utils

    local output
    output=$(bash "$RUN_SCRIPT")
    assert_equals "💼 - test-repo 🌳 - feature-branch/src/utils" "$output" "Worktree subdirectory"
}

test_non_git_in_home() {
    mkdir -p "$HOME/projects/myapp"
    cd "$HOME/projects/myapp"

    local output
    output=$(bash "$RUN_SCRIPT")
    assert_equals "💼 projects/myapp" "$output" "Non-git directory in home"
}

test_non_git_outside_home() {
    mkdir -p "$TEST_DIR/random/path"
    cd "$TEST_DIR/random/path"

    local output
    output=$(bash "$RUN_SCRIPT")
    assert_equals "💼 $TEST_DIR/random/path" "$output" "Non-git directory outside home"
}

test_emoji_fallback_work_directory() {
    unset TERMINAL_TITLE_EMOJI
    mkdir -p /Users/dylanr/work/2389/test-emoji-project
    cd /Users/dylanr/work/2389/test-emoji-project
    git init --quiet

    local output
    output=$(bash "$RUN_SCRIPT")
    assert_equals "💼 test-emoji-project" "$output" "Work directory with emoji auto-detection"

    rm -rf /Users/dylanr/work/2389/test-emoji-project
}

test_emoji_fallback_personal_directory() {
    unset TERMINAL_TITLE_EMOJI
    mkdir -p /tmp/personal-project
    cd /tmp/personal-project
    git init --quiet

    local output
    output=$(bash "$RUN_SCRIPT")
    assert_equals "🎉 personal-project" "$output" "Personal directory with emoji auto-detection"

    rm -rf /tmp/personal-project
}

# Run all tests
echo "Running smart-pwd tests..."
echo

setup

test_git_root
test_git_subdirectory
test_git_worktree_root
test_git_worktree_subdirectory
test_non_git_in_home
test_non_git_outside_home

teardown

echo
echo "Testing emoji auto-detection fallback..."
echo

test_emoji_fallback_work_directory
test_emoji_fallback_personal_directory

echo
echo "================================"
echo -e "Tests passed: ${GREEN}$PASSED${NC}"
echo -e "Tests failed: ${RED}$FAILED${NC}"
echo "================================"

exit $FAILED
