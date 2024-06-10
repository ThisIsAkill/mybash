# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n] confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Making my scripts run without typing the whole path
export PATH="$HOME/.scripts:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set the theme to powerlevel10k
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set the default editor
export EDITOR=nvim
export VISUAL=nvim
alias vim='nvim'

# Enable case-insensitive and hyphen-insensitive completion
# Uncomment if required
# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"

# Auto-update configuration
# Uncomment and set frequency as needed
# zstyle ':omz:update' mode auto
# zstyle ':omz:update' frequency 13

# Uncomment if pasting URLs and other text is messed up
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment to disable auto-setting terminal title
# DISABLE_AUTO_TITLE="true"

# Uncomment to enable command auto-correction
# ENABLE_CORRECTION="true"

# Uncomment to display dots whilst waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment to disable marking untracked files under VCS as dirty
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment to change the command execution timestamp format
# HIST_STAMPS="mm/dd/yyyy"

# Load custom folder
# ZSH_CUSTOM=/path/to/new-custom-folder

# Load plugins
plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting zsh-completions)

# Load oh-my-zsh
source $ZSH/oh-my-zsh.sh

# Load Powerlevel10k configuration if available
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Add custom functions to fpath
fpath+=${ZDOTDIR:-~}/.zsh_functions
autoload -U compinit && compinit

# Load fzf if available
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

#######################################################
# GENERAL ALIAS'S
#######################################################

# Edit this .zshrc file
alias ezrc='edit ~/.zshrc'

# alias to show the date
alias da='date "+%Y-%m-%d %A %T %Z"'

# Alias's to modified commands
alias cls='clear'
alias vim='nvim'
alias cat='bat'
alias Desktop='cd ~/Desktop'
alias install='sudo pacman -S'
alias update='sudo pacman -Syu'
alias pkgf='sudo pacman -Ss'
alias gs='git status'
alias gp='git pull'
alias ga='git add'
alias hb='source ~/.scripts/hastebin'
alias rm='trash -v'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias ps='ps auxf'

# Change directory aliases
alias home='cd ~'
alias ~='cd ~'
alias ...='cd ../..'
alias ..="cd .."

# Remove a directory and all files
alias rmd='/bin/rm --recursive --force --verbose'

# Search files in the current folder
alias f="find . | grep"

#######################################################
# SPECIAL FUNCTIONS
#######################################################
# Function to copy a file with progress indicator
cpp() {
  set -e
  strace -q -ewrite cp -- "${1}" "${2}" 2>&1 | \
  awk '{
    count += $NF
    if (count % 10 == 0) {
      percent = count / total_size * 100
      printf "%3d%% [", percent
      for (i=0; i<=percent; i++) printf "="
      printf ">"
      for (i=percent; i<100; i++) printf " "
      printf "]\r"
    }
  }
  END { print "" }' total_size="$(stat -c '%s' "${1}")" count=0
}

# Copy and go to the directory
cpg() {
	if [ -d "$2" ]; then
		cp "$1" "$2" && cd "$2"
	else
		cp "$1" "$2"
	fi
}

# Move and go to the directory
mvg() {
	if [ -d "$2" ]; then
		mv "$1" "$2" && cd "$2"
	else
		mv "$1" "$2"
	fi
}


# Function to create a directory and change into it
mkdirg() {
  mkdir -p "$1"
  cd "$1"
}

# Custom cd function to list directory contents after changing directory
cd () {
  if [ -n "$1" ]; then
    builtin cd "$@" && ls
  else
    builtin cd ~ && ls
  fi
}

# Initialize zoxide
eval "$(zoxide init zsh)"

# Define a function to run `zi`
function zoxide_zi() {
    zle reset-prompt
    zi
    zle accept-line
}
# Bind Ctrl+f to the zoxide_zi function
zle -N zoxide_zi
bindkey '^f' zoxide_zi

# Initialize fzf
source <(fzf --zsh)

