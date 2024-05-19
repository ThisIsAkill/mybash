#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <existing-repository-url>"
    exit 1
fi

# Prompt for the folder path
read -p "Enter the path of the folder you want to add to the repository: " folder_path

# Check if the folder exists
if [ ! -d "$folder_path" ]; then
    echo "Error: Folder not found!"
    exit 1
fi

# Personal access token for GitHub authentication
access_token="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"

# Initialize the repository if not already initialized
git init

# Add all files to the staging area
git add .

# Commit the changes
git commit -m "Added folder contents to existing repository"

# Push the changes to GitHub with the access token in the URL
git push "$1" master

echo "Folder contents added to the existing repository successfully!"
