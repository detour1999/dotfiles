# ABOUTME: Fish function to create SSH tunnels to mini dev server for multiple ports.
# ABOUTME: Usage: workproxy [--local] PORT [PORT ...] (defaults to tailscale host 2389-mini)

function workproxy --description "SSH tunnel multiple ports to mini"
    # Parse --local flag
    set -l host 2389-mini
    set -l ports
    for arg in $argv
        switch $arg
            case --local
                set host mini-dylan.local
            case '*'
                set -a ports $arg
        end
    end

    if test (count $ports) -eq 0
        set_color red
        echo "  Usage: workproxy [--local] PORT [PORT ...]"
        set_color normal
        return 1
    end

    # Validate all args are numeric ports
    for port in $ports
        if not string match -qr '^\d+$' $port; or test $port -lt 1; or test $port -gt 65535
            set_color red
            printf "  Invalid port: %s (must be 1-65535)\n" $port
            set_color normal
            return 1
        end
    end

    set -l tunnel_args
    for port in $ports
        set -a tunnel_args -L $port:127.0.0.1:$port
    end

    # inner box width = 38
    echo
    set_color brblack
    echo "  ╭──────────────────────────────────────╮"
    printf "  │        workproxy → %-17s│\n" $host
    echo "  ├──────────────────────────────────────┤"
    set_color normal
    for port in $ports
        set -l portlen (string length $port)
        set -l label_len (math (string length $host) + 1 + $portlen)
        set -l left_len (math "localhost:" + $portlen)
        set -l content_len (math "$left_len + 3 + $label_len")
        set -l pad (math "38 - 4 - $content_len")

        set_color brblack
        printf "  │  "
        set_color green
        printf "localhost:%s" $port
        set_color brblack
        printf " → "
        set_color cyan
        printf "%s:%s" $host $port
        set_color brblack
        printf "%*s│\n" $pad ""
    end
    set_color brblack
    echo "  ╰──────────────────────────────────────╯"
    set_color normal
    echo
    set_color brblack
    echo "  ctrl+c to disconnect"
    set_color normal
    echo

    ssh -N $tunnel_args dylanr@$host
    set -l ssh_status $status
    if test $ssh_status -ne 0
        echo
        set_color red
        printf "  ssh exited with status %d\n" $ssh_status
        set_color normal
    end
    return $ssh_status
end
