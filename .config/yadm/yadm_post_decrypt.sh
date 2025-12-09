#!/bin/bash
# ABOUTME: Post-decrypt script for YADM - sets up SSH keys and permissions after decryption
# ABOUTME: Automatically run after 'yadm decrypt' to configure decrypted sensitive files

set -e  # Exit on error

echo "=== YADM Post-Decrypt Setup ==="

# SSH directory and files
SSH_DIR="$HOME/.ssh"
SSH_CONFIG="$SSH_DIR/config"

# Ensure SSH directory exists with correct permissions
if [ -d "$SSH_DIR" ]; then
  echo "Setting SSH directory permissions..."
  chmod 700 "$SSH_DIR"

  # Set permissions for SSH config
  if [ -f "$SSH_CONFIG" ]; then
    chmod 600 "$SSH_CONFIG"
    echo "✅ SSH config permissions set (600)"
  fi

  # Set permissions for all private keys (files without .pub extension)
  for key_file in "$SSH_DIR"/*; do
    # Skip if it's a directory, public key, or known_hosts
    if [ -f "$key_file" ] && [[ ! "$key_file" == *.pub ]] && [[ ! "$key_file" == *known_hosts* ]]; then
      chmod 600 "$key_file"
      echo "✅ Set permissions for $(basename "$key_file") (600)"
    fi
  done

  # Set permissions for public keys
  for pub_key in "$SSH_DIR"/*.pub; do
    if [ -f "$pub_key" ]; then
      chmod 644 "$pub_key"
      echo "✅ Set permissions for $(basename "$pub_key") (644)"
    fi
  done

  echo "✅ SSH setup completed"
else
  echo "⚠️ SSH directory not found at $SSH_DIR"
  echo "   If you have encrypted SSH keys, they may not have been decrypted yet."
fi

# GPG setup (if you use GPG keys)
GPG_DIR="$HOME/.gnupg"
if [ -d "$GPG_DIR" ]; then
  echo "Setting GPG directory permissions..."
  chmod 700 "$GPG_DIR"

  # Set restrictive permissions on GPG files
  find "$GPG_DIR" -type f -exec chmod 600 {} \;
  find "$GPG_DIR" -type d -exec chmod 700 {} \;

  echo "✅ GPG permissions set"
fi

# Switch yadm remote from HTTPS to SSH (now that SSH keys are decrypted)
echo "Switching yadm remote to SSH..."
CURRENT_URL=$(yadm remote get-url origin 2>/dev/null)

if [[ "$CURRENT_URL" == https://github.com/* ]]; then
  # Extract user/repo from HTTPS URL
  REPO_PATH=$(echo "$CURRENT_URL" | sed 's|https://github.com/||' | sed 's|\.git$||')
  SSH_URL="git@github.com:${REPO_PATH}.git"

  yadm remote set-url origin "$SSH_URL"
  echo "✅ Switched yadm remote from HTTPS to SSH: $SSH_URL"
elif [[ "$CURRENT_URL" == git@github.com:* ]]; then
  echo "✅ Already using SSH remote: $CURRENT_URL"
else
  echo "⚠️ Unknown remote URL format: $CURRENT_URL"
fi

# Add any other post-decrypt setup here
# Examples:
# - Setting up git credentials
# - Configuring application-specific secrets
# - Symlinking decrypted config files

echo "=== Post-Decrypt Setup Complete ==="
