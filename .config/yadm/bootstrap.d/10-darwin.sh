#!/bin/bash
# macOS-specific bootstrap: Homebrew, MAS, launchd, defaults, casks, github apps

echo "=== macOS Setup ==="

# --- Homebrew ---
if ! command -v brew &>/dev/null; then
    echo "Homebrew not found, installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH based on architecture
    if [[ "$(uname -m)" == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# --- Mac App Store (mas) ---
if ! command -v mas &>/dev/null; then
    echo "Installing mas for Mac App Store apps..."
    brew install mas
fi

if ! mas account &>/dev/null; then
    echo "You are not signed into the Mac App Store."
    echo "Mac App Store apps in your Brewfile cannot be installed without signing in."
    echo ""

    read -p "Would you like to sign in to the Mac App Store now? (y/n) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Launching the Mac App Store app. Please sign in through the app..."
        open -a "App Store"

        read -p "Press Enter once you've signed in through the Mac App Store app..." -r

        if mas account &>/dev/null; then
            echo "Successfully signed in to the Mac App Store as $(mas account)."
        else
            echo "Still not signed in to the Mac App Store. Trying alternative method..."
            read -p "Enter your Apple ID email: " apple_id
            mas signin "$apple_id" || {
                echo "Failed to sign in using the CLI method."
                echo "Please sign in manually through the Mac App Store app before installing Mac App Store apps."
            }
        fi
    else
        echo "Skipping Mac App Store sign-in. Mac App Store apps will not be installed."
    fi
else
    echo "Already signed in to the Mac App Store as $(mas account)."
fi

# --- Brewfile ---
mkdir -p "$HOME/.config/brew"

if [ -f "$HOME/.config/brew/Brewfile" ]; then
    echo "Installing Brewfile packages..."

    if mas account &>/dev/null; then
        brew bundle --file="$HOME/.config/brew/Brewfile" || {
            echo "Warning: Some Brewfile packages failed to install. Check the log for details."
        }
    else
        echo "Not signed into Mac App Store. Installing only brew/cask/vscode packages (skipping mas)..."
        brew bundle --file="$HOME/.config/brew/Brewfile" --no-mas || {
            echo "Warning: Some Brewfile packages failed to install. Check the log for details."
        }
        echo "To install Mac App Store apps later, sign in and run: brew bundle --file=$HOME/.config/brew/Brewfile"
    fi
else
    echo "Brewfile not found! Creating a new one..."
    brew bundle dump --file="$HOME/.config/brew/Brewfile" --all
fi

# --- Launchd services ---
if [ -f "$HOME/.config/yadm/launchd_manager.sh" ]; then
    echo "Setting up launchd services..."
    chmod +x "$HOME/.config/yadm/launchd_manager.sh"
    "$HOME/.config/yadm/launchd_manager.sh" setup-all
else
    echo "Warning: launchd manager script not found. Scheduled tasks will not be set up."
fi

# --- macOS defaults ---
MACOS_DEFAULTS_LOAD="$HOME/.config/yadm/macos_defaults_load.sh"
MACOS_DEFAULTS_DUMP="$HOME/.config/yadm/macos_defaults_dump.sh"

if [ -f "$MACOS_DEFAULTS_LOAD" ]; then
    echo "Applying saved macOS defaults..."
    chmod +x "$MACOS_DEFAULTS_LOAD"
    bash "$MACOS_DEFAULTS_LOAD"
else
    echo "No saved macOS defaults load script found. Will dump current settings."
    if [ -f "$MACOS_DEFAULTS_DUMP" ]; then
        echo "Dumping current macOS defaults for future use..."
        chmod +x "$MACOS_DEFAULTS_DUMP"
        bash "$MACOS_DEFAULTS_DUMP"
    fi
fi

# --- GitHub-hosted applications ---
echo "Installing GitHub-hosted applications..."

INSTALLER_SCRIPT="$HOME/.config/yadm/github_app_installer.sh"
if [ -f "$INSTALLER_SCRIPT" ]; then
    chmod +x "$INSTALLER_SCRIPT"
    source "$INSTALLER_SCRIPT"

    install_github_app "jcsalterego/Sky.app" "Sky"

    echo "GitHub app installation completed."
else
    echo "Warning: GitHub app installer script not found. Skipping."
fi

# --- Default shell ---
preferred_shell="/usr/local/bin/zsh"
if [[ -f "$preferred_shell" ]] && [[ "$SHELL" != "$preferred_shell" ]]; then
    echo "Setting up $preferred_shell as default shell..."
    chsh -s "$preferred_shell"
fi

echo "=== macOS Setup Complete ==="
