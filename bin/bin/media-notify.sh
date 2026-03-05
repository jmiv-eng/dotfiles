#!/bin/bash

# Get the current process ID of this script
# checking against $$ ensures we do not kill ourselves
current_pid=$$

# Find all processes matching the script name
# Loop through them and kill any that do not match current PID
pgrep -f "media-notify.sh" | while read -r pid; do
    if [ "$pid" != "$current_pid" ]; then
        kill "$pid" 2>/dev/null
    fi
done

# Directory for the temporary icon
TMP_DIR="/tmp/spotify-notifications"
mkdir -p "$TMP_DIR"
COVER_FILE="$TMP_DIR/cover.jpg"

# Variable to track the last processed album art URL
last_url=""

# Clean up on exit
trap "rm -rf $TMP_DIR" EXIT

# Loop to auto-reconnect if Spotify crashes or restarts
while true; do
    # We ask playerctl to only output when metadata changes
    # formatting ensures we get a single line with our delimiter "§§"
    playerctl metadata --player=spotify --format '{{ artist }}§§{{ title }}§§{{ mpris:artUrl }}' --follow | while IFS='§' read -r artist _ title _ url; do
        
        # Basic check to ensure we have data
        if [[ -z "$url" ]]; then continue; fi

        # OPTIMIZATION: Only download if the image URL is different from the last one
        if [[ "$url" != "$last_url" ]]; then
            curl -s -o "$COVER_FILE" "$url"
            last_url="$url"
        fi

        # Send the notification
        # -r 555 replaces the previous popup so they don't stack
        dunstify -r 555 -a "Spotify" -i "$COVER_FILE" "Now Playing" "<b>$title</b>\n$artist"
        
    done
    
    # Wait before trying to reconnect to avoid CPU spam if Spotify is closed
    sleep 5
done
