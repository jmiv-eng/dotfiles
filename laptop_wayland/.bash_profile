#
# ~/.bash_profile
#

# Default programs
export EDITOR="nvim"
export TERMINAL="alacritty"
export BROWSER="firefox"

# nvidia specific

source ~/.vutility_secure

[[ -f ~/.bashrc ]] && . ~/.bashrc

#if [ "$(tty)" = "/dev/tty1" ]; then
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
	# Application environment variables
	#export LIBVA_DRIVER_NAME=nvidia
	export GBM_BACKEND=nvidia-drm  
	#export __GLX_VENDOR_LIBRARY_NAME=nvidia  
	#export WLR_DRM_NO_ATOMIC=1  
	#export WLR_DRM_NO_MODIFIERS=1
	#export WLR_RENDERER=vulkan
	export QT_QPA_PLATFORM=wayland
	export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
	export MOZ_ENABLE_WAYLAND=1
	export WLR_NO_HARDWARE_CURSORS=1
	export XDG_CURRENT_DESKTOP=sway
	export XDG_SESSION_TYPE=wayland
	exec sway --unsupported-gpu >~/sway.log 2>&1
fi
. "$HOME/.cargo/env"
