# ABOUTME: Main fish shell configuration for Dylan's system.
# ABOUTME: Sets up PATH, environment variables, and initializes mise + atuin.

# --- PATH ---
fish_add_path ~/.config/bin
fish_add_path ~/.local/bin
fish_add_path ~/go/bin
fish_add_path /opt/homebrew/opt/openjdk/bin

# --- Environment ---
set -gx JAVA_HOME /opt/homebrew/opt/openjdk
set -gx VIRTUAL_ENV_DISABLE_PROMPT 1
set -gx CLAUDE_CODE_DISABLE_TERMINAL_TITLE 1
set -gx GPG_TTY (tty)

# --- File descriptor limit ---
ulimit -n 10240

# --- Tool initialization ---
mise activate fish | source
atuin init fish | source
