#!/bin/bash
exec nano "$@"
# if command -v zed > /dev/null 2>&1; then
#     exec zed --wait "$@"
# elif command -v code > /dev/null 2>&1; then
#     exec code --wait "$@"
# else
#     exec nano "$@"
# fi
