@~/.config/agents/AGENTS.md

@~/.config/agents/intent.md

# Claude Code specifics

Everything above is shared with Codex and Gemini. Only Claude-only behavior belongs below.

- Never use the built-in `EnterPlanMode` tool. Planning is handled by skills and the
  brainstorming/writing-plans workflows — this is a hard rule with no exceptions.
- Skills carry the detail: `css`, `firebase`, `testing`, `journal-and-social`. They load on
  demand, so don't restate their contents here.
- Auto memory (`~/.claude/projects/<project>/memory/`) is for things you learn from my
  corrections. This file is for rules I author. Don't duplicate one into the other.
