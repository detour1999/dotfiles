# MCP Connection Data Investigation Findings

## Executive Summary

This investigation explored available data sources for detecting which MCP servers are actively connected in a Claude Code session. The findings reveal multiple potential approaches, with process-based detection being the most reliable method.

## Available Data Sources

### 1. Running Processes (PRIMARY METHOD)

**Location:** System process table via `ps` command

**Discovery:**
- MCP server processes are spawned as child processes of the main Claude app
- Each active MCP server runs as a distinct Node.js process
- Process hierarchy: Claude app (PID 49783) → npm exec processes → MCP server processes

**Example Process Tree:**
```
501 49783 Claude.app (main)
├── 501 70795 npm exec @modelcontextprotocol/server-filesystem
│   └── 501 70833 node mcp-server-filesystem
├── 501 70796 npm exec github:2389-research/mcp-socialmedia
│   └── 501 70942 node mcp-agent-social
└── 501 70797 npm exec github:2389-research/journal-mcp
    └── 501 70895 node private-journal-mcp
```

**Advantages:**
- Direct reflection of active connections
- Real-time status (process exists = server connected)
- No dependency on configuration files or Claude internals

**Limitations:**
- Requires parsing process table
- Process names may vary between MCP servers
- Need to filter out unrelated MCP processes from other Claude sessions

### 2. Environment Variables

**Location:** Shell environment

**Discovery:**
```
CLAUDE_CODE_ENTRYPOINT=cli
CLAUDECODE=1
```

**Analysis:**
- Only generic Claude Code environment markers present
- No session-specific or MCP connection information
- Cannot be used for connection detection

### 3. Configuration Files

**Location:** `~/.claude.json`

**Structure:**
```json
{
  "mcpServers": {
    "servername": {
      "type": "stdio",
      "command": "...",
      "args": [...],
      "env": {...}
    }
  },
  "projects": {
    "project-path": {
      "mcpServers": {...}
    }
  }
}
```

**Analysis:**
- Contains all CONFIGURED servers, not CONNECTED servers
- Current `mcp-status.sh` implementation uses this
- This is the problem we're trying to solve - shows all configured, not just connected

### 4. Session Input JSON

**Location:** stdin passed to status line scripts

**Discovery:**
```json
{
  "session_id": "test-session",
  "workspace": {
    "current_dir": "/path/to/dir"
  }
}
```

**Analysis:**
- Provides session context and workspace information
- Does NOT include MCP connection information
- Could potentially be enhanced by Claude Code in future

### 5. MCP-Related Files

**Location:** `~/.claude/` and `~/.npm/_npx/`

**Discovery:**
- No runtime connection state files found
- npx cache contains installed MCP servers but not connection status
- No transcript or session files accessible with connection data

## Recommended Implementation Approach

### Primary Method: Process-Based Detection

**Strategy:** Parse system processes to identify actively running MCP servers

**Algorithm:**
1. Get the Claude app main process PID (from environment or process table)
2. Find all child processes of the Claude app
3. Filter for processes that match MCP server patterns:
   - Command contains "mcp-server-", "mcp-agent-", "private-journal-mcp", etc.
   - Or: npm exec processes with known MCP package names
4. Extract server names from process command lines
5. Match against configured servers to normalize names

**Implementation Sketch:**
```bash
get_connected_servers() {
    # Find Claude app PID
    claude_pid=$(pgrep -f "Claude.app/Contents/MacOS/Claude" | head -1)

    if [ -z "$claude_pid" ]; then
        echo -e "${YELLOW}MCP: No session${RESET}"
        return
    fi

    # Find all child processes running MCP servers
    # NOTE: This is a simplified example - needs refinement using pstree or recursive discovery
    connected_servers=$(ps -eo pid,ppid,command | \
        awk -v parent="$claude_pid" '
            $2 == parent || found[$2] {
                found[$1]=1
                if ($0 ~ /mcp-server-|mcp-agent-|journal-mcp|socialmedia/) {
                    print $0
                }
            }
        ' | \
        sed -n 's/.*mcp-server-\([^ ]*\).*/\1/p; s/.*mcp-agent-\([^ ]*\).*/\1/p' | \
        sort -u)

    # Format output
    # ... (count and display logic)
}
```

### Alternative Method: Hybrid Approach

If process parsing proves fragile, implement a hybrid:
1. Read configured servers from `~/.claude.json`
2. Check if each server's process is running
3. Display only those with active processes

**Advantages:**
- More robust server name resolution
- Leverages existing config parsing logic
- Fallback to config-only display if process detection fails

## Data Format/Structure

### Process Command Line Patterns

MCP servers can be identified by these patterns in process command lines:

1. **npx-installed servers:**
   - Pattern: `node /Users/*/\.npm/_npx/*/node_modules/.bin/[server-name]`
   - Example: `node /Users/dylanr/.npm/_npx/a3241bba59c344f5/node_modules/.bin/mcp-server-filesystem`

2. **Direct Node.js servers:**
   - Pattern: `node /path/to/mcp-*/dist/index.js`
   - Example: `node /Users/dylanr/Dropbox (Personal)/work/2389/mcp-socialmedia/dist/index.js`

3. **npm exec launchers:**
   - Pattern: `npm exec [package-name]`
   - Example: `npm exec github:2389-research/mcp-socialmedia`

### Server Name Extraction

Mapping from process to configured server name requires:
1. Extract binary/script name from process command
2. Strip common prefixes: `mcp-server-`, `mcp-agent-`, etc.
3. Match against keys in `~/.claude.json` mcpServers
4. Handle special cases (custom paths, GitHub repos)

## Limitations and Considerations

### Current Limitations

1. **Process Parsing Fragility:**
   - Different MCP servers use different naming conventions
   - Process names may not directly match config names
   - Future MCP servers may use different patterns

2. **Multi-Session Ambiguity:**
   - Multiple Claude Code sessions may run simultaneously
   - Need to identify which processes belong to THIS session
   - Current approach assumes single Claude GUI session

   **Potential Solution:** Filter processes by checking if their parent chain includes the current shell's parent Claude process, or by examining process start times relative to session start. This would ensure we only detect MCP servers for the current session rather than all Claude sessions.

3. **No Official API:**
   - Claude Code doesn't expose connection state via API
   - Relying on implementation details (process tree)
   - May break with Claude Code updates

4. **Platform Dependency:**
   - Process parsing commands differ across OS (macOS/Linux/Windows)
   - Current investigation on macOS only
   - Will need platform-specific implementations

### Testing Considerations

1. **Test with real session:** Automated tests limited; need manual testing in Claude Code
2. **Edge cases to test:**
   - Zero servers connected
   - All servers connected
   - Servers connecting/disconnecting during display
   - Multiple Claude sessions running
3. **Fallback behavior:** Must gracefully degrade if detection fails

## Recommendations for Claude Code Team

If this implementation proves useful, consider adding to Claude Code:

1. **Session JSON enhancement:** Add `connected_mcp_servers` array to stdin JSON
2. **CLI command:** `claude mcp list --connected` to query active connections
3. **Session file:** Write connection state to `~/.claude/sessions/[session-id].json`

Any of these would make status line scripts more reliable and maintainable.

## Next Steps for Implementation

1. **Task 2:** Create test framework with mocked process output
2. **Task 3:** Implement process-based detection function
3. **Task 4:** Test with real Claude Code session
4. **Task 5:** Add fallback to config-based display if detection fails
5. **Task 6:** Document behavior and limitations

## Related Files

- Investigation script: `tests/investigate-connection-data.sh`
- Investigation output: `tests/investigation-results.txt`
- Current implementation: `mcp-status.sh`
