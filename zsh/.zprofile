# Default programs
export EDITOR="nvim"
export TERMINAL="alacritty"
export BROWSER="firefox"

# wlroots specific
#export GBM\_BACKEND=nvidia-drm  
#export \_\_GLX\_VENDOR\_LIBRARY\_NAME=nvidia  
#export WLR\_NO\_HARDWARE\_CURSORS=1  
#export WLR\_DRM\_NO\_ATOMIC=1  

# Application environment variables
export QT_QPA_PLATFORM="wayland"
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export MOZ_ENABLE_WAYLAND=1
export WLR_NO_HARDWARE_CURSORS=1
export XDG_SESSION_TYPE=wayland

alias ls='ls --color=auto'
alias ll='ls -lav --ignore=.. --color=auto'   # show long listing of all except ".."
alias l='ls -lav --ignore=.?* --color=auto'   # show long listing but no hidden dotfiles except "."
alias vim="nvim"
alias vi="nvim"
alias rm="echo 'This is not the command you are looking for'; false"
alias cl="clear"
alias sudovim="sudo -E nvim -u /home/jmiv/.config/nvim/init.lua"

[[ -f ~/.bashrc ]] && . ~/.bashrc

if [ "$(tty)" = "/dev/tty1" ]; then
	exec sway 
fi
