#!/bin/bash

# Define the list of hard drive names
hard_drives="Jormungdor Slepnir Fenrir"

# Loop through each hard drive
for drive in $hard_drives
do
    # Get the partition of the drive (assuming a single partition per drive)
    partition=$(lsblk -ln -o NAME | grep "^$drive" | head -n 1)
    
    if [ -z "$partition" ]; then
        echo "No partition found for $drive"
        continue
    fi

    # Get UUID of the partition
    uuid=$(blkid -s UUID -o value /dev/$partition)

    # Detect partition type
    drive_type=$(blkid -s TYPE -o value /dev/$partition)

    # Check if UUID and drive type are detected
    if [ -z "$uuid" ] || [ -z "$drive_type" ]; then
        echo "Failed to get UUID or drive type for /dev/$partition"
        continue
    fi

    # Create directory in /mnt with drive name
    sudo mkdir -p /mnt/$drive

    # Check if ntfs-3g is needed
    if [ "$drive_type" = "ntfs" ]; then
        # Check if ntfs-3g is installed
        if ! command -v ntfs-3g &> /dev/null; then
            # Install ntfs-3g
            sudo apt-get install ntfs-3g -y
        fi

        # Mount ntfs partition using ntfs-3g
        sudo mount -t ntfs-3g UUID=$uuid /mnt/$drive

        # Update fstab entry for automatic mounting
        echo "UUID=$uuid /mnt/$drive ntfs-3g defaults 0 0" | sudo tee -a /etc/fstab
    else
        # Mount partition using detected type
        sudo mount UUID=$uuid /mnt/$drive

        # Update fstab entry for automatic mounting
        echo "UUID=$uuid /mnt/$drive $drive_type defaults 0 0" | sudo tee -a /etc/fstab
    fi
done
