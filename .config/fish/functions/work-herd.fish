# ABOUTME: Convenience wrapper to mosh into mini and land in herdr instead of tmux.
# ABOUTME: Usage: work-herd [--host HOST] [--session SESSION | SESSION]

function work-herd --description "mosh into mini and run herdr"
    work-mini --herd $argv
end
