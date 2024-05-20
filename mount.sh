#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Function to display usage
usage() {
    echo "Usage: $0 /dev/sdXn"
    exit 1
}

# Check if the device is provided as an argument
if [ -z "$1" ]; then
    usage
fi

DEVICE=$1

# Check if the device exists
if [ ! -b "$DEVICE" ]; then
    echo "Device $DEVICE does not exist."
    exit 1
fi

# Get the UUID of the device
UUID=$(blkid -s UUID -o value $DEVICE)
if [ -z "$UUID" ]; then
    echo "Failed to get UUID for $DEVICE."
    exit 1
fi

# Determine the file system type
FSTYPE=$(blkid -s TYPE -o value $DEVICE)
if [ -z "$FSTYPE" ]; then
    echo "Failed to get file system type for $DEVICE."
    exit 1
fi

# Create the mount point directory
MOUNT_POINT="/mnt/$(basename $DEVICE)"
mkdir -p $MOUNT_POINT

# Set the ownership and permissions for the mount point
# Assuming the current user should have ownership and permissions
CURRENT_USER=$(logname)
chown $CURRENT_USER:$CURRENT_USER $MOUNT_POINT
chmod 755 $MOUNT_POINT

# Backup /etc/fstab
cp /etc/fstab /etc/fstab.bak

# Add the new entry to /etc/fstab if it doesn't already exist
if ! grep -q "UUID=$UUID" /etc/fstab; then
    echo "UUID=$UUID  $MOUNT_POINT  $FSTYPE  defaults  0  2" >> /etc/fstab
else
    echo "Entry for $DEVICE already exists in /etc/fstab."
fi

# Mount all file systems in /etc/fstab
mount -a

# Verify the mount was successful
if mount | grep $MOUNT_POINT > /dev/null; then
    echo "Drive $DEVICE mounted successfully at $MOUNT_POINT."
else
    echo "Failed to mount $DEVICE. Restoring original /etc/fstab."
    mv /etc/fstab.bak /etc/fstab
    exit 1
fi

echo "Script completed successfully."
