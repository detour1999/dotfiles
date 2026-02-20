# ABOUTME: Git-related utility functions for fish shell.
# ABOUTME: Provides helper functions for working with git repositories.

function git_current_branch --description 'Get the current git branch name'
    command git symbolic-ref --short HEAD 2>/dev/null
    or command git rev-parse --short HEAD 2>/dev/null
end

function git_current_repository --description 'Get the current git repository name'
    # Extract repository name from remote origin URL (works with HTTPS and SSH)
    set -l url (command git config --get remote.origin.url 2>/dev/null)
    if test -n "$url"
        echo $url | sed -E 's|^.*/([^/]+)(\.git)?$|\1|'
    end
end
