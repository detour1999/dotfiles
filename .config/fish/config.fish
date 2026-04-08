# ABOUTME: Main fish shell configuration for Dylan's system.
# ABOUTME: Sets up PATH, environment variables, and initializes mise + atuin.

# --- PATH ---
if test -d /opt/homebrew/bin
    fish_add_path /opt/homebrew/bin
end
fish_add_path ~/.config/bin
fish_add_path ~/.local/bin
fish_add_path ~/go/bin

# --- Environment ---
set -gx VIRTUAL_ENV_DISABLE_PROMPT 1
set -gx CLAUDE_CODE_DISABLE_TERMINAL_TITLE 1
set -gx GPG_TTY (tty)

# --- File descriptor limit (macOS only) ---
if test (uname) = Darwin
    ulimit -n 10240
end

# --- Tool initialization ---
if command -q mise
    mise activate fish | source
end
if command -q atuin
    atuin init fish | source
end