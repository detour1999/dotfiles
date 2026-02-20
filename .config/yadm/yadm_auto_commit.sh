#!/bin/bash

# Set up PATH for launchd
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Change to home directory
cd "$HOME"

# Random delay (0-30 minutes) to stagger across machines.
# All machines share this script but will naturally spread out.
JITTER=$((RANDOM % 1800))
echo "⏳ Sleeping ${JITTER}s before auto-commit (jitter to avoid conflicts)..."
sleep "$JITTER"

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

# Pull remote changes before pushing to avoid diverge from other machines.
# Use merge (not rebase) and auto-resolve binary plist conflicts by accepting
# the remote version — the next auto-commit will recapture local state anyway.
yadm fetch origin
if ! yadm diff --quiet origin/main..HEAD -- '*.plist' 2>/dev/null; then
  # There are plist differences — set up merge to prefer remote for binaries
  echo "⚠️  Remote has diverged, merging..."
fi

if ! yadm merge origin/main --no-ff --no-edit 2>/dev/null; then
  # If merge conflicts, accept remote for all binary plists and keep ours for text
  CONFLICTED=$(yadm diff --name-only --diff-filter=U 2>/dev/null)
  if [ -n "$CONFLICTED" ]; then
    echo "$CONFLICTED" | while read -r file; do
      case "$file" in
        *.plist)
          yadm checkout --theirs "$file" 2>/dev/null
          yadm add "$file"
          echo "  Resolved binary conflict: $file (accepted remote)"
          ;;
        *)
          # For text files, try accepting both sides (ours wins on conflict)
          yadm checkout --ours "$file" 2>/dev/null
          yadm add "$file"
          echo "  Resolved text conflict: $file (kept local)"
          ;;
      esac
    done
    yadm commit --no-edit 2>/dev/null || true
  fi
fi

# Push to remote
yadm push

echo "✅ Dotfiles auto-committed and pushed at $TIMESTAMP"