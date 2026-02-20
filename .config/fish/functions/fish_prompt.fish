# ABOUTME: Colorized fish prompt blending detour2 and Harper's prompt styles.
# ABOUTME: Shows username, SSH/tmux indicator, directory, git branch+dirty, duration, job count.

function fish_prompt
    set -l last_status $status

    # Username (cyan)
    set_color cyan
    echo -n $USER

    # SSH / tmux / default indicator
    if set -q SSH_CONNECTION; and not set -q TMUX
        set_color white
        echo -n " ["
        set_color yellow
        echo -n "§"
        set_color white
        echo -n "]"
    else if set -q TMUX
        set_color white
        echo -n " ["
        set_color magenta
        echo -n "†"
        set_color white
        echo -n "]"
    end

    # Background jobs
    set -l job_count (jobs | count)
    if test $job_count -gt 0
        set_color white
        echo -n " ["
        set_color yellow
        echo -n $job_count
        set_color white
        echo -n "]"
    end

    # Directory (green, 3 components, shortened)
    set_color green
    echo -n " "(prompt_pwd --dir-length 1)

    # Git branch + dirty indicator
    set -l git_branch (command git branch --show-current 2>/dev/null)
    if test -n "$git_branch"
        set_color blue
        echo -n " ("
        set_color red
        echo -n $git_branch
        # Dirty check
        if not command git diff --quiet HEAD 2>/dev/null
            set_color yellow
            echo -n "⚡"
        end
        set_color blue
        echo -n ")"
    end

    # Command duration (yellow, only if >1s)
    if test $CMD_DURATION -gt 1000
        set_color yellow
        set -l seconds (math "$CMD_DURATION / 1000")
        if test $seconds -ge 60
            set -l mins (math -s0 "$seconds / 60")
            set -l secs (math -s0 "$seconds % 60")
            echo -n " "$mins"m"$secs"s"
        else
            echo -n " "$seconds"s"
        end
    end

    # Prompt character — green on success, red on failure
    if test $last_status -eq 0
        set_color green
    else
        set_color red
    end
    echo -n " » "

    set_color normal
end
