#!/usr/bin/env bash
# ABOUTME: Wires Claude Code, Codex, and Gemini CLI to the shared ~/.config/agents tree.
# ABOUTME: Idempotent — safe to re-run; backs up any real file sitting where a symlink belongs.

set -euo pipefail

AGENTS_DIR="$HOME/.config/agents"
SKILLS=(css firebase testing journal-and-social)

echo "=== Agent Configuration ==="

if [ ! -d "$AGENTS_DIR" ]; then
    echo "No $AGENTS_DIR found; skipping agent wiring."
    exit 0
fi

# Point $2 at $1, backing up anything real that is already there.
link() {
    local source="$1" target="$2"
    [ -e "$source" ] || { echo "  skip (missing source): $source"; return 0; }
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        return 0
    fi
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        mv "$target" "$target.bak.$(date +%s)"
        echo "  backed up existing $target"
    fi
    mkdir -p "$(dirname "$target")"
    ln -sfn "$source" "$target"
    echo "  linked $target -> $source"
}

# The guard script and its test suite must stay executable across a fresh checkout.
chmod +x "$AGENTS_DIR"/hooks/*.sh 2>/dev/null || true

# --- Claude Code ---------------------------------------------------------------
# CLAUDE.md and settings.json are tracked files restored by yadm directly, so only
# the skills and commands directories need linking.
for skill in "${SKILLS[@]}"; do
    link "$AGENTS_DIR/skills/$skill" "$HOME/.claude/skills/$skill"
done
link "$HOME/.config/claude/commands" "$HOME/.claude/commands"

# --- Codex ---------------------------------------------------------------------
# Codex doesn't honor XDG, so everything is linked in from ~/.config.
link "$AGENTS_DIR/AGENTS.md" "$HOME/.codex/AGENTS.md"
link "$HOME/.config/codex/hooks.json" "$HOME/.codex/hooks.json"
for skill in "${SKILLS[@]}"; do
    link "$AGENTS_DIR/skills/$skill" "$HOME/.codex/skills/$skill"
done

# --- Gemini CLI ----------------------------------------------------------------
link "$AGENTS_DIR/AGENTS.md" "$HOME/.gemini/GEMINI.md"
for skill in "${SKILLS[@]}"; do
    link "$AGENTS_DIR/skills/$skill" "$HOME/.gemini/skills/$skill"
done

# --- Post-link reminders -------------------------------------------------------
# Codex gates hooks twice: the features.hooks flag and a per-hook trust hash, both
# stored in config.toml. Editing hooks.json changes the hash and forces a re-trust,
# which only the interactive TUI can grant.
if command -v codex &>/dev/null; then
    if ! grep -q 'trusted_hash' "$HOME/.config/codex/config.toml" 2>/dev/null; then
        echo "  codex: hooks are untrusted — run 'codex', then press 't' at the hook review prompt"
    fi
    if ! grep -qE '^hooks[[:space:]]*=[[:space:]]*true' "$HOME/.config/codex/config.toml" 2>/dev/null; then
        echo "  codex: set 'hooks = true' under [features] in ~/.config/codex/config.toml"
    fi
fi

# Gemini keeps hooks inside settings.json, which it also writes auth state into, so
# it can't be a symlink — merge the hook in instead. `gemini hooks migrate` reports
# success without writing anything, so don't rely on it. Note the differences from
# the Claude/Codex config: the event is BeforeTool, the tool is run_shell_command,
# and timeout is in milliseconds rather than seconds.
if command -v gemini &>/dev/null; then
    gemini_settings="$HOME/.gemini/settings.json"
    if [ ! -s "$gemini_settings" ]; then
        echo "  gemini: not set up — run 'gemini' once and pick an auth method, then re-run bootstrap"
    elif ! jq -e '.hooks.BeforeTool' "$gemini_settings" >/dev/null 2>&1; then
        tmp=$(mktemp)
        jq '.hooks.BeforeTool = [{
              matcher: "run_shell_command",
              hooks: [{
                type: "command",
                command: "bash ~/.config/agents/hooks/bash-guard.sh --no-ask",
                timeout: 10000
              }]
            }]' "$gemini_settings" > "$tmp" && mv "$tmp" "$gemini_settings"
        echo "  gemini: installed BeforeTool guard into settings.json"
    fi
fi

echo "=== Agent Configuration Complete ==="
