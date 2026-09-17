#!/bin/sh
# gpu-screen-recorder instant replay control.
#
# Two entry points, dispatched on arguments:
#   (no args)       picker    — bound to $mod+F9 in sway
#   <path> <type>   save hook — invoked via gpu-screen-recorder's -sc option

notify() {
    notify-send -a gpu-screen-recorder "$@"
}

### Save hook
if [ "$#" -ge 1 ]; then
    path=$1
    case "${2-}" in
        replay)     title="Replay saved" ;;
        regular)    title="Recording saved" ;;
        screenshot) title="Screenshot saved" ;;
        *)          title="Saved" ;;
    esac

    printf '%s' "$path" | wl-copy
    action=$(notify -i camera-video -t 8000 -A open=Open -A folder=Reveal \
        "$title" "$(printf '%s' "$path" | sed 's/&/\&amp;/g')")

    case "$action" in
        open)   xdg-open "$path" ;;
        folder) xdg-open "$(dirname "$path")" ;;
    esac
    exit 0
fi

### Picker
pgrep -f "^gpu-screen-recorder" >/dev/null || {
    notify -u critical "Replay buffer isn't running"
    exit 1
}

choice=$(printf '%s\n' \
    "Last 30 seconds" \
    "Last 1 minute" \
    "Whole buffer" \
    "Toggle full recording" \
    | wofi --show dmenu -i -p "Clip" --conf ~/.config/wofi/gsr.conf) || exit 0

case "$choice" in
    "Last 30 seconds")       sig=-RTMIN+2 ;;
    "Last 1 minute")         sig=-RTMIN+3 ;;
    "Whole buffer")          sig=-USR1 ;;
    "Toggle full recording") sig=-RTMIN ;;
    *) exit 0 ;;
esac

pkill "$sig" -f "^gpu-screen-recorder"
