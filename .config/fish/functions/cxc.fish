# ABOUTME: Resume the most recent Codex session with approvals and sandbox bypassed.
# ABOUTME: Shortcut alias for codex resume --last --dangerously-bypass-approvals-and-sandbox.

function cxc --wraps='codex resume --last --dangerously-bypass-approvals-and-sandbox' --description 'Continue last Codex session (bypass approvals/sandbox)'
    codex resume --last --dangerously-bypass-approvals-and-sandbox $argv
end
