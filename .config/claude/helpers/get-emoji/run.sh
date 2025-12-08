#!/usr/bin/env bash
# ABOUTME: Determines the appropriate emoji based on current directory
# ABOUTME: Returns 💼 for work directories, 🎉 for personal/fun directories

case "$PWD" in
  /Users/dylanr/work/2389*|"/Users/dylanr/Dropbox (Personal)/work/2389"*)
    echo "💼"
    ;;
  *)
    echo "🎉"
    ;;
esac
