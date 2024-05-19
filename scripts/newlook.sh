#!/bin/bash

# Define the directory containing wallpapers
wall_dir="$HOME/Documents/distro-backup/Wallpapers"

# Select a random wallpaper from the directory
wall=$(find "$wall_dir" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)

# Set the wallpaper using KDE Plasma's command
qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript 'var allDesktops = desktops();for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = "org.kde.image";d.currentConfigGroup = Array("Wallpaper","org.kde.image","General");d.writeConfig("Image", "file://'$wall'");}'

# Generate color scheme using 'wal' command and suppress notifications
wal -c > /dev/null 2>&1
wal -i "$wall" > /dev/null 2>&1

# Simulate pressing super (Windows key) + D to refresh desktop
#xdotool key --clearmodifiers "Super_L+d"

