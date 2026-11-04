# ABOUTME: Terminal title fish writes each prompt — command plus shortened path.
# ABOUTME: Overrides fish's default, which prefixes a bracketed hostname over SSH.

function fish_title --description 'Terminal title without the hostname prefix'
    # Fish's default opens with "["(prompt_hostname | string sub -l 10)"]" whenever
    # SSH_TTY is set. Both consumers of this string already name the host: herdr's
    # ui.window_title leads with a machine glyph, and tmux's set-titles-string
    # leads with the session. The bracket is a second, differently truncated copy
    # eating a narrow tab, so this keeps fish's shape and drops only that prefix.
    #
    # An override for the current command arrives as the first parameter; `fg` uses
    # it to report the true process name.
    if set -q argv[1]
        echo -- (string sub -l 20 -- $argv[1]) (prompt_pwd -d 1 -D 1)
    else
        # Don't print "fish" because it's redundant
        set -l command (status current-command)
        if test "$command" = fish
            set command
        end
        echo -- (string sub -l 20 -- $command) (prompt_pwd -d 1 -D 1)
    end
end
