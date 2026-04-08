#
# ~/.bashrc
#
# Minimal bashrc — fish is the primary shell.
# This just makes bash usable if you land in it.

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

export PATH="$HOME/.local/bin:$HOME/go/bin:$PATH"
export VIRTUAL_ENV_DISABLE_PROMPT=1
export GPG_TTY=$(tty)

# Toolchain
eval "$(mise activate bash)"

# History
if command -v atuin &>/dev/null; then
    eval "$(atuin init bash)"
fi

# fzf
if [[ -f ~/.fzf.bash ]]; then
    source ~/.fzf.bash
elif [[ -f /usr/share/fzf/key-bindings.bash ]]; then
    source /usr/share/fzf/key-bindings.bash
fi
