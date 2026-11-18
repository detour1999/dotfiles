#!/bin/bash
# ABOUTME: Weekly unattended upgrade of the agent CLIs that mise pins to "latest".
# ABOUTME: Scoped deliberately — toolchains on "latest" are left for a human to bump.

# Set up PATH for launchd
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
eval "$(/opt/homebrew/bin/brew shellenv)"

# Only the agent CLIs. go/node/python are version-pinned in config.toml so an
# unattended `mise upgrade` would skip them anyway, but rust/java/deno/yarn/ruff
# are on "latest" and moving a toolchain at 1am is not a thing to do unattended.
TOOLS=(claude codex herdr)

echo "=== mise upgrade $(date) ==="
mise upgrade "${TOOLS[@]}"
status=$?

if [ $status -ne 0 ]; then
  echo "mise upgrade failed with exit $status"
  exit $status
fi

# Record the resolved versions so the log answers "what am I running?" without
# needing a second command.
mise ls --current "${TOOLS[@]}"
