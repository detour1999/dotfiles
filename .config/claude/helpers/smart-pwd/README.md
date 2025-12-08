# Smart PWD

A bash script that displays your current working directory in a smart, context-aware format for terminal status lines.

## Features

- **Git Root**: Shows repo name when at git root
- **Git Subdirectories**: Shows repo name + relative path
- **Git Worktrees**: Shows repo name + branch name + relative path with tree emoji
- **Home Directory**: Strips home directory for cleaner display
- **Absolute Paths**: Shows full path when outside home directory

## Output Format

| Scenario | Example Path | Output |
|----------|-------------|--------|
| Git root | `/Users/dylanr/work/2389/auto-play` | `💼 auto-play` |
| Git subdirectory | `/Users/dylanr/work/2389/auto-play/hosting` | `💼 auto-play/hosting` |
| Worktree root | `/Users/dylanr/work/2389/auto-play/.worktrees/feature` | `💼 - auto-play 🌳 - feature` |
| Worktree subdir | `/Users/dylanr/work/2389/auto-play/.worktrees/feature/src` | `💼 - auto-play 🌳 - feature/src` |
| Non-git in home | `/Users/dylanr/projects/myapp` | `💼 projects/myapp` |
| Non-git outside home | `/tmp/random/path` | `💼 /tmp/random/path` |

## Usage

The script uses the `TERMINAL_TITLE_EMOJI` environment variable if set, otherwise automatically determines the emoji using the `get-emoji` helper:

```bash
# With explicit emoji
export TERMINAL_TITLE_EMOJI="💼"
source /path/to/run.sh

# Or let it auto-detect based on directory
source /path/to/run.sh
```

## Testing

Run the test suite to verify all scenarios work correctly:

```bash
./test.sh
```

The test suite covers:
- Git repositories (root and subdirectories)
- Git worktrees (root and subdirectories)
- Non-git directories (inside and outside home)

## Dependencies

- **get-emoji helper**: Located at `~/.config/claude/helpers/get-emoji/run.sh`
  - Used to auto-detect emoji when `TERMINAL_TITLE_EMOJI` is not set
  - Determines 💼 for work directories, 🎉 for personal

## Implementation Details

The script uses:
- `git rev-parse --show-toplevel` to get the git root
- `git rev-parse --show-prefix` to get relative path within repo
- `git rev-parse --git-common-dir` to get the main repo when in a worktree
- Regex matching to detect worktree paths
- Parameter expansion to strip home directory when appropriate
- `get-emoji` helper for automatic emoji selection
