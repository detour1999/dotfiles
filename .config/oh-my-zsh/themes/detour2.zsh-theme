# Function to check directory against conda environments
function unused_conda_warning() {
  if [[ -z $CONDA_DEFAULT_ENV || $CONDA_DEFAULT_ENV == "base" ]]; then
    local current_dir=$(basename "$PWD")
    # Check if current directory name exists as a conda env
    if conda info --envs | grep -q "^${current_dir}\s"; then
      echo "%{$fg_bold[red]%}(*c) "
    elif [[ -f "environment.yml" || -f "conda-env.yml" ]]; then
      echo "%{$fg_bold[red]%}(*c) "
    fi
  fi
}

# Function to check for unused venv in current directory
function unused_venv_warning() {
  if [[ -d ".venv" && -z $VIRTUAL_ENV ]]; then
    echo "%{$fg_bold[red]%}(*v) "
  fi
}

# Function to get the current Python virtualenv name
function virtual_env_prompt_info() {
  if [[ -n $VIRTUAL_ENV ]]; then
    venv_name=$(basename $(dirname $VIRTUAL_ENV))
    echo "%{$fg_bold[green]%}($venv_name) "
  fi
}

# Function to get the current Conda env name
function conda_env_prompt_info() {
  if [[ -n $CONDA_DEFAULT_ENV && $CONDA_DEFAULT_ENV != "base" ]]; then
    echo "%{$fg_bold[green]%}(conda:$CONDA_DEFAULT_ENV) "
  fi
}

# Function to display the hostname when in an SSH session
function ssh_hostname() {
  if [[ -n $SSH_CONNECTION ]]; then
    echo "%{$fg_bold[yellow]%}(%m) "
  fi
}

# Modified PROMPT that includes both warnings
PROMPT='$(unused_venv_warning)$(conda_env_prompt_info)$(virtual_env_prompt_info)%{$fg_no_bold[cyan]%}%n%{$fg_no_bold[magenta]%}$(ssh_hostname)•%{$fg_no_bold[green]%}%3~$(git_prompt_info)%{$reset_color%}» '

# Rest of your theme remains unchanged
RPROMPT='[%*]'

# git theming
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg_no_bold[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[blue]%})"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg_bold[yellow]%}⚡%{$fg_bold[blue]%})"

export LSCOLORS="exfxcxdxbxegedabagacad"
export LS_COLORS='no=00:fi=00:di=01;34:ln=00;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=41;33;01:ex=00;32:*.cmd=00;32:*.exe=01;32:*.com=01;32:*.bat=01;32:*.btm=01;32:*.dll=01;32:*.tar=00;31:*.tbz=00;31:*.tgz=00;31:*.rpm=00;31:*.deb=00;31:*.arj=00;31:*.taz=00;31:*.lzh=00;31:*.lzma=00;31:*.zip=00;31:*.zoo=00;31:*.z=00;31:*.Z=00;31:*.gz=00;31:*.bz2=00;31:*.tb2=00;31:*.tz2=00;31:*.tbz2=00;31:*.avi=01;35:'
