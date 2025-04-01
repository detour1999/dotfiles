#!/bin/bash
# Script to load macOS defaults from previously saved files

# Set up error handling
set -e
set -u

echo "=== Starting macOS defaults load at $(date) ==="

# Define path for defaults
DEFAULTS_DIR="$HOME/.config/yadm/macos_defaults"

# Check if directory exists
if [ ! -d "$DEFAULTS_DIR" ]; then
  echo "Error: macOS defaults directory not found at $DEFAULTS_DIR"
  echo "Please run the dump script first."
  exit 1
fi

# Function to apply defaults from a plist file
apply_defaults() {
  local file="$1"
  local domain=$(basename "$file" .plist | sed 's/_/\//g')

  echo "Applying defaults for domain: $domain"

  # Import the plist file
  defaults import "$domain" "$file" 2>/dev/null

  # Check for errors
  if [ $? -eq 0 ]; then
    echo "  Success: Settings imported for $domain"
  else
    echo "  Warning: Failed to import settings for $domain"
  fi
}

# Apply all saved defaults
echo "Loading defaults from $DEFAULTS_DIR..."
for plist_file in "$DEFAULTS_DIR"/*.plist; do
  if [ -f "$plist_file" ]; then
    apply_defaults "$plist_file"
  fi
done

# Special handling for certain preferences that may need specific commands
echo "Applying special settings..."

# Set wallpaper if the setting exists
if defaults read com.apple.desktop &>/dev/null; then
  echo "  Refreshing desktop wallpaper..."
  osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/Library/Desktop Pictures/Solid Colors/Stone.png"' &>/dev/null || true
  osascript -e 'tell application "Finder" to set desktop picture to (get desktop picture)' &>/dev/null || true
fi

# Apply screen resolution settings if needed
if defaults read com.apple.systempreferences &>/dev/null; then
  echo "  Refreshing display settings..."
  displayplacer list &>/dev/null && {
    # If displayplacer is installed, it could be used to restore exact monitor configs
    echo "    Note: You could use displayplacer to save/restore exact monitor configurations"
  }
fi

# Restart affected applications
echo "Restarting affected applications..."
for app in Finder Dock SystemUIServer; do
  echo "  Restarting $app..."
  killall "$app" 2>/dev/null || true
done

echo "=== macOS defaults load completed at $(date) ==="
echo "Settings have been applied. Some changes may require logging out and back in or a system restart to take full effect."
