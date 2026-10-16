# ABOUTME: Convenience wrapper to mosh into mini via local network and land in herdr.
# ABOUTME: Usage: work-herd-local [--session SESSION | SESSION]

function work-herd-local --description "mosh into mini (local) and run herdr"
    work-mini --herd --host mini-dylan.local $argv
end
