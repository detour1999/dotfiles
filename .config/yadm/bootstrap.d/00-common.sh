#!/bin/bash
# Cross-platform bootstrap: mise, oh-my-zsh (macOS), TPM, VSCode extensions, gh aliases

echo "=== Cross-Platform Setup ==="

# --- mise ---
if ! command -v mise &>/dev/null; then
    echo "Installing mise..."
    curl https://mise.jdx.dev/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

if command -v mise &>/dev/null; then
    echo "Running mise install (this may take a while on first run)..."
    mise install --yes || {
        echo "Warning: Some mise tools failed to install. Check the log for details."
    }
else
    echo "Warning: mise not found after install attempt. Skipping tool installation."
fi

# --- TPM (Tmux Plugin Manager) ---
if command -v tmux &>/dev/null; then
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        echo "Installing Tmux Plugin Manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm.git "$HOME/.tmux/plugins/tpm"

        if [ -d "$HOME/.tmux/plugins/tpm" ]; then
            echo "TPM installed successfully"
            echo "Run 'prefix + I' inside tmux to install plugins"
        else
            echo "Warning: TPM installation may have failed."
        fi
    else
        echo "TPM already installed"
    fi
fi

# --- VSCode extensions ---
if command -v code &>/dev/null; then
    echo "Installing VSCode extensions..."
    extensions=(
        "github.copilot"
        "github.copilot-chat"
        "mechatroner.rainbow-csv"
        "ms-python.debugpy"
        "ms-python.python"
        "ms-python.vscode-pylance"
        "ms-vscode-remote.remote-containers"
    )

    for ext in "${extensions[@]}"; do
        code --install-extension "$ext" || echo "Failed to install $ext"
    done
fi

# --- GitHub CLI aliases ---
if command -v gh &>/dev/null && [ -f "$HOME/.config/gh/aliases.yaml" ]; then
    echo "Importing GitHub CLI aliases..."
    gh alias import < "$HOME/.config/gh/aliases.yaml"
fi

echo "=== Cross-Platform Setup Complete ==="
