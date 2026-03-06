# ABOUTME: Convenience wrapper to mosh into mini via local network.
# ABOUTME: Usage: work-mini-local [--session SESSION | SESSION]

function work-mini-local --description "mosh into mini (local) and run utm"
    work-mini --host mini-dylan.local $argv
end
