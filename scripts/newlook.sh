#!/bin/bash

# Define the directory containing wallpapers
wall_dir="$HOME/Documents/distro-backup/Wallpapers"

# Check if the directory exists
if [ ! -d "$wall_dir" ]; then
    echo "Wallpaper directory does not exist: $wall_dir"
    exit 1
fi

# Select a random wallpaper from the directory
wall=$(find "$wall_dir" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)

# Check if a wallpaper was found
if [ -z "$wall" ]; then
    echo "No wallpapers found in directory: $wall_dir"
    exit 1
fi

# Set the wallpaper using KDE Plasma's command
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript 'var allDesktops = desktops();for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = "org.kde.image";d.currentConfigGroup = Array("Wallpaper","org.kde.image","General");d.writeConfig("Image", "file://'$wall'");}'

# Check if qdbus command succeeded
if [ $? -ne 0 ]; then
    echo "Failed to set wallpaper using qdbus"
    exit 1
fi

# Generate color scheme using 'wal' command and suppress notifications
wal -c > /dev/null 2>&1
wal -i "$wall" > /dev/null 2>&1

# Check if wal command succeeded
if [ $? -ne 0 ]; then
    echo "Failed to generate color scheme using wal"
    exit 1
fi

# Optional: Simulate pressing super (Windows key) + D to refresh desktop
#xdotool key --clearmodifiers "Super_L+d"

echo "Wallpaper and color scheme updated successfully."
