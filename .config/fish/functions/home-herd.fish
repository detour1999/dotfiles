# ABOUTME: Convenience wrapper to mosh into home-mini and land in herdr instead of tmux.
# ABOUTME: Usage: home-herd [--session WORKSPACE | WORKSPACE]

function home-herd --description "mosh into home-mini and run herdr"
    work-mini --herd --host home-mini $argv
end
