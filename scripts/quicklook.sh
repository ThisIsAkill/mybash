#!/bin/bash

# Enable debugging
set -x

# Get the filename from the first argument
file="$1"
echo "Debug: Received file argument as '$file'"

# Check if file exists
if [ ! -f "$file" ]; then
  echo "Error: File '$file' does not exist."
  exit 1
fi

# Identify file type using 'file' command
filetype=$(file --brief --mime-type "$file")
echo "Debug: File type identified as '$filetype'"

# Determine the package manager based on the Linux distribution using /etc/os-release
source /etc/os-release
case $ID in
    debian|ubuntu|linuxmint)
        PKG_MANAGER="apt-get"
        PKG_INSTALL_CMD="install -y"
        ;;
    fedora|centos|rhel)
        PKG_MANAGER="dnf"
        PKG_INSTALL_CMD="install -y"
        ;;
    arch|manjaro)
        PKG_MANAGER="pacman"
        PKG_INSTALL_CMD="-S --noconfirm"
        ;;
    *)
        echo "Error: Unsupported Linux distribution."
        exit 1
        ;;
esac

# Use appropriate preview tool based on filetype
case "$filetype" in
  image/*)
    echo "Debug: File is an image."
    # Use 'sxiv' for images with geometry set for larger window
    if command -v sxiv >/dev/null 2>&1; then
      echo "Debug: Using 'sxiv' for image preview."
      sxiv -g 800x800 "$file"
    else
      echo "Error: 'sxiv' not found. Attempting to install..."
      sudo $PKG_MANAGER $PKG_INSTALL_CMD sxiv
      sxiv -g 800x800 "$file"
    fi
    ;;
  video/*)
    echo "Debug: File is a video."
    # Use 'mpv' for videos with larger window size
    if command -v mpv >/dev/null 2>&1; then
      echo "Debug: Using 'mpv' for video playback."
      mpv --geometry=800x800 "$file"
    else
      echo "Error: No video player found (mpv). Attempting to install..."
      sudo $PKG_MANAGER $PKG_INSTALL_CMD mpv
      mpv --geometry=800x800 "$file"
    fi
    ;;
  model/vnd.collada+xml|model/stl)
    echo "Debug: File is a 3D model."
    # Use 'openvdb' for 3D models with larger window size
    if command -v openvdb >/dev/null 2>&1; then
      echo "Debug: Using 'openvdb' for 3D model viewing."
      openvdb --geometry 800x800 "$file"
    else
      echo "Error: No 3D model viewer found (openvdb). Attempting to install..."
      sudo $PKG_MANAGER $PKG_INSTALL_CMD openvdb
      openvdb --geometry 800x800 "$file"
    fi
    ;;
  *)
    echo "Debug: File type is '$filetype'."
    # Use 'head' for text files (shows the beginning)
    if [[ "$filetype" == text* ]]; then
      echo "Debug: File is a text file."
      head -n 10 "$file"
    else
      echo "Unsupported file type: $filetype"
    fi
    ;;
esac

# Disable debugging
set +x

exit 0
