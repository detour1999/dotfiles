# ABOUTME: Instructions for AI agents working with this yadm dotfiles setup.
# ABOUTME: Covers architecture, setup flow, and how to modify the bootstrap system.

# yadm Dotfiles

This repo manages cross-platform dotfiles using [yadm](https://yadm.io/). It supports macOS, Arch Linux, and Ubuntu/Debian, with a GUI vs headless distinction on Linux.

## Setting Up a New Machine

Three commands, no interactive prompts:

```bash
# macOS
brew install yadm

# Arch Linux
sudo pacman -S yadm

# Then (both platforms):
yadm clone https://github.com/detour1999/dotfiles.git
yadm decrypt           # enter GPG passphrase — unlocks SSH keys
yadm bootstrap         # installs everything, idempotent, safe to re-run
```

`yadm decrypt` MUST happen before `yadm bootstrap`. The bootstrap needs SSH keys for git clones. If SSH isn't working, bootstrap falls back to HTTPS automatically but warns.

## Architecture

```
~/.config/yadm/
  bootstrap                  # orchestrator — detects OS/distro/GUI, sources sub-scripts
  bootstrap.d/
    00-common.sh             # cross-platform: mise install, TPM, VSCode extensions, gh aliases
    10-darwin.sh             # macOS: homebrew, mas, launchd, defaults, casks
    20-linux.sh              # Arch Linux: pacman, paru (AUR), systemd services
```

### Bootstrap flow

1. Detect environment (`YADM_OS`, `YADM_DISTRO`, `YADM_HAS_GUI`)
2. If SSH to GitHub isn't working, temporarily disable the git SSH rewrite
3. Run OS-specific script (packages, services, shell setup)
4. Run cross-platform script (mise, TPM, etc.)
5. Restore SSH rewrite if it was disabled

### Key design decisions

- **No interactive prompts in bootstrap** — decrypt is a prerequisite, not a step
- **Idempotent** — every step checks "is this already done?" and skips if so
- **fish is the default shell** on all platforms. `.zshrc` and `.bashrc` exist as minimal fallbacks (just mise + atuin + fzf) in case you land in those shells
- **mise manages all dev toolchains** (node, go, rust, python, deno, java, uv, yarn, ruff, claude). System package managers (brew/pacman) handle system tools only
- **No oh-my-zsh** — removed, fish is primary

## Package Management

### Dev toolchains (mise — cross-platform)

Defined in `~/.config/mise/config.toml`. Includes: node, go, rust, python, deno, java, uv, yarn, ruff, claude. These are NOT in the Brewfile or pacman lists.

### macOS system packages

`~/.config/brew/Brewfile` — managed by `brew bundle`. Includes CLI tools, casks, MAS apps, VSCode extensions. Does NOT include language runtimes (those are in mise).

### Arch Linux system packages

```
~/.config/pacman/
  packages-core.txt       # every Arch box (fish, tmux, git, docker, etc.)
  packages-gui.txt        # GUI desktops only (ghostty, zed, discord, etc.)
  packages-aur.txt        # AUR packages, all machines
  packages-aur-gui.txt    # AUR packages, GUI only
```

Plain text, one package per line, `#` comments. The AUR helper is `paru`.

### Ubuntu/Debian system packages

```
~/.config/apt/
  packages-core.txt       # every Ubuntu/Debian box (fish, tmux, git, docker, etc.)
```

Some tools not in default Ubuntu repos (gh, atuin, tailscale) are installed via their official install scripts in `20-linux.sh`.

### GUI detection

- macOS: always true
- Linux: checks `$DISPLAY`, `$WAYLAND_DISPLAY`, `$XDG_SESSION_TYPE`
- Override: create `~/.config/yadm/flags/has-gui` to force GUI mode

## Shell configs

| File | Purpose |
|------|---------|
| `~/.config/fish/config.fish` | Primary shell config. OS-conditional paths, mise + atuin init |
| `~/.zshrc` | Minimal fallback — mise, atuin, fzf. No oh-my-zsh |
| `~/.bashrc` | Minimal fallback — mise, atuin, fzf |
| `~/.zprofile` | Brew shellenv (wrapped in existence check) |
| `~/.zshenv` | Just `$HOME/.local/bin` in PATH |

All shell configs use runtime OS detection (`uname` / `test -d /opt/homebrew`) rather than yadm alternate files. One file to maintain, not two.

## Git SSH rewrite

`.gitconfig##template` sets `url.git@github.com:.insteadOf=https://github.com/` which rewrites all GitHub HTTPS to SSH. This is great once keys are set up but causes a chicken-and-egg problem on fresh machines. Bootstrap handles this by temporarily unsetting the rewrite if SSH isn't working.

## Encrypted files

Sensitive files (SSH keys, etc.) are listed in `~/.config/yadm/encrypt` and managed with `yadm encrypt` / `yadm decrypt`. GPG passphrase required.

## Making changes

- **Adding a brew package**: add to `~/.config/brew/Brewfile`
- **Adding a pacman package**: add to the appropriate `~/.config/pacman/packages-*.txt`
- **Adding a dev runtime**: add to `~/.config/mise/config.toml` [tools] section
- **Adding a new bootstrap step**: add to the appropriate `bootstrap.d/*.sh` script
- **Testing bootstrap**: just run `yadm bootstrap` — it's idempotent

## Logs

Bootstrap logs: `~/.yadm_bootstrap.log`
