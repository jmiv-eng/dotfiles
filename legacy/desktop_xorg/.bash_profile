#
# ~/.bash_profile
#

# for zoom to work via firefox
#export XDG_SESSION_TYPE=wayland
#export XDG_CURRENT_DESKTOP=sway
#export WLR_DRM_NO_MODIFIERS=1 

# for vlc to work with qt5
#export QT_QPA_PLATFORM=wayland

# for SDL2 to force wayland 
#export SDL_VIDEODRIVER=wayland
# if things break, do (for xwayland):
# export SDL_VIDEODRIVER=x11

[[ -f ~/.bashrc ]] && . ~/.bashrc

#if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
#  exec startx
#fi

#if [ "$(tty)" = "/dev/tty1" ]; then
#	exec sway
#fi
