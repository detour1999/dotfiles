# Minimal zshrc — fish is the primary shell.
# This just makes zsh usable if you land in it.

export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"

export VIRTUAL_ENV_DISABLE_PROMPT=1
export GPG_TTY=$(tty)

# Toolchain
eval "$(mise activate zsh)"

# History
if command -v atuin &>/dev/null; then
    eval "$(atuin init zsh)"
fi

# fzf
if [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh
elif [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
fi
