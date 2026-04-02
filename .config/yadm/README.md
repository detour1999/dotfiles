# Dotfiles

Cross-platform dotfiles managed with [yadm](https://yadm.io/). Supports macOS, Arch Linux, and Ubuntu/Debian (GUI + headless).

## New Machine Setup

### macOS

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
brew install yadm
yadm clone https://github.com/detour1999/dotfiles.git
yadm decrypt
yadm bootstrap
```

### Arch Linux

```bash
sudo pacman -S yadm
yadm clone https://github.com/detour1999/dotfiles.git
yadm decrypt
yadm bootstrap
```

### Ubuntu / Debian (Proxmox containers, etc.)

```bash
sudo apt update && sudo apt install -y yadm
yadm clone https://github.com/detour1999/dotfiles.git
yadm decrypt
yadm bootstrap
```

That's it. Three steps after yadm is installed:

1. **clone** — pulls down all dotfiles (uses HTTPS, no keys needed)
2. **decrypt** — unlocks SSH keys and secrets (enter your GPG passphrase)
3. **bootstrap** — installs packages, dev tools, sets fish as default shell

Bootstrap is non-interactive and idempotent. Safe to re-run any time.

## What Bootstrap Does

```
bootstrap
├── Detect OS (macOS / Linux), distro (arch), GUI vs headless
├── Fall back to HTTPS if SSH keys aren't working yet
├── OS-specific packages
│   ├── macOS: brew bundle, mas, launchd, macOS defaults, casks
│   └── Linux: pacman, paru (AUR), systemd services, fish as default shell
├── Cross-platform tools
│   ├── mise install (node, go, rust, python, deno, java, uv, yarn, ruff, claude)
│   ├── TPM (tmux plugin manager)
│   ├── VSCode extensions
│   └── gh CLI aliases
└── Restore SSH git rewrite if keys are working
```

## How Packages Are Managed

| What | Where | Manager |
|------|-------|---------|
| Dev runtimes (node, go, rust, python, java, etc.) | `~/.config/mise/config.toml` | mise |
| macOS system tools + GUI apps | `~/.config/brew/Brewfile` | brew |
| Arch core packages | `~/.config/pacman/packages-core.txt` | pacman |
| Arch GUI packages | `~/.config/pacman/packages-gui.txt` | pacman |
| Arch AUR packages | `~/.config/pacman/packages-aur.txt` | paru |
| Arch AUR GUI packages | `~/.config/pacman/packages-aur-gui.txt` | paru |
| Ubuntu/Debian core packages | `~/.config/apt/packages-core.txt` | apt |

Dev runtimes are **only** in mise, not in brew or pacman. System tools are **only** in brew/pacman, not in mise.

## Adding Things

```bash
# Add a dev runtime
# Edit ~/.config/mise/config.toml, then:
mise install

# Add a brew package (macOS)
# Edit ~/.config/brew/Brewfile, then:
brew bundle --file=~/.config/brew/Brewfile

# Add a pacman package (Arch)
# Edit the appropriate ~/.config/pacman/packages-*.txt, then:
sudo pacman -S --needed <package>

# Add an AUR package (Arch)
# Edit the appropriate ~/.config/pacman/packages-aur*.txt, then:
paru -S <package>

# Add an apt package (Ubuntu/Debian)
# Edit ~/.config/apt/packages-core.txt, then:
sudo apt install <package>
```

## Shell Setup

**fish** is the primary shell on all platforms. zsh and bash have minimal fallback configs (just mise + atuin + fzf) in case you end up in them.

| File | Purpose |
|------|---------|
| `~/.config/fish/config.fish` | Primary shell config |
| `~/.zshrc` | Minimal fallback |
| `~/.bashrc` | Minimal fallback |

## File Structure

```
~/.config/yadm/
  bootstrap                    # orchestrator
  bootstrap.d/
    00-common.sh               # cross-platform (mise, TPM, VSCode, gh)
    10-darwin.sh               # macOS (brew, mas, launchd, defaults)
    20-linux.sh                # Arch Linux (pacman, paru, systemd)
  encrypt                      # list of files to encrypt
  yadm_post_decrypt.sh         # SSH key setup after decrypt
  yadm_auto_commit.sh          # auto-commit dotfile changes (scheduled)
  launchd_manager.sh           # macOS scheduled tasks
  macos_defaults_dump.sh       # export macOS preferences
  macos_defaults_load.sh       # apply macOS preferences
  github_app_installer.sh      # install apps from GitHub releases (macOS)
  update_brewfile.sh           # sync Brewfile with installed packages
```

## Encrypted Files

SSH keys and secrets are encrypted with GPG. Managed by `yadm encrypt` / `yadm decrypt`. The list of encrypted files is in `~/.config/yadm/encrypt`.

## GUI vs Headless (Linux)

Bootstrap auto-detects GUI by checking `$DISPLAY`, `$WAYLAND_DISPLAY`, and `$XDG_SESSION_TYPE`. GUI packages (ghostty, zed, discord, fonts, etc.) are only installed on desktops.

To force GUI mode on a headless-detected machine (e.g., SSH into a desktop):
```bash
touch ~/.config/yadm/flags/has-gui
yadm bootstrap
```

## Logs

`~/.yadm_bootstrap.log`
