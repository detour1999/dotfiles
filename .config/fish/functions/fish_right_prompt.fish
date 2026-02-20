# ABOUTME: Right-side prompt showing current time.
# ABOUTME: Matches the RPROMPT from the detour2 zsh theme.

function fish_right_prompt
    set_color brblack
    echo -n "["(date +%H:%M:%S)"]"
    set_color normal
end
