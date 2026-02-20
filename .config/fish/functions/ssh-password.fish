# ABOUTME: SSH wrapper that forces password authentication.
# ABOUTME: Disables pubkey auth to force password prompt.

function ssh-password --wraps='ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no' --description 'SSH with password auth only'
    ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no $argv
end
