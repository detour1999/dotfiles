# MCP Connected Servers Status Display Implementation Plan

> **For Claude:** Use `${SUPERPOWERS_SKILLS_ROOT}/skills/collaboration/executing-plans/SKILL.md` to implement this plan task-by-task.

**Goal:** Modify the status line script to display only MCP servers that are actively connected in the current Claude Code session, rather than all configured servers.

**Architecture:** The current script reads `~/.claude.json` to list all configured MCP servers. We need to determine which servers are actually connected in the session and filter the display accordingly. This requires research to find how Claude Code exposes connection information, followed by implementation to query and display only connected servers.

**Tech Stack:** bash, jq, Claude Code session context

---

## Task 1: Research MCP Connection Information Sources

**Files:**
- Investigate: Claude Code documentation and runtime environment
- Create: `tests/investigate-connection-data.sh`

**Step 1: Create investigation script to capture all available data**

Create a test script that captures all possible sources of connection information:

```bash
#!/usr/bin/env bash
# Investigation script to find MCP connection data

echo "=== Testing stdin JSON structure ==="
cat > /tmp/test-input.json <<EOF
{
  "session_id": "test-session",
  "workspace": {"current_dir": "$(pwd)"}
}
EOF

echo "Input JSON:"
cat /tmp/test-input.json

echo -e "\n=== Checking environment variables ==="
env | grep -i "claude\|mcp" || echo "No Claude/MCP env vars found"

echo -e "\n=== Checking for MCP-related files ==="
find ~/.claude* -type f -name "*mcp*" 2>/dev/null || echo "No MCP files found"

echo -e "\n=== Checking for running MCP processes ==="
ps aux | grep -i mcp | grep -v grep || echo "No MCP processes found"

echo -e "\n=== Checking Claude Code config structure ==="
if [ -f ~/.claude.json ]; then
    echo "Config file exists, checking structure:"
    jq 'keys' ~/.claude.json 2>/dev/null
fi
```

**Step 2: Run investigation script**

```bash
chmod +x tests/investigate-connection-data.sh
./tests/investigate-connection-data.sh > tests/investigation-results.txt 2>&1
cat tests/investigation-results.txt
```

Expected: Output showing all available data sources we can query

**Step 3: Document findings**

Create `tests/findings.md` documenting:
- Available data sources
- How to query connected servers
- Data format/structure
- Limitations

**Step 4: Commit investigation work**

```bash
git add tests/
git commit -m "research: investigate MCP connection data sources"
```

---

## Task 2: Create Test Framework for Connection Detection

**Files:**
- Create: `tests/test-mcp-status.sh`
- Modify: `mcp-status.sh` (prepare for testing)

**Step 1: Write failing test for connection detection**

Create test file:

```bash
#!/usr/bin/env bash
# Test suite for mcp-status.sh

source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Test 1: Should detect connected servers
test_connected_servers() {
    echo "Test: Detect connected servers"

    # Mock input with connected servers (based on research findings)
    # TODO: Update based on Task 1 findings
    input='{"session_id": "test", "workspace": {"current_dir": "'$(pwd)'"}}'

    result=$(echo "$input" | "$source_dir/mcp-status.sh")

    if echo "$result" | grep -q "MCP ("; then
        echo "✓ PASS: Shows MCP server count"
    else
        echo "✗ FAIL: Does not show MCP server count"
        return 1
    fi
}

# Test 2: Should show zero when no servers connected
test_no_connected_servers() {
    echo "Test: No connected servers"

    # Mock input with no connections
    input='{"session_id": "test", "workspace": {"current_dir": "'$(pwd)'"}}'

    result=$(echo "$input" | "$source_dir/mcp-status.sh")

    if echo "$result" | grep -q "No servers"; then
        echo "✓ PASS: Shows 'No servers' message"
    else
        echo "✗ FAIL: Does not show appropriate message"
        return 1
    fi
}

# Run all tests
echo "Running MCP Status Tests"
echo "========================"
test_connected_servers || exit 1
test_no_connected_servers || exit 1
echo "========================"
echo "All tests passed!"
```

**Step 2: Run test to verify it fails**

```bash
chmod +x tests/test-mcp-status.sh
./tests/test-mcp-status.sh
```

Expected: Tests fail because script still shows configured servers, not connected

**Step 3: Commit failing tests**

```bash
git add tests/test-mcp-status.sh
git commit -m "test: add failing tests for connected server detection"
```

---

## Task 3: Implement Connection Detection Function

**Files:**
- Modify: `mcp-status.sh:22-80`

**Step 1: Write function to detect connected servers**

Based on Task 1 findings, add new function after line 21:

```bash
# Function to get connected MCP servers for current session
get_connected_servers() {
    # TODO: Implementation depends on Task 1 research findings
    # Possible approaches:
    # 1. Parse session-specific connection file
    # 2. Query Claude Code API/CLI
    # 3. Check running processes
    # 4. Parse transcript or session data

    # Placeholder - replace with actual implementation
    local connected_servers=""

    # Extract session_id from input if available
    local session_id=$(echo "$input" | jq -r '.session_id // ""' 2>/dev/null)

    if [ -z "$session_id" ] || [ "$session_id" = "null" ]; then
        echo -e "${YELLOW}MCP: No session${RESET}"
        return
    fi

    # Check for connected servers
    # Implementation will be added based on research

    echo "$connected_servers"
}
```

**Step 2: Update main function to use connection detection**

Replace the `get_mcp_servers` function call at line 83:

```bash
# Main execution
get_connected_servers
```

**Step 3: Run tests**

```bash
./tests/test-mcp-status.sh
```

Expected: Tests still fail but with different error (detecting session, but no servers found)

**Step 4: Commit minimal implementation**

```bash
git add mcp-status.sh
git commit -m "feat: add connection detection skeleton"
```

---

## Task 4: Implement Actual Connection Query Logic

**Files:**
- Modify: `mcp-status.sh:23-50` (get_connected_servers function body)

**Step 1: Implement connection query based on research**

Update the get_connected_servers function with actual implementation:

```bash
get_connected_servers() {
    # Based on Task 1 findings - REPLACE THIS SECTION
    # Example implementation (actual approach depends on research):

    local session_id=$(echo "$input" | jq -r '.session_id // ""' 2>/dev/null)

    if [ -z "$session_id" ] || [ "$session_id" = "null" ]; then
        echo -e "${YELLOW}MCP: No session${RESET}"
        return
    fi

    # APPROACH A: If connection data is in transcript or session file
    local transcript_path=$(echo "$input" | jq -r '.transcript_path // ""' 2>/dev/null)
    if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
        # Parse transcript for MCP server connections
        connected_servers=$(grep -o "mcp__[a-zA-Z0-9_-]*" "$transcript_path" | \
                          sed 's/mcp__//' | \
                          sed 's/__[a-zA-Z0-9_-]*$//' | \
                          sort -u)
    fi

    # APPROACH B: If checking running processes
    # connected_servers=$(ps aux | grep "mcp.*server" | ...)

    # APPROACH C: If there's a Claude Code CLI command
    # connected_servers=$(claude-code mcp list --connected 2>/dev/null)

    # Count and format output
    local total=0
    local server_list=""

    while IFS= read -r server; do
        if [ -n "$server" ]; then
            total=$((total + 1))
            if [ -z "$server_list" ]; then
                server_list="${server}"
            else
                server_list="${server_list}, ${server}"
            fi
        fi
    done <<< "$connected_servers"

    if [ $total -eq 0 ]; then
        echo -e "${YELLOW}MCP: No connected${RESET}"
    else
        if [ ${#server_list} -gt 50 ]; then
            server_list="${server_list:0:47}..."
        fi
        echo -e "${GREEN}MCP (${total}):${RESET} ${server_list}"
    fi
}
```

**Step 2: Test with actual Claude Code session**

```bash
# Run within an actual Claude Code session to get real JSON
./mcp-status.sh < /dev/stdin
```

Expected: Should show only connected servers from current session

**Step 3: Run automated tests**

```bash
./tests/test-mcp-status.sh
```

Expected: All tests pass

**Step 4: Commit implementation**

```bash
git add mcp-status.sh
git commit -m "feat: query and display only connected MCP servers"
```

---

## Task 5: Add Comparison Mode (Optional Enhancement)

**Files:**
- Modify: `mcp-status.sh:23-90`

**Step 1: Write test for comparison display**

Add to `tests/test-mcp-status.sh`:

```bash
# Test 3: Should show connected vs configured count
test_comparison_display() {
    echo "Test: Comparison display"

    input='{"session_id": "test", "workspace": {"current_dir": "'$(pwd)'"}}'
    result=$(echo "$input" | "$source_dir/mcp-status.sh")

    # Should show format like "MCP: 2/5 connected"
    if echo "$result" | grep -qE "MCP.*[0-9]+/[0-9]+"; then
        echo "✓ PASS: Shows connected/configured comparison"
    else
        echo "✗ FAIL: Does not show comparison"
        return 1
    fi
}
```

**Step 2: Run test to verify it fails**

```bash
./tests/test-mcp-status.sh
```

Expected: New test fails

**Step 3: Implement comparison display**

Update output format in `get_connected_servers`:

```bash
# Get total configured servers
local config_file="$HOME/.claude.json"
local total_configured=0

if [ -f "$config_file" ] && command -v jq >/dev/null 2>&1; then
    total_configured=$(jq -r '[
        (if .mcpServers then .mcpServers | keys[] else empty end),
        (if .projects then .projects | to_entries | .[].value.mcpServers // {} | keys[] else empty end)
    ] | unique | length' "$config_file" 2>/dev/null)
fi

# Update output format
if [ $total -eq 0 ]; then
    echo -e "${YELLOW}MCP: 0/${total_configured} connected${RESET}"
else
    if [ ${#server_list} -gt 40 ]; then
        server_list="${server_list:0:37}..."
    fi
    echo -e "${GREEN}MCP: ${total}/${total_configured}${RESET} ${server_list}"
fi
```

**Step 4: Run tests**

```bash
./tests/test-mcp-status.sh
```

Expected: All tests pass

**Step 5: Commit enhancement**

```bash
git add mcp-status.sh tests/test-mcp-status.sh
git commit -m "feat: show connected vs configured server count"
```

---

## Task 6: Update Documentation

**Files:**
- Modify: `CLAUDE.md:24-40`

**Step 1: Update CLAUDE.md with new behavior**

Update the "mcp-status.sh" section:

```markdown
**mcp-status.sh:**
- Displays MCP (Model Context Protocol) servers actively connected in current session
- Shows connected vs total configured servers (e.g., "MCP: 2/5 connected")
- Reads session information from JSON stdin (session_id, transcript_path)
- Falls back to configured servers if connection data unavailable
- Requires `jq` for JSON parsing
- Uses ANSI color codes: GREEN for active connections, YELLOW for warnings
```

**Step 2: Add troubleshooting section**

Add new section to CLAUDE.md:

```markdown
## Troubleshooting

**MCP Status shows "No session":**
- Script is being run outside Claude Code session
- JSON input doesn't contain session_id

**MCP Status shows "No connected" but servers are configured:**
- Servers are configured but not connected to current session
- Check Claude Code MCP server logs for connection issues

**MCP Status shows all configured servers:**
- Fallback mode active (connection detection failed)
- Check that jq is installed and transcript_path is accessible
```

**Step 3: Commit documentation**

```bash
git add CLAUDE.md
git commit -m "docs: update for connected server detection"
```

---

## Task 7: Manual Testing and Validation

**Files:**
- Create: `tests/manual-test-checklist.md`

**Step 1: Create manual test checklist**

```markdown
# Manual Testing Checklist for MCP Connected Servers

## Setup
- [ ] Have at least 3 MCP servers configured in ~/.claude.json
- [ ] Start Claude Code session
- [ ] Connect to only 1-2 servers (not all)

## Test Cases

### Test 1: Connected servers display
- [ ] Run status line script
- [ ] Verify only connected servers are shown
- [ ] Verify count matches actual connections
- [ ] Verify format: "MCP: X/Y connected" where X < Y

### Test 2: No connections
- [ ] Start fresh session with no MCP servers connected
- [ ] Run status line script
- [ ] Verify shows "MCP: 0/Y connected"

### Test 3: All servers connected
- [ ] Connect to all configured MCP servers
- [ ] Run status line script
- [ ] Verify shows "MCP: Y/Y connected" with all server names

### Test 4: Fallback behavior
- [ ] Run script outside Claude Code session (no JSON input)
- [ ] Verify graceful fallback or clear error message

### Test 5: Color coding
- [ ] With connected servers, verify GREEN color
- [ ] With no connections, verify YELLOW color

## Validation
- [ ] Status line updates correctly as servers connect/disconnect
- [ ] No errors in Claude Code logs
- [ ] Performance is acceptable (< 100ms execution)
```

**Step 2: Execute manual tests**

Follow the checklist and document results in `tests/manual-test-results.md`

**Step 3: Fix any issues found**

Address failures discovered during manual testing

**Step 4: Commit final validation**

```bash
git add tests/
git commit -m "test: add manual testing checklist and results"
```

---

## Notes for Implementation

**Critical Dependencies:**
- Task 1 research findings will determine the implementation approach for Tasks 3-4
- The actual implementation in Tasks 3-4 must be updated based on what connection data is available
- If no connection data is available, discuss alternative approaches with user

**Fallback Strategy:**
- If connection detection is not possible, consider adding a flag to ~/.claude.json to manually mark active servers
- Alternative: Keep current behavior but add visual indicator that it shows "configured" not "connected"

**Testing Approach:**
- @skills/testing/test-driven-development/SKILL.md
- @skills/debugging/systematic-debugging/SKILL.md for troubleshooting

**Code Quality:**
- DRY: Reuse existing jq patterns and color codes
- YAGNI: Don't add features beyond connected server display
- Frequent commits after each passing test
