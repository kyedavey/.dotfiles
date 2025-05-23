# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# ------------------------------ history -----------------------------

HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend

# ------------------------ bash shell options ------------------------

shopt -s checkwinsize

# -----------------------------set prompt-----------------------------

__ps1() {
  EXIT="$?"
  BLUE='\[\e[34m\]'
  RED='\[\e[31m\]'
  GREEN='\[\e[32m\]'
  GREY='\[\e[90m\]'
  COLOR_NONE='\[\e[0m\]'
  
  [[ $SSH_CLIENT ]] && HOST="$GREEN\u$GREY at $GREEN\h$GREY in "
  [[ $UID == 0 ]]  && HOST="$RED\u$GREY at $GREEN\h$GREY in "

	DIR="${BLUE}\w"
  
  GIT_BRANCH="$(git branch --show-current 2>/dev/null)"
  if [[ "$(git status -s 2> /dev/null)" ]]; then
    GIT_COLOUR="$RED"
  else
    GIT_COLOUR="$GREEN"
  fi
  GIT_INFO="$GREY on $GIT_COLOUR$GIT_BRANCH"

  if [ $EXIT = 0 ] ; then
    PROMPT_SIGN="${GREEN}❯${COLOR_NONE} "
  else
    PROMPT_SIGN="${RED}❯${COLOR_NONE} "
  fi

  if [[ "$GIT_BRANCH" ]]; then
	  PS1="$HOST$DIR$GIT_INFO $PROMPT_SIGN"
  else
    PS1="$HOST$DIR $PROMPT_SIGN"
  fi

  PS2="${GREEN}❯"
}

PROMPT_COMMAND="__ps1"

# ------------------------------ aliases -----------------------------

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Starship Prompt
if [ -x "$(command -v starship)" ]; then
  eval "$(starship init bash)" 
fi