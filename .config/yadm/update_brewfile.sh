#!/bin/bash

# Path to your Brewfile
BREWFILE="$HOME/.config/brew/Brewfile"

# Dump the current state of Homebrew packages to a temporary file
TEMP_BREWFILE=$(mktemp)
brew bundle dump --force --file="$TEMP_BREWFILE"

# Compare the current Brewfile with the new one
if ! cmp -s "$BREWFILE" "$TEMP_BREWFILE"; then
  # Only update and commit if there are changes
  mv "$TEMP_BREWFILE" "$BREWFILE"
  yadm add "$BREWFILE"
  yadm commit -m "Weekly Brewfile update"
  yadm push
else
  # No changes, so clean up the temp file
  rm "$TEMP_BREWFILE"
fi
