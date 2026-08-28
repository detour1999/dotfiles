# When connected via SSH, override exotic TERM values that remote servers
# may not have terminfo for (e.g. xterm-ghostty).
if set -q SSH_TTY
    set -x TERM xterm-256color
end
