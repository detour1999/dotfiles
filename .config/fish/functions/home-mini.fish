# ABOUTME: Convenience wrapper to mosh into home-mini and land in tmux.
# ABOUTME: Usage: home-mini [--session SESSION | SESSION]

function home-mini --description "mosh into home-mini and run utm"
    work-mini --host home-mini $argv
end
