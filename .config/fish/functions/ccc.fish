# ABOUTME: Continue Claude Code session with permissions skipped.
# ABOUTME: Shortcut alias for claude --dangerously-skip-permissions --continue.

function ccc --wraps='claude --dangerously-skip-permissions --continue' --description 'Continue Claude Code (skip permissions)'
    claude --dangerously-skip-permissions --continue $argv
end
