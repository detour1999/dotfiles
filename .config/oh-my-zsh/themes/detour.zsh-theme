function current_env_name {
    if [ -n "$CONDA_DEFAULT_ENV" ]; then
        # This is a conda environment, so just print its name
        echo "$CONDA_DEFAULT_ENV"
    elif [ -n "$VIRTUAL_ENV" ]; then
        # This is a Python venv environment, print the last part of its path
        basename "$VIRTUAL_ENV"
    fi
    # If neither condition is true, the function will output nothing
}

# user, host, full path, and time/date
# on two lines for easier vgrepping
# entry in a nice long thread on the Arch Linux forums: https://bbs.archlinux.org/viewtopic.php?pid=521888#p521888
PROMPT=$'%{\e[0;34m%}%B┌─[%b%{\e[0m%}%{\e[1;32m%}%n%{\e[1;30m%}@%{\e[0m%}%{\e[0;36m%}%m%{\e[0;34m%}%B]%b%{\e[0m%} - %b%{\e[0;34m%}%B[%b%{\e[0;32m%}%~%{\e[0;34m%}%B]%b%{\e[0m%} - %{\e[0;34m%}%B[%b%{\e[2;33m%}'%D{"%a %b %d, %H:%M"}%b$'%{\e[0;34m%}%B]%b%{\e[0m%}
%{\e[0;34m%}%B└─%B[%{\e[1;35m%}$%{\e[0;34m%}%B] \e[1;32m%}%B$(current_env_name) \e[0;34m%}%B<$(git_prompt_info)>%{\e[0m%}%b'
PS2=$' \e[0;34m%}%B>%{\e[0m%}%b '
