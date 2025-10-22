#!/usr/bin/env bash
# ABOUTME: Investigation script to discover MCP connection data sources
# ABOUTME: Explores all available data sources (processes, env vars, files, config) for detecting active MCP connections

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
