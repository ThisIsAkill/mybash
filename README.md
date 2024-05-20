# Linux Setup Script

This repository contains a comprehensive setup script designed to automate the configuration of a new Linux environment. The script handles package installations, configuration of the Zsh shell with Oh My Zsh, keybindings setup, and more.

## Features

- **Automatic package installation**: Installs packages listed in `pacman.txt`.
- **Flatpak setup**: Installs Flatpak and adds the Flathub repository.
- **Zsh and Oh My Zsh**: Installs Zsh, sets it as the default shell, and configures it with Oh My Zsh and the Powerlevel10k theme.
- **Zsh plugins**: Installs useful Zsh plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`).
- **Keybindings**: Configures custom keybindings based on the detected desktop environment (GNOME or KDE).
- **Fonts installation**: Copies custom fonts to the user's local font directory and refreshes the font cache.
- **Alacritty configuration**: Sets up the Alacritty terminal emulator with custom settings.
- **Wallpapers**: Copies wallpapers to the user's `Pictures` directory.

## Usage

1. **Clone the repository**:
   ```sh
   git clone https://github.com/yourusername/linux-setup-script.git
   cd linux-setup-script
   ```

2. **Make the setup script executable**:
   ```sh
   chmod +x setup.sh
   ```

3. **Run the setup script**:
   ```sh
   sudo ./setup.sh
   ```

   > **Note**: The script requires root privileges to install packages and perform system-level changes.

## File Structure

- `setup.sh`: The main setup script.
- `flatpak.sh`: A script for installing additional Flatpak applications (if any).
- `pacman.txt`: A list of packages to be installed.
- `mount.sh`: A script that automates the process of adding an entry to `/etc/fstab` to automatically mount a specified drive at boot. It creates a mount point, sets appropriate permissions, and ensures the drive is mounted correctly.
- `pk10k.zsh`: Configuration file for Powerlevel10k.
- `scripts/`: Directory containing additional scripts to be copied to the user's `.scripts` directory.
- `Wallpapers/`: Directory containing wallpapers to be copied to the user's `Pictures` directory.
- `Fonts/`: Directory containing custom fonts to be installed.
- `alacritty.toml`: Configuration file for the Alacritty terminal emulator.

## Customization

### Package List

You can customize the list of packages to be installed by editing the `pacman.txt` file. Each line in this file should contain the name of a package to be installed.

### Zsh Configuration

The Zsh configuration can be customized by editing the `pk10k.zsh` file and modifying the section appended to the `~/.zshrc` file within the `setup.sh` script.

### Keybindings

Keybindings for GNOME and KDE can be adjusted in the `setup.sh` script under the respective desktop environment sections.

### Mounting Drives

- The script must be run with root privileges.
- Ensure the `blkid` command is available on your system.
- Run the script with the device name as an argument:

    ```sh
    sudo ./mount_drive.sh /dev/sdXn
    ```

  > **Note**: Replace `/dev/sdXn` with your actual device name (e.g., `/dev/sda1`).


## Logging

The script logs all operations to `/var/log/setup_script.log`. You can review this log file to troubleshoot any issues that occur during the setup process.

## Contributing

Contributions are welcome! If you have suggestions for improvements or encounter any issues, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
```

### Explanation
- **Features**: Highlights the key features and capabilities of the script.
- **Usage**: Provides step-by-step instructions on how to clone, make executable, and run the setup script.
- **File Structure**: Describes the purpose of each file and directory in the repository.
- **Customization**: Explains how users can customize the package list, Zsh configuration, and keybindings.
- **Logging**: Informs users about the logging functionality.
- **Contributing**: Encourages contributions and provides guidance on how to contribute.
- **License**: Mentions the license under which the project is distributed.

Feel free to modify the content to better match your specific repository details and preferences.
