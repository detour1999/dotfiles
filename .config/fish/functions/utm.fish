# ABOUTME: Wrapper that unlocks the macOS keychain then starts tmux.
# ABOUTME: Runs unlock.sh first, then passes arguments to tm.

function utm --description 'Run unlock.sh then tm'
    unlock.sh; or echo "Keychain unlock skipped"
    tm $argv
end
