# Dotfiles Setup with yadm

This repository manages dotfiles using [yadm](https://yadm.io/) (Yet Another Dotfiles Manager).

## Setting Up a New Mac

### 1. Install Homebrew and yadm

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew to PATH (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install yadm
brew install yadm
```

### 2. Clone the dotfiles repository

```bash
yadm clone https://github.com/detour1999/dotfiles.git
```

This pulls down all tracked dotfiles and automatically triggers the bootstrap script.

### 3. Run bootstrap manually (if needed)

```bash
# Make bootstrap executable (sometimes needed after fresh clone)
chmod +x ~/.config/yadm/bootstrap

yadm bootstrap
```

## What Bootstrap Does

The bootstrap script (`~/.config/yadm/bootstrap`) automates the following:

1. **Homebrew Setup** - Installs Homebrew if not present
2. **Mac App Store** - Installs `mas` and prompts for App Store sign-in
3. **Brewfile** - Runs `brew bundle` from `~/.config/brew/Brewfile`
4. **Launchd Services** - Sets up scheduled tasks via `launchd_manager.sh`
5. **VSCode Extensions** - Installs configured extensions
6. **macOS Defaults** - Applies saved system preferences
7. **GitHub Apps** - Installs apps from GitHub releases (e.g., Sky.app)
8. **Oh-My-Zsh** - Installs the Zsh framework
9. **Encrypted Files** - Optionally decrypts sensitive files and sets up SSH
10. **GitHub CLI** - Imports `gh` aliases

## Helper Scripts

| Script | Purpose |
|--------|---------|
| `bootstrap` | Main setup script for new machines |
| `launchd_manager.sh` | Manages launchd services |
| `macos_defaults_dump.sh` | Exports current macOS preferences |
| `macos_defaults_load.sh` | Applies saved macOS preferences |
| `update_brewfile.sh` | Updates Brewfile with current packages |
| `yadm_auto_commit.sh` | Auto-commits dotfile changes |
| `yadm_post_decrypt.sh` | Post-decrypt setup for SSH keys |
| `github_app_installer.sh` | Installs apps from GitHub releases |

## Encrypted Files

Sensitive files are encrypted with `yadm encrypt`. The list of encrypted files is in `~/.config/yadm/encrypt`.

To decrypt after cloning:
```bash
yadm decrypt
```

## Logs

Bootstrap logs are written to `~/.yadm_bootstrap.log`.
