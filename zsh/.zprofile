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

[[ -f ~/.bashrc ]] && . ~/.bashrc

if [ "$(tty)" = "/dev/tty1" ]; then
	exec sway --unsupported-gpu
fi
