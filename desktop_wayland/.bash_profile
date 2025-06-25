#
# ~/.bash_profile
#

# Default programs
export EDITOR="nvim"
export TERMINAL="alacritty"
export BROWSER="firefox"

# Application enviornment variables
export QT_QPA_PLATFORM="wayland"
export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
export MOZ_ENABLE_WAYLAND=1
export WLR_NO_HARDWARE_CURSORS=1

[[ -f ~/.bashrc ]] && . ~/.bashrc

if [ "$(tty)" = "/dev/tty1" ]; then
	exec sway
fi
. "$HOME/.cargo/env"
