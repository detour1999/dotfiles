#!/bin/bash
# Linux-specific bootstrap: Arch (pacman/paru) and Ubuntu/Debian (apt)

echo "=== Linux Setup ==="

# --- Helper functions ---
install_from_list() {
    local file="$1"
    local cmd="$2"
    if [[ ! -f "$file" ]]; then
        echo "Warning: Package list not found: $file"
        return
    fi

    echo "Installing packages from $(basename "$file")..."
    local failed=()
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" =~ ^[[:space:]]*# ]] && continue
        pkg=$(echo "$pkg" | xargs)  # trim whitespace
        eval "$cmd" "$pkg" 2>&1 || failed+=("$pkg")
    done < "$file"

    if [[ ${#failed[@]} -gt 0 ]]; then
        echo "Warning: Failed to install: ${failed[*]}"
    fi
}

# ==============================================================================
# ARCH LINUX
# ==============================================================================

setup_arch() {
    echo "Setting up Arch Linux..."
    PACMAN_DIR="$HOME/.config/pacman"

    # Refresh package database
    echo "Updating package database..."
    sudo pacman -Sy

    # Ensure base-devel is installed (needed for AUR)
    if ! pacman -Qg base-devel &>/dev/null; then
        echo "Installing base-devel group..."
        sudo pacman -S --needed --noconfirm base-devel
    fi

    # Core packages
    install_from_list "$PACMAN_DIR/packages-core.txt" "sudo pacman -S --needed --noconfirm"

    # AUR helper (paru)
    if ! command -v paru &>/dev/null; then
        echo "Installing paru (AUR helper)..."
        PARU_BUILD_DIR=$(mktemp -d)
        git clone https://aur.archlinux.org/paru.git "$PARU_BUILD_DIR/paru"
        (cd "$PARU_BUILD_DIR/paru" && makepkg -si --noconfirm) || {
            echo "Warning: paru installation failed. AUR packages will be skipped."
        }
        rm -rf "$PARU_BUILD_DIR"
    fi

    # AUR packages
    if command -v paru &>/dev/null; then
        install_from_list "$PACMAN_DIR/packages-aur.txt" "paru -S --needed --noconfirm --skipreview"
    fi

    # GUI packages
    if [[ "$YADM_HAS_GUI" == "true" ]]; then
        echo "GUI detected, installing desktop packages..."
        install_from_list "$PACMAN_DIR/packages-gui.txt" "sudo pacman -S --needed --noconfirm"

        if command -v paru &>/dev/null; then
            install_from_list "$PACMAN_DIR/packages-aur-gui.txt" "paru -S --needed --noconfirm --skipreview"
        fi
    fi
}

# ==============================================================================
# UBUNTU / DEBIAN
# ==============================================================================

setup_debian() {
    echo "Setting up Ubuntu/Debian..."
    APT_DIR="$HOME/.config/apt"

    # Update package index
    echo "Updating apt package index..."
    sudo apt update

    # Core packages
    install_from_list "$APT_DIR/packages-core.txt" "sudo apt install -y"

    # Packages that need external repos
    install_extra_apt_repos

    # GUI packages (unlikely on proxmox containers, but supported)
    if [[ "$YADM_HAS_GUI" == "true" ]]; then
        echo "GUI detected, installing desktop packages..."
        install_from_list "$APT_DIR/packages-gui.txt" "sudo apt install -y"
    fi
}

install_extra_apt_repos() {
    # GitHub CLI
    if ! command -v gh &>/dev/null; then
        echo "Adding GitHub CLI repo..."
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
            | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
            | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install -y gh
    fi

    # Atuin (not in default Ubuntu repos)
    if ! command -v atuin &>/dev/null; then
        echo "Installing atuin..."
        curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh || {
            echo "Warning: atuin installation failed."
        }
    fi

    # Tailscale
    if ! command -v tailscale &>/dev/null; then
        echo "Installing tailscale..."
        curl -fsSL https://tailscale.com/install.sh | sh || {
            echo "Warning: tailscale installation failed."
        }
    fi
}

# ==============================================================================
# DISPATCH
# ==============================================================================

case "$YADM_DISTRO" in
    arch)
        setup_arch
        ;;
    ubuntu|debian)
        setup_debian
        ;;
    *)
        echo "Unsupported distro: ${YADM_DISTRO:-unknown}"
        echo "Supported: arch, ubuntu, debian"
        echo "Skipping package installation."
        ;;
esac

# ==============================================================================
# COMMON LINUX SETUP (all distros)
# ==============================================================================

# --- Default shell (fish) ---
if command -v fish &>/dev/null; then
    FISH_PATH=$(which fish)
    if [[ "$SHELL" != "$FISH_PATH" ]]; then
        # Ensure fish is in /etc/shells
        if ! grep -q "$FISH_PATH" /etc/shells; then
            echo "Adding fish to /etc/shells..."
            echo "$FISH_PATH" | sudo tee -a /etc/shells
        fi
        echo "Setting fish as default shell..."
        chsh -s "$FISH_PATH"
    else
        echo "fish is already the default shell"
    fi
else
    echo "fish not installed, skipping shell change"
fi

# --- Enable systemd services ---
enable_service() {
    local service="$1"
    if systemctl list-unit-files "$service" &>/dev/null; then
        if ! systemctl is-enabled "$service" &>/dev/null; then
            echo "Enabling $service..."
            sudo systemctl enable --now "$service"
        else
            echo "$service already enabled"
        fi
    fi
}

enable_service docker.service
enable_service tailscaled.service

# Add user to docker group if not already
if command -v docker &>/dev/null; then
    if ! groups | grep -q docker; then
        echo "Adding $USER to docker group..."
        sudo usermod -aG docker "$USER"
        echo "Note: Log out and back in for docker group to take effect."
    fi
fi

echo "=== Linux Setup Complete ==="
