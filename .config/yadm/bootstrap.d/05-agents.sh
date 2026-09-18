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

# Gemini stores hooks in its own format; migrate them from the Claude settings.
if command -v gemini &>/dev/null && [ ! -f "$HOME/.gemini/hooks.json" ]; then
    echo "  run 'gemini hooks migrate' to import the Claude hooks into Gemini"
fi

echo "=== Agent Configuration Complete ==="
