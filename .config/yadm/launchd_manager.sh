#!/bin/bash
# Improved Launchd Services Manager Script
# Handles creation and management of launchd services for YADM bootstrap

set -e
set -u

# Path constants
LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
CONFIG_DIR="$HOME/.config/yadm"
MACOS_CONFIG_DIR="$HOME/.config/macOS"

# Create required directories
mkdir -p "$LAUNCH_AGENTS_DIR"
mkdir -p "$CONFIG_DIR"
mkdir -p "$MACOS_CONFIG_DIR"

# Define standard services as an array of service definitions
# Each service is defined as: "name:script_path:weekday:hour:minute"
STANDARD_SERVICES=(
  "brewfile-update:$CONFIG_DIR/update_brewfile.sh:0:0:0"
  "defaults-dump:$CONFIG_DIR/macos_defaults_dump.sh:6:12:0"
  "gh-alias-sync:$HOME/.config/gh/scripts/gh-alias-sync:1:9:30"
)

# Function to create a launchd plist
create_launchd_plist() {
  local name="$1"
  local script_path="$2"
  local weekday="$3"
  local hour="$4"
  local minute="$5"
  local plist_path="$LAUNCH_AGENTS_DIR/com.user.$name.plist"

  cat > "$plist_path" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.user.$name</string>
  <key>ProgramArguments</key>
  <array>
    <string>$script_path</string>
  </array>
  <key>StartCalendarInterval</key>
  <dict>
    <key>Weekday</key>
    <integer>$weekday</integer>
    <key>Hour</key>
    <integer>$hour</integer>
    <key>Minute</key>
    <integer>$minute</integer>
  </dict>
  <key>StandardErrorPath</key>
  <string>$MACOS_CONFIG_DIR/logs/$name-error.log</string>
  <key>StandardOutPath</key>
  <string>$MACOS_CONFIG_DIR/logs/$name-output.log</string>
</dict>
</plist>
EOF

  return 0
}

# Function to install or update a service
setup_service() {
  local name="$1"
  local script_path="$2"
  local weekday="$3"
  local hour="$4"
  local minute="$5"

  local plist_path="$LAUNCH_AGENTS_DIR/com.user.$name.plist"

  echo "Setting up service: $name"

  # Make sure logs directory exists
  mkdir -p "$MACOS_CONFIG_DIR/logs"

  # Check if script exists
  if [ ! -f "$script_path" ]; then
    echo "  Warning: Script $script_path not found. Service may not work properly."
  fi

  # Create plist file
  create_launchd_plist "$name" "$script_path" "$weekday" "$hour" "$minute"

  # Load or reload the service
  echo "  Loading service..."
  launchctl unload "$plist_path" 2>/dev/null || true
  launchctl load "$plist_path"

  echo "  Service $name installed successfully."
}

# Function to install all standard services
setup_all_services() {
  echo "Setting up all standard services..."

  for service_def in "${STANDARD_SERVICES[@]}"; do
    # Split the definition into components
    IFS=':' read -r name script_path weekday hour minute <<< "$service_def"

    # Set up this service
    setup_service "$name" "$script_path" "$weekday" "$hour" "$minute"
  done

  echo "All standard services have been set up."
}

# Function to list all installed services
list_services() {
  echo "Installed launchd services:"
  echo "------------------------"
  echo "NAME                   STATUS              SCHEDULE"
  echo "------------------------"

  for plist in "$LAUNCH_AGENTS_DIR"/com.user.*.plist; do
    if [ -f "$plist" ]; then
      local name=$(basename "$plist" .plist | sed 's/com\.user\.//')
      local status="Unknown"

      # Try to get service status
      if launchctl list "com.user.$name" &>/dev/null; then
        status="Running"
      else
        status="Not running"
      fi

      # Extract schedule from plist
      local weekday=$(defaults read "$plist" StartCalendarInterval | grep Weekday | awk '{print $3}' | tr -d ';')
      local hour=$(defaults read "$plist" StartCalendarInterval | grep Hour | awk '{print $3}' | tr -d ';')
      local minute=$(defaults read "$plist" StartCalendarInterval | grep Minute | awk '{print $3}' | tr -d ';')

      # Convert weekday number to name
      local weekday_name
      case "$weekday" in
        0) weekday_name="Sunday" ;;
        1) weekday_name="Monday" ;;
        2) weekday_name="Tuesday" ;;
        3) weekday_name="Wednesday" ;;
        4) weekday_name="Thursday" ;;
        5) weekday_name="Friday" ;;
        6) weekday_name="Saturday" ;;
        *) weekday_name="Unknown" ;;
      esac

      printf "%-22s %-20s %s at %02d:%02d\n" "$name" "$status" "$weekday_name" "$hour" "$minute"
    fi
  done

  if [ ! -f "$LAUNCH_AGENTS_DIR"/com.user.*.plist 2>/dev/null ]; then
    echo "No services installed."
  fi
}

# Function to uninstall a service
uninstall_service() {
  local name="$1"
  local plist_path="$LAUNCH_AGENTS_DIR/com.user.$name.plist"

  if [ -f "$plist_path" ]; then
    echo "Uninstalling service: $name"
    launchctl unload "$plist_path" 2>/dev/null || true
    rm "$plist_path"
    echo "Service $name uninstalled successfully."
  else
    echo "Service $name not found."
  fi
}

# Print usage information
print_usage() {
  echo "Launchd Services Manager"
  echo "Usage: $0 COMMAND [ARGS]"
  echo ""
  echo "Commands:"
  echo "  setup NAME SCRIPT WEEKDAY HOUR MINUTE  Set up or update a service"
  echo "                                         WEEKDAY: 0=Sun, 1=Mon, ..., 6=Sat"
  echo "  setup-all                             Set up all standard services"
  echo "  list                                  List all installed services"
  echo "  uninstall NAME                        Uninstall a service"
  echo ""
  echo "Examples:"
  echo "  $0 setup-all"
  echo "  $0 setup backup $HOME/.scripts/backup.sh 5 18 0"
  echo "  $0 list"
  echo "  $0 uninstall backup"
}

# Main command processing
case "${1:-}" in
  "setup")
    if [ $# -ne 6 ]; then
      echo "Error: setup requires 5 arguments"
      print_usage
      exit 1
    fi
    setup_service "$2" "$3" "$4" "$5" "$6"
    ;;
  "setup-all")
    setup_all_services
    ;;
  "list")
    list_services
    ;;
  "uninstall")
    if [ $# -ne 2 ]; then
      echo "Error: uninstall requires a service name"
      print_usage
      exit 1
    fi
    uninstall_service "$2"
    ;;
  *)
    print_usage
    ;;
esac

exit 0
