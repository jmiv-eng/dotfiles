#
# ~/.bashrc
#

alias ls='ls --color=auto'
alias ll='ls -lav --ignore=..'   # show long listing of all except ".."
alias l='ls -lav --ignore=.?*'   # show long listing but no hidden dotfiles except "."

## Use the up and down arrow keys for finding a command in history
## (you can write some initial letters of the command first).
#bind '"\e[A":history-search-backward'
#bind '"\e[B":history-search-forward'

# new bash prompt settings
export PROMPT_DIRTRIM=3
export PS1="[\[$(tput sgr0)\]\[$(tput bold)\]\[\033[38;5;221m\]\u\[$(tput sgr0)\]@\[$(tput sgr0)\]\[$(tput bold)\]\[\033[38;5;9m\]\h\[$(tput sgr0)\]: \[$(tput sgr0)\]\[\033[38;5;86m\]\w\[$(tput sgr0)\]]\\$ \[$(tput sgr0)\]"

export set PATH=$PATH:/home/jmichael/bin
export QT_QPA_PLATFORMTHEME="qt5ct"

# aliases
#alias python='python3'
alias vim="nvim"
alias vi="nvim"
alias rm="echo 'This is not the command you are looking for'; false"
#alias ssh='TERM=xterm-256color ssh -x'

# Try to detect the most recent active ssh-agent socket
if [ -z "$SSH_AUTH_SOCK" ]; then
  sock=$(find /tmp/ssh-* -type s -user "$USER" -name 'agent.*' 2>/dev/null | xargs ls -t 2>/dev/null | head -n1)
  if [ -n "$sock" ]; then
    export SSH_AUTH_SOCK="$sock"
  fi
fi
