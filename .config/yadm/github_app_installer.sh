#!/bin/bash

# Function to install a macOS app from a GitHub repository
# Usage: install_github_app "owner/repo" "AppName"
install_github_app() {
  REPO_PATH="$1"
  APP_NAME="$2"

  if [ -z "$REPO_PATH" ] || [ -z "$APP_NAME" ]; then
    echo "Error: Repository path and app name are required."
    echo "Usage: install_github_app \"owner/repo\" \"AppName\""
    return 1
  fi

  echo "Installing $APP_NAME from GitHub repository $REPO_PATH..."

  # Create Applications directory if it doesn't exist
  mkdir -p "$HOME/Applications"

  # Check if the app is already installed
  if [ -d "$HOME/Applications/$APP_NAME.app" ]; then
    echo "$APP_NAME.app is already installed. Checking for updates..."

    # Get the latest version from GitHub releases
    LATEST_VERSION=$(curl -s "https://api.github.com/repos/$REPO_PATH/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

    # Get the current installed version (assuming it follows standard macOS bundle conventions)
    CURRENT_VERSION=$(defaults read "$HOME/Applications/$APP_NAME.app/Contents/Info" CFBundleShortVersionString 2>/dev/null || echo "0.0.0")

    if [[ "$LATEST_VERSION" != "$CURRENT_VERSION" ]]; then
      echo "Updating $APP_NAME.app from $CURRENT_VERSION to $LATEST_VERSION..."
      rm -rf "$HOME/Applications/$APP_NAME.app"
      install_latest_github_app "$REPO_PATH" "$APP_NAME"
    else
      echo "$APP_NAME.app is already up to date (version $CURRENT_VERSION)."
    fi
  else
    echo "$APP_NAME.app not found. Installing..."
    install_latest_github_app "$REPO_PATH" "$APP_NAME"
  fi
}

# Function to download and install the latest version of an app from GitHub
install_latest_github_app() {
  REPO_PATH="$1"
  APP_NAME="$2"

  # Get the latest release info
  LATEST_RELEASE=$(curl -s "https://api.github.com/repos/$REPO_PATH/releases/latest")
  LATEST_VERSION=$(echo "$LATEST_RELEASE" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

  # Get the download URL - try to find a zip or dmg file
  DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | grep '"browser_download_url":' | grep -E '\.(zip|dmg)' | head -n 1 | sed -E 's/.*"([^"]+)".*/\1/')

  if [ -z "$DOWNLOAD_URL" ]; then
    echo "Failed to get download URL for $APP_NAME.app. Skipping installation."
    return 1
  fi

  # Create temp directory
  TEMP_DIR=$(mktemp -d)

  # Check file extension
  FILE_EXT="${DOWNLOAD_URL##*.}"
  TEMP_FILE="$TEMP_DIR/$APP_NAME.$FILE_EXT"

  # Download the file
  echo "Downloading $APP_NAME $LATEST_VERSION..."
  curl -L "$DOWNLOAD_URL" -o "$TEMP_FILE"

  echo "Extracting $APP_NAME.app..."

  # Process based on file type
  if [[ "$FILE_EXT" == "zip" ]]; then
    # Unzip the application
    unzip -q "$TEMP_FILE" -d "$TEMP_DIR"

    # Try to find the .app directory
    APP_PATH=$(find "$TEMP_DIR" -name "*.app" -maxdepth 2 | head -n 1)

    if [ -z "$APP_PATH" ]; then
      echo "Could not find .app in the downloaded zip. Installation failed."
      rm -rf "$TEMP_DIR"
      return 1
    fi

    # Move the app to Applications
    echo "Installing $APP_NAME.app to ~/Applications..."
    mv "$APP_PATH" "$HOME/Applications/$APP_NAME.app"

  elif [[ "$FILE_EXT" == "dmg" ]]; then
    # Mount the DMG
    echo "Mounting DMG file..."
    MOUNT_POINT=$(hdiutil attach "$TEMP_FILE" -nobrowse -readonly | tail -n 1 | awk '{print $NF}')

    # Try to find the .app directory
    APP_PATH=$(find "$MOUNT_POINT" -name "*.app" -maxdepth 1 | head -n 1)

    if [ -z "$APP_PATH" ]; then
      echo "Could not find .app in the mounted DMG. Installation failed."
      hdiutil detach "$MOUNT_POINT" -quiet
      rm -rf "$TEMP_DIR"
      return 1
    fi

    # Copy the app to Applications
    echo "Installing $APP_NAME.app to ~/Applications..."
    cp -R "$APP_PATH" "$HOME/Applications/$APP_NAME.app"

    # Unmount the DMG
    hdiutil detach "$MOUNT_POINT" -quiet
  else
    echo "Unsupported file format: $FILE_EXT. Installation failed."
    rm -rf "$TEMP_DIR"
    return 1
  fi

  # Clean up
  rm -rf "$TEMP_DIR"

  echo "$APP_NAME.app $LATEST_VERSION has been installed successfully."
}

# Example usage:
# install_github_app "jcsalterego/Sky.app" "Sky"
# install_github_app "sindresorhus/Gifski" "Gifski"
