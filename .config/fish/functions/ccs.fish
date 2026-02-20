# ABOUTME: Start Claude Code with permissions skipped.
# ABOUTME: Shortcut alias for claude --dangerously-skip-permissions.

function ccs --wraps='claude --dangerously-skip-permissions' --description 'Start Claude Code (skip permissions)'
    claude --dangerously-skip-permissions $argv
end
