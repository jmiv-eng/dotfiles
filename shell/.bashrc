#
# ~/.bashrc
#

alias ls='ls --color=auto'
alias ll='ls -lav --ignore=..'
alias l='ls -lav --ignore=.?*'
alias vim="nvim"
alias vi="nvim"
alias cl="clear"

# Bash prompt
export PROMPT_DIRTRIM=3
export PS1="[\[$(tput sgr0)\]\[$(tput bold)\]\[\033[38;5;221m\]\u\[$(tput sgr0)\]@\[$(tput sgr0)\]\[$(tput bold)\]\[\033[38;5;9m\]\h\[$(tput sgr0)\]: \[$(tput sgr0)\]\[\033[38;5;86m\]\w\[$(tput sgr0)\]]\\$ \[$(tput sgr0)\]"

export PATH=$HOME/bin:/usr/local/bin:$PATH
export QT_QPA_PLATFORMTHEME="qt5ct"

# Cargo
[[ -f ~/.cargo/env ]] && source ~/.cargo/env

# SSH agent, only when none is set (an SSH session may carry a forwarded one):
# gcr-ssh-agent if it's running, else an existing agent socket, else a new agent
if [[ -z "$SSH_AUTH_SOCK" ]]; then
  if [[ -S "$XDG_RUNTIME_DIR/gcr/ssh" ]]; then
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"
  else
    sock=$(find /tmp -maxdepth 2 -path '/tmp/ssh-*' -type s -user "$USER" -name 'agent.*' 2>/dev/null | xargs ls -t 2>/dev/null | head -n1)
    if [[ -n "$sock" ]]; then
      export SSH_AUTH_SOCK="$sock"
    else
      eval "$(ssh-agent -s)" > /dev/null
    fi
  fi
fi

# Local overrides
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
