#!/bin/bash

# Set the directory path where the images will be downloaded
download_dir="$HOME/Documents/distro-backup/Wallpapers"

# Create the specified directory if it doesn't exist
mkdir -p "$download_dir"

# Change to the directory
cd "$download_dir"

# Use xclip to get the image links from the clipboard, split by newlines
clipboard_links=$(xclip -selection clipboard -o | grep -Eo '(http|https)://[^/"]+/\S+\.(png|jpg|jpeg|gif)')

# Debugging: Print out the extracted links
echo "Extracted links:"
echo "$clipboard_links"

# Loop through each link and download the image
while IFS= read -r link; do
    # Check if the link is empty or invalid
    if [ -z "$link" ]; then
        echo "Warning: Empty or invalid link detected. Skipping..."
    else
        # Attempt to download the image
        echo "Downloading: $link"
        wget "$link"
    fi
done <<< "$clipboard_links"

echo "Images downloaded successfully."
