#!/bin/bash
# YADM Post-Bootstrap SSH Setup Script
# This script decrypts YADM files and switches the remote to use SSH

set -e  # Exit immediately if a command exits with a non-zero status

# Function to print messages with timestamps
log_message() {
  echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1"
}

# Ensure YADM is installed
if ! command -v yadm &> /dev/null; then
  log_message "Error: YADM is not installed. Please install YADM first."
  exit 1
fi

# Get current remote URL
CURRENT_REMOTE=$(yadm remote get-url origin 2>/dev/null || echo "none")
log_message "Current YADM remote: $CURRENT_REMOTE"

# Parse GitHub username and repository name from current remote
if [[ "$CURRENT_REMOTE" == *"github.com"* ]]; then
  # Handle HTTPS URL format (https://github.com/username/repo.git)
  if [[ "$CURRENT_REMOTE" == https://github.com/* ]]; then
    REPO_PATH=${CURRENT_REMOTE#https://github.com/}
    REPO_PATH=${REPO_PATH%.git}
    GITHUB_USERNAME=${REPO_PATH%%/*}
    REPO_NAME=${REPO_PATH#*/}
  # Handle SSH URL format (git@github.com:username/repo.git)
  elif [[ "$CURRENT_REMOTE" == git@github.com:* ]]; then
    REPO_PATH=${CURRENT_REMOTE#git@github.com:}
    REPO_PATH=${REPO_PATH%.git}
    GITHUB_USERNAME=${REPO_PATH%%/*}
    REPO_NAME=${REPO_PATH#*/}
  else
    log_message "Error: Unrecognized GitHub URL format."
    exit 1
  fi

  log_message "Detected GitHub username: $GITHUB_USERNAME"
  log_message "Detected repository name: $REPO_NAME"
else
  log_message "Error: Current remote does not appear to be a GitHub repository."
  log_message "Please set up your remote manually."
  exit 1
fi

# If remote already uses SSH, we might not need to update it
if [[ "$CURRENT_REMOTE" == git@github.com:* ]]; then
  log_message "Remote already using SSH. No update needed."
  NEEDS_UPDATE=false
else
  log_message "Remote is not using SSH. Will update after decryption."
  NEEDS_UPDATE=true
fi

# Decrypt YADM files
log_message "Decrypting YADM files..."
yadm decrypt || {
  log_message "Failed to decrypt YADM files. Please check your passphrase and try again."
  exit 1
}
log_message "YADM decryption successful!"

# Give SSH access to the new key
log_message "Setting proper permissions for SSH files..."
chmod 700 ~/.ssh || true
chmod 600 ~/.ssh/id_rsa || true
chmod 644 ~/.ssh/id_rsa.pub || true

# Check if SSH key exists
if [ ! -f ~/.ssh/id_rsa ]; then
  log_message "Warning: SSH key ~/.ssh/id_rsa not found after decryption."
  log_message "Make sure your YADM encrypted files include your SSH key."
  exit 1
fi

# Update the remote URL if needed
if [ "$NEEDS_UPDATE" = true ]; then
  NEW_REMOTE="git@github.com:${GITHUB_USERNAME}/${REPO_NAME}.git"
  log_message "Updating YADM remote to use SSH: $NEW_REMOTE"

  yadm remote set-url origin "$NEW_REMOTE" || {
    log_message "Failed to update remote URL. Please check your repository details."
    exit 1
  }

  log_message "Remote URL updated successfully!"
else
  log_message "Remote URL already using SSH. No update needed."
fi

# Test the connection
log_message "Testing SSH connection to GitHub..."
ssh -T git@github.com -o BatchMode=yes -o StrictHostKeyChecking=accept-new || {
  # Exit code 1 is actually successful for the GitHub SSH test (it just says "You've authenticated")
  if [ $? -eq 1 ]; then
    log_message "SSH connection to GitHub successful!"
  else
    log_message "Warning: SSH connection test to GitHub failed."
    log_message "This might be due to a new host, or your SSH key might not be added to your GitHub account."
    log_message "Try running 'ssh -T git@github.com' manually to debug."
  fi
}

# Test fetching from the repository
log_message "Testing YADM fetch..."
if yadm fetch -q; then
  log_message "YADM fetch successful! Your SSH setup is working correctly."
else
  log_message "Warning: YADM fetch failed. Your SSH setup may not be complete."
  log_message "Please check that your SSH key is added to your GitHub account."
fi

log_message "YADM post-bootstrap SSH setup completed!"
