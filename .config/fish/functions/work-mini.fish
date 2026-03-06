# ABOUTME: Mosh into the mini dev server and optionally join a tmux session.
# ABOUTME: Usage: work-mini [--host HOST] [--session SESSION | SESSION]

function work-mini --description "mosh into mini and run utm"
    # Parse --host and --session flags; remaining positional arg is session
    set -l host 2389-mini
    set -l session
    set -l positional

    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --host
                set i (math $i + 1)
                set host $argv[$i]
            case --session
                set i (math $i + 1)
                set session $argv[$i]
            case '*'
                set -a positional $argv[$i]
        end
        set i (math $i + 1)
    end

    # Positional arg is session if --session wasn't used
    if test -z "$session"; and test (count $positional) -ge 1
        set session $positional[1]
    end

    # Phrases and matching emojis for random selection
    set -l phrases 'B E A S T   M O D E' 'S E N D   I T' 'L F G' 'H A C K   T H E   P L A N E T' 'F U L L   S E N D' 'L O C K   I N' 'L E T S   G O O O' 'G O   T I M E' 'Y E E T' 'N O   S L E E P   T I L L   P R O D'
    set -l emojis '🔥' '⚡' '🚀' '💀' '🏁' '🧠' '🎯' '⏰' '🫡' '💣'
    set -l pick (random 1 (count $phrases))
    set -l bar_colors brred bryellow brgreen brcyan brblue brmagenta

    echo
    # Top rainbow bar
    for _r in (seq 1 6)
        for c in $bar_colors
            set_color $c
            printf '▓▒'
        end
    end
    printf '\n'

    # Phrase line
    echo
    set_color --bold $bar_colors[(random 1 (count $bar_colors))]
    echo "      $emojis[$pick]  $phrases[$pick]  $emojis[$pick]"
    echo
    set_color normal

    # Bottom rainbow bar
    for _r in (seq 1 6)
        for c in $bar_colors
            set_color $c
            printf '▒▓'
        end
    end
    printf '\n'
    echo

    # Connection info
    set_color --bold bryellow
    echo "      ⮕  $host"
    set_color normal
    echo

    if test -n "$session"
        mosh --server=/opt/homebrew/bin/mosh-server dylanr@$host -- /opt/homebrew/bin/fish -lc "utm $session"
    else
        mosh --server=/opt/homebrew/bin/mosh-server dylanr@$host -- /opt/homebrew/bin/fish -lc 'utm'
    end

    # Disconnect banner
    set -l bye_phrases 'P E A C E   O U T' 'G G' 'T O U C H   G R A S S' 'L A T E R   N E R D' 'A I G H T   I M M A   H E A D   O U T' 'S E S H   O V E R' 'C L O C K E D   O U T' 'B Y E   F E L I C I A' 'G O N E   F I S H I N' 'C T R L + D   E N E R G Y'
    set -l bye_emojis '✌️' '🎮' '🌿' '🤓' '🚪' '⏹️' '🕐' '👋' '🎣' '⌨️'
    set -l bye_pick (random 1 (count $bye_phrases))

    echo
    for _r in (seq 1 6)
        for c in $bar_colors
            set_color $c
            printf '░░'
        end
    end
    printf '\n'

    echo
    set_color --bold $bar_colors[(random 1 (count $bar_colors))]
    echo "      $bye_emojis[$bye_pick]  $bye_phrases[$bye_pick]  $bye_emojis[$bye_pick]"
    echo
    set_color normal

    for _r in (seq 1 6)
        for c in $bar_colors
            set_color $c
            printf '░░'
        end
    end
    printf '\n'
    echo

    set_color --bold brred
    echo "      ⮕  disconnected from $host"
    set_color normal
    echo
end
