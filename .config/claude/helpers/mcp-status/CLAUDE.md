# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository contains custom status line scripts for Claude Code. These scripts are executed by Claude Code to display dynamic information in the status line interface.

## Architecture

**Status Line Script Protocol:**
- Scripts receive JSON input via stdin containing workspace information (current_dir, project_dir)
- Scripts output formatted text (with ANSI color codes) to stdout
- The output is displayed in Claude Code's status line

**mcp-status.sh:**
- Displays MCP (Model Context Protocol) servers actively connected in current session
- Shows connected vs total configured servers (e.g., "MCP: 2/5 connected")
- Reads session information from JSON stdin (session_id, transcript_path)
- Falls back to configured servers if connection data unavailable
- Requires `jq` for JSON parsing
- Uses ANSI color codes: GREEN for active connections, YELLOW for warnings

**Configuration Source:**
- Reads from `~/.claude.json`
- Parses `.mcpServers` (user-level) and `.projects[].mcpServers` (project-specific)

## Testing Scripts

To test the script manually:

```bash
# Basic test with empty input
echo '{}' | ./mcp-status.sh

# Test with current directory context
echo '{"workspace": {"current_dir": "'$(pwd)'"}}' | ./mcp-status.sh

# Direct execution (uses pwd)
./mcp-status.sh < /dev/null
```

## Dependencies

- `bash` - Shell interpreter
- `jq` - JSON command-line processor (required for parsing `~/.claude.json`)

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

## Script Modifications

When modifying status line scripts:
- Ensure output is concise (status lines have limited space)
- Use ANSI color codes sparingly for important status indicators
- Handle missing dependencies gracefully with informative fallback messages
- Test with various JSON input scenarios (empty, missing fields, etc.)
- Keep execution time minimal (scripts run frequently)
