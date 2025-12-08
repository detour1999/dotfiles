# Get Emoji

A bash helper that determines the appropriate emoji based on the current directory context.

## Purpose

Centralizes emoji selection logic so it can be used consistently across:
- ZSH theme prompts
- Terminal title bars
- Claude Code hooks
- Other shell scripts

## Output

Returns one of two emojis based on the current working directory:

| Directory | Emoji | Meaning |
|-----------|-------|---------|
| `/Users/dylanr/work/2389/*` | 💼 | Work/professional context |
| Everything else | 🎉 | Personal/fun context |

## Usage

```bash
# Get emoji for current directory
emoji=$(bash ~/.config/claude/helpers/get-emoji/run.sh)
echo "$emoji"  # Outputs: 💼 or 🎉
```

## Testing

Run the test suite to verify emoji selection:

```bash
cd ~/.config/claude/helpers/get-emoji
./test.sh
```

## Integration

This helper is used by:
- **smart-pwd**: Provides emoji when `TERMINAL_TITLE_EMOJI` is not set
- **detour2 theme**: Determines prompt icon and terminal title emoji
