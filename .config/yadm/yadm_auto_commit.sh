#!/bin/bash

# Set up PATH for launchd
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Change to home directory
cd "$HOME"

# Check if there are any changes to tracked files
if yadm diff --quiet && yadm diff --cached --quiet; then
  echo "No changes to commit"
  exit 0
fi

# Stage all tracked files that have changes
yadm add -u

# Check if there are any staged changes after adding
if yadm diff --cached --quiet; then
  echo "No staged changes after adding updates"
  exit 0
fi

# Create commit with timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
yadm commit -m "$(cat <<EOF
Auto-update dotfiles - $TIMESTAMP

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"

# Push to remote
yadm push

echo "✅ Dotfiles auto-committed and pushed at $TIMESTAMP"