#!/bin/bash

# Check if file/directory path argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <file_or_directory_path>"
    exit 1
fi

# Get file/directory path from command line argument
path="$1"

# Check if file or directory exists
if [ ! -e "$path" ]; then
    echo "File or directory not found: $path"
    exit 1
fi

# Check if the path is a directory
if [ -d "$path" ]; then
    # If it's a directory, create a temporary zip file
    temp_zip=$(mktemp -u).zip
    echo "Creating temporary zip file: $temp_zip"
    zip -r "$temp_zip" "$path"
    file_path="$temp_zip"
else
    file_path="$path"
fi

# Upload file using curl with progress bar
echo "Uploading file..."
upload_url=$(curl -# -F "file=@$file_path" https://0x0.st)

# Check if upload was successful
if [ $? -eq 0 ]; then
    echo "File uploaded successfully."
    echo "URL: $upload_url"
    
    # Copy URL to clipboard
    echo "$upload_url" | xclip -selection clipboard
    echo "URL copied to clipboard."
else
    echo "Failed to upload file."
fi

# If a temporary zip file was created, remove it
if [ -n "$temp_zip" ]; then
    rm "$temp_zip"
fi
