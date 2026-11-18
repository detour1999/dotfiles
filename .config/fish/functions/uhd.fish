# ABOUTME: Wrapper that unlocks the macOS keychain then starts herdr.
# ABOUTME: The herdr counterpart to utm — usage: uhd [WORKSPACE | herdr-flags...]

function uhd --description 'Run unlock.sh then herdr'
    unlock.sh; or echo "Keychain unlock skipped"

    # A bare first argument names a workspace inside the single default session,
    # the way `tm NAME` names a session inside the single tmux server. herdr's own
    # --session is a level higher: it starts a separate server with its own
    # sidebar, so named work would never share one window. Flags pass through
    # as-is, so `uhd --remote host` and friends still work.
    if test (count $argv) -eq 0; or string match -q -- '-*' $argv[1]
        herdr $argv
        return
    end

    __uhd_focus_workspace $argv[1]; or return 1
    herdr
end

function __uhd_focus_workspace --argument-names label \
    --description 'Focus or create a herdr workspace by label'

    # Workspace commands talk to a running server over the socket. With no server
    # up there is nothing to focus, and starting one here is the wrong move: a
    # hand-backgrounded `herdr server` reports
    # capabilities.detached_server_daemon = false, which makes saved-machine
    # clients (Spaceport, `herdr machine`) refuse the host. Let the attach that
    # follows start the server herdr's own way and land on the default workspace.
    if not __uhd_server_running
        echo "uhd: no herdr server yet; starting without focusing '$label'" >&2
        return 0
    end

    # `workspace focus` takes a workspace id, not a label, so match the label first.
    set -l id (herdr workspace list \
        | jq -r --arg l $label '.result.workspaces[] | select(.label == $l) | .workspace_id' \
        | head -1)

    if test -n "$id"
        herdr workspace focus $id >/dev/null
    else
        herdr workspace create --label $label --focus >/dev/null
    end
end

function __uhd_server_running --description 'True when the default herdr server answers'
    herdr status server --json | jq -e '.running' >/dev/null 2>&1
end
