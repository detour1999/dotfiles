#!/bin/bash
# Script to dump macOS defaults for backup and restoration
# Should be run periodically to keep settings up to date

# Set up PATH for launchd
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Set up error handling
set -e
set -u

echo "=== Starting macOS defaults dump at $(date) ==="

# Create output directory
DEFAULTS_DIR="$HOME/.config/macOS/defaults"
mkdir -p "$DEFAULTS_DIR"

# Create timestamp for backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$DEFAULTS_DIR/backups"
mkdir -p "$BACKUP_DIR"

# Function to dump domain defaults to file
dump_domain() {
  local domain="$1"
  local output_file="$DEFAULTS_DIR/${domain//\//_}.plist"

  echo "Dumping defaults for domain: $domain"

  # Backup existing file if it exists
  if [ -f "$output_file" ]; then
    cp "$output_file" "$BACKUP_DIR/$(basename "$output_file").$TIMESTAMP"
  fi

  # Export new defaults
  defaults export "$domain" "$output_file" 2>/dev/null || true

  # Check if export was successful
  if [ -f "$output_file" ] && [ -s "$output_file" ]; then
    echo "  Success: $(wc -c < "$output_file") bytes written"
  else
    echo "  Warning: No data exported for $domain"
  fi
}

# Common domains to dump
DOMAINS=(
  "NSGlobalDomain"
  "com.apple.finder"
  "com.apple.dock"
  "com.apple.Safari"
  "com.apple.Terminal"
  "com.apple.screencapture"
  "com.apple.menuextra.clock"
  "com.apple.menuextra.battery"
  "com.apple.controlcenter"
  "com.apple.AppleMultitouchTrackpad"
  "com.apple.driver.AppleBluetoothMultitouch.trackpad"
  "com.apple.HIToolbox"
  ".GlobalPreferences"
  "com.apple.systempreferences"
  "com.apple.desktop"
  "com.apple.spaces"
  "com.apple.universalaccess"
  "com.apple.LaunchServices"
  "com.apple.Spotlight"
  "com.apple.preference.general"
  "com.apple.iCal"
  "com.apple.mail"
  "com.apple.commerce"
  "com.apple.SoftwareUpdate"
)

# Dump all specified domains
for domain in "${DOMAINS[@]}"; do
  dump_domain "$domain"
done

# Try to include some common third-party apps if they exist
THIRD_PARTY_APPS=(
)

# Only process third-party apps if the array isn't empty
if [ ${#THIRD_PARTY_APPS[@]} -gt 0 ]; then
  echo "Checking for third-party app preferences..."
  for app in "${THIRD_PARTY_APPS[@]}"; do
    # Skip empty strings
    if [ -z "$app" ]; then
      continue
    fi

    # Check if app has any defaults before dumping
    if defaults read "$app" &>/dev/null; then
      dump_domain "$app"
    fi
  done
else
  echo "No third-party apps configured for backup."
fi

# Clean up old backups (keep last 10)
# find "$BACKUP_DIR" -type f -name "*.plist.*" | sort | head -n -50 | xargs rm -f 2>/dev/null || true
find "$BACKUP_DIR" -type f -name "*.plist.*" | sort | awk '{ lines[NR] = $0 } END { for(i=1; i<=NR-50; i++) print lines[i] }' | xargs rm -f 2>/dev/null || true


echo "=== macOS defaults dump completed at $(date) ==="
echo "Defaults saved to: $DEFAULTS_DIR"
