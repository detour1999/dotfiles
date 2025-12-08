#!/usr/bin/env bash
# ABOUTME: Test suite for mcp-status.sh to verify connected server detection
# ABOUTME: Validates that script shows only actively connected MCP servers

source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Test 1: Should detect and show connected servers
test_connected_servers() {
    echo "Test: Detect connected servers"

    # Mock input with valid session_id
    input='{"session_id": "test", "workspace": {"current_dir": "'$(pwd)'"}}'

    result=$(echo "$input" | "$source_dir/mcp-status.sh")

    if echo "$result" | grep -qE "MCP:"; then
        echo "✓ PASS: Shows MCP server count"
        echo "Result: $result"
    else
        echo "✗ FAIL: Does not show MCP server count"
        echo "Got: $result"
        return 1
    fi
}

# Test 2: Should show appropriate message based on connection state
test_connection_state() {
    echo "Test: Shows connection state"

    # Mock input with valid session
    input='{"session_id": "test", "workspace": {"current_dir": "'$(pwd)'"}}'

    result=$(echo "$input" | "$source_dir/mcp-status.sh")

    # Should show either connected servers with X/Y format, "connected" suffix, or "No Claude session"
    if echo "$result" | grep -qE "MCP: [0-9]+/[0-9]+|connected|No Claude session"; then
        echo "✓ PASS: Shows appropriate connection state"
        echo "Result: $result"
    else
        echo "✗ FAIL: Does not show connection state"
        echo "Got: $result"
        return 1
    fi
}

# Test 3: Should handle no Claude session gracefully
test_no_claude_session() {
    echo "Test: Handle no Claude session"

    # Create a temporary wrapper script that simulates pgrep failure
    local temp_script=$(mktemp)

    cat > "$temp_script" << 'WRAPPER_EOF'
#!/usr/bin/env bash

# Temporarily override pgrep to always fail for this test
pgrep() {
    return 1
}
export -f pgrep

# Source and run the actual script
WRAPPER_EOF

    # Append the contents of mcp-status.sh, excluding the shebang
    tail -n +2 "$source_dir/mcp-status.sh" >> "$temp_script"
    chmod +x "$temp_script"

    # Mock input
    input='{"session_id": "test", "workspace": {"current_dir": "'$(pwd)'"}}'

    result=$(echo "$input" | "$temp_script")

    # Cleanup
    rm -f "$temp_script"

    # Should show "No Claude session" message
    if echo "$result" | grep -q "No Claude session"; then
        echo "✓ PASS: Shows 'No Claude session' when pgrep fails"
        echo "Result: $result"
    else
        echo "✗ FAIL: Does not show 'No Claude session' message"
        echo "Got: $result"
        return 1
    fi
}

# Test 4: Should show connected vs configured count (comparison display)
test_comparison_display() {
    echo "Test: Comparison display format"

    # Mock input with valid session
    input='{"session_id": "test", "workspace": {"current_dir": "'$(pwd)'"}}'

    result=$(echo "$input" | "$source_dir/mcp-status.sh")

    # Should show format like "MCP: X/Y" or "MCP (X/Y):" where X is connected, Y is configured
    # Examples: "MCP: 2/5" or "MCP (2/5):" or "MCP: 0/5 No connected"
    if echo "$result" | grep -qE "MCP[: ]*[0-9]+/[0-9]+"; then
        echo "✓ PASS: Shows connected/configured comparison"
        echo "Result: $result"
    else
        echo "✗ FAIL: Does not show X/Y comparison format"
        echo "Got: $result"
        return 1
    fi
}

# Run all tests
echo "Running MCP Status Tests"
echo "========================"
test_connected_servers || exit 1
test_connection_state || exit 1
test_no_claude_session || exit 1
test_comparison_display || exit 1
echo "========================"
echo "All tests passed!"
