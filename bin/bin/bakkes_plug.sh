#!/bin/sh

# Define the destination directory (adjust as needed)
DEST_DIR="$HOME/.steam/steam/steamapps/compatdata/252950/pfx/drive_c/users/steamuser/Downloads"

# Ensure the destination directory exists
mkdir -p "$DEST_DIR"

# Check if at least one .zip file is provided
if [ "$#" -eq 0 ]; then
    echo "Usage: $0 <zip-file1> [zip-file2 ...]"
    exit 1
fi

# Loop through all provided .zip files
for ZIP_FILE in "$@"; do
    if [ -f "$ZIP_FILE" ]; then
        echo "Copying '$ZIP_FILE' to '$DEST_DIR'..."
        cp "$ZIP_FILE" "$DEST_DIR"
    else
        echo "Warning: File '$ZIP_FILE' does not exist, skipping..."
    fi
done

echo "All valid plugin .zip files have been copied to '$DEST_DIR'."
