#
# ~/.bashrc
#

alias ls='ls --color=auto'
alias ll='ls -lav --ignore=..'   # show long listing of all except ".."
alias l='ls -lav --ignore=.?*'   # show long listing but no hidden dotfiles except "."

## Use the up and down arrow keys for finding a command in history
## (you can write some initial letters of the command first).
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

# old bash prompt
#PS1='[\u@\h \W]\$ '

# new bash prompt settings
export PROMPT_DIRTRIM=3
export PS1="[\[$(tput sgr0)\]\[$(tput bold)\]\[\033[38;5;221m\]\u\[$(tput sgr0)\]@\[$(tput sgr0)\]\[$(tput bold)\]\[\033[38;5;9m\]\h\[$(tput sgr0)\]: \[$(tput sgr0)\]\[\033[38;5;86m\]\w\[$(tput sgr0)\]]\\$ \[$(tput sgr0)\]"

# keychain for ssh 
eval $(keychain --eval --quiet id_ed25519 google_compute_engine)

export set PATH=$PATH:/home/jmiv/bin
export set EDITOR=nvim
export QT_QPA_PLATFORMTHEME="qt5ct"

# aliases
alias python='python3'
alias vim="nvim"
alias vi="nvim"
alias rm="echo 'This is not the command you are looking for'; false"
alias ssh='TERM=xterm-256color ssh -x'
