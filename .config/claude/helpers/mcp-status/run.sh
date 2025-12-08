#!/usr/bin/env bash

# ABOUTME: MCP Server Status Display for Claude Code Status Line
# ABOUTME: This script checks MCP server configurations and displays their status

# Read JSON from stdin (Claude Code passes this)
# Note: Currently used for extracting workspace directory. Reserved for future enhancement
# where we may need to compare against session_id or other metadata for filtering.
input=$(cat)

# Extract current directory from stdin if available
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .workspace.project_dir // ""' 2>/dev/null)
if [ -z "$current_dir" ] || [ "$current_dir" = "null" ]; then
    current_dir=$(pwd)
fi

# Color codes for better visibility
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Function to get connected MCP servers for current session
get_connected_servers() {
    # Find Claude app main process PID
    # Look for the main Claude.app process on macOS
    local claude_pid=$(pgrep -f "Claude.app/Contents/MacOS/Claude" 2>/dev/null | head -1)

    if [ -z "$claude_pid" ]; then
        echo -e "${YELLOW}MCP: No Claude session${RESET}"
        return
    fi

    # Find all processes that might be MCP servers
    # Strategy: Look for node processes running MCP-related executables that are
    # descendants of the Claude process (verify parent-child relationship)
    # Patterns to match:
    # - mcp-server-*
    # - mcp-agent-*
    # - private-journal-mcp
    # - Commands with @modelcontextprotocol in path

    # First, get all descendant PIDs of Claude (children, grandchildren, etc.)
    local claude_descendants=$(pstree -p "$claude_pid" 2>/dev/null | \
        grep -o '([0-9]*)' | \
        tr -d '()')

    # If pstree is not available, fall back to manual tree walk
    if [ -z "$claude_descendants" ]; then
        # Get all processes with their PIDs and PPIDs
        local all_procs=$(ps -eo pid,ppid 2>/dev/null)

        # Start with Claude PID
        local pids_to_check="$claude_pid"
        claude_descendants="$claude_pid"

        # Iteratively find all descendants
        while [ -n "$pids_to_check" ]; do
            local new_pids=""
            for pid in $pids_to_check; do
                # Find children of this PID
                local children=$(echo "$all_procs" | awk -v ppid="$pid" '$2 == ppid {print $1}')
                if [ -n "$children" ]; then
                    new_pids="$new_pids $children"
                    claude_descendants="$claude_descendants $children"
                fi
            done
            pids_to_check="$new_pids"
        done
    fi

    # Now find MCP servers that are in the descendant list
    local connected_servers=$(ps -eo pid,command 2>/dev/null | \
        grep -E 'node.*mcp-server-|node.*mcp-agent-|node.*private-journal-mcp|node.*@modelcontextprotocol|npm exec.*mcp' | \
        grep -v grep | \
        while read -r pid cmd; do
            # Check if this PID is a descendant of Claude
            if echo "$claude_descendants" | grep -qw "$pid"; then
                echo "$cmd"
            fi
        done | \
        sed -n 's/.*mcp-server-\([a-zA-Z0-9_-]*\).*/\1/p;
                s/.*mcp-agent-\([a-zA-Z0-9_-]*\).*/\1/p;
                s/.*private-journal-mcp.*/private-journal/p;
                s/.*@modelcontextprotocol\/server-\([a-zA-Z0-9_-]*\).*/\1/p' | \
        sort -u)

    # Alternative: extract from npm exec commands (also verify descendant relationship)
    if [ -z "$connected_servers" ]; then
        connected_servers=$(ps -eo pid,command 2>/dev/null | \
            grep "npm exec" | \
            grep -v grep | \
            while read -r pid cmd; do
                # Check if this PID is a descendant of Claude
                if echo "$claude_descendants" | grep -qw "$pid"; then
                    echo "$cmd"
                fi
            done | \
            sed -n 's/.*exec @modelcontextprotocol\/server-\([a-zA-Z0-9_-]*\).*/\1/p;
                    s/.*exec github:[^/]*\/mcp-\([a-zA-Z0-9_-]*\).*/\1/p' | \
            sort -u)
    fi

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

    # Get total configured servers for comparison display
    local config_file="$HOME/.claude.json"
    local total_configured=0

    if [ -f "$config_file" ] && command -v jq >/dev/null 2>&1; then
        total_configured=$(jq -r '[
            (if .mcpServers then .mcpServers | keys[] else empty end),
            (if .projects then .projects | to_entries | .[].value.mcpServers // {} | keys[] else empty end)
        ] | unique | length' "$config_file" 2>/dev/null)
    fi

    # Output result with comparison format
    if [ $total -eq 0 ]; then
        echo -e "${YELLOW}MCP: 0/${total_configured} connected${RESET}"
    else
        # Truncate server list if too long
        if [ ${#server_list} -gt 40 ]; then
            server_list="${server_list:0:37}..."
        fi
        echo -e "${GREEN}MCP: ${total}/${total_configured}${RESET} ${server_list}"
    fi
}

# Function to get MCP servers from config
get_mcp_servers() {
    local config_file="$HOME/.claude.json"
    local total=0
    local server_list=""
    
    # Check if config file exists
    if [ ! -f "$config_file" ]; then
        echo -e "${YELLOW}MCP: No config${RESET}"
        return
    fi
    
    # Check if jq is available
    if ! command -v jq >/dev/null 2>&1; then
        echo -e "${YELLOW}MCP: jq required${RESET}"
        return
    fi
    
    # Extract all unique MCP servers from both user-level and all projects
    local servers=$(jq -r --arg pwd "$current_dir" '
        # Collect all server names from different sources
        [
            # User-level mcpServers
            (if .mcpServers then .mcpServers | keys[] else empty end),
            # All project-specific mcpServers
            (if .projects then .projects | to_entries | .[].value.mcpServers // {} | keys[] else empty end)
        ] | unique | .[]
    ' "$config_file" 2>/dev/null)
    
    if [ -z "$servers" ]; then
        echo -e "${YELLOW}MCP: No servers${RESET}"
        return
    fi
    
    # Count and list servers
    while IFS= read -r server; do
        if [ -n "$server" ]; then
            total=$((total + 1))
            
            # Add to list
            if [ -z "$server_list" ]; then
                server_list="${server}"
            else
                server_list="${server_list}, ${server}"
            fi
        fi
    done <<< "$servers"
    
    # Output the result
    if [ $total -eq 0 ]; then
        echo -e "${YELLOW}MCP: No servers${RESET}"
    else
        # Truncate server list if too long
        if [ ${#server_list} -gt 50 ]; then
            server_list="${server_list:0:47}..."
        fi
        echo -e "${GREEN}MCP (${total}):${RESET} ${server_list}"
    fi
}

# Main execution
get_connected_servers
