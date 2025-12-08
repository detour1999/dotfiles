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

### Test 6: Process detection accuracy
- [ ] Verify only Claude-related MCP processes are detected
- [ ] Verify no false positives from other applications

### Test 7: Server name extraction
- [ ] Verify server names are correctly extracted from process commands
- [ ] Test with various MCP server naming patterns:
  - [ ] @modelcontextprotocol/server-* format
  - [ ] npm exec format
  - [ ] private-journal-mcp format
  - [ ] mcp-server-* format

### Test 8: Performance
- [ ] Verify execution time is acceptable (< 200ms)
- [ ] Check that process tree walking doesn't cause delays

## Validation
- [ ] Status line updates correctly as servers connect/disconnect
- [ ] No errors in Claude Code logs
- [ ] Script handles edge cases gracefully
- [ ] Output is properly formatted and readable
