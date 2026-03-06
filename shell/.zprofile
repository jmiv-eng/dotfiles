# Default programs
export EDITOR="nvim"
export TERMINAL="alacritty"
export BROWSER="firefox"
export READER="evince"
export LANG=en_US.UTF-8

# Secrets (not in git)
[ -f ~/.vutility_secure ] && source ~/.vutility_secure

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Launch sway on TTY1
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
    export QT_QPA_PLATFORM=wayland
    export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
    export MOZ_ENABLE_WAYLAND=1
    export XDG_CURRENT_DESKTOP=sway
    export XDG_SESSION_TYPE=wayland

    case "$(hostname)" in
        vu|wave)
            export GBM_BACKEND=nvidia-drm
            export WLR_NO_HARDWARE_CURSORS=1
            exec sway --unsupported-gpu 2>&1
            ;;
        *)
            exec sway
            ;;
    esac
fi
