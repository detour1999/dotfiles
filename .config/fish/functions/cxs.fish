# ABOUTME: Start Codex CLI with approvals and sandbox bypassed.
# ABOUTME: Shortcut alias for codex --dangerously-bypass-approvals-and-sandbox.

function cxs --wraps='codex --dangerously-bypass-approvals-and-sandbox' --description 'Start Codex (bypass approvals/sandbox)'
    codex --dangerously-bypass-approvals-and-sandbox $argv
end
