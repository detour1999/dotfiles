# ABOUTME: Wrapper that unlocks the macOS keychain then starts herdr.
# ABOUTME: The herdr counterpart to utm — usage: uhd [SESSION | herdr-flags...]

function uhd --description 'Run unlock.sh then herdr'
    unlock.sh; or echo "Keychain unlock skipped"

    # herdr takes a session as --session NAME, where tm takes it positionally.
    # Treat a bare first argument as the session name; pass flags through as-is
    # so `uhd --remote host` and friends still work.
    if test (count $argv) -ge 1; and not string match -q -- '-*' $argv[1]
        herdr --session $argv
    else
        herdr $argv
    end
end
