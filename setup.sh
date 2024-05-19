#!/bin/bash

# Define the log file path
log_file="/var/log/setup_script.log"

# Function to log messages
log() {
    local message=$1
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $message" | tee -a $log_file
}

# Function to install packages from a file
install_packages_from_file() {
    local file=$1
    local install_cmd=$2
    local errors=()

    if [ -f "$file" ]; then
        log "Installing packages from $file..."
        while read -r package; do
            if command -v "$package" &> /dev/null; then
                log "$package is already installed."
                continue
            fi
            if $install_cmd "$package"; then
                log "Installed $package successfully."
            else
                errors+=("Failed to install $package.")
            fi
        done < "$file"
    else
        log "File $file not found."
    fi

    for error in "${errors[@]}"; do
        log "Error: $error"
    done
}

# Function to install a package if not already installed
install_if_not_installed() {
    local cmd=$1
    local package=$2
    if ! command -v "$cmd" &> /dev/null; then
        log "Installing $package..."
        if [ -f /etc/debian_version ]; then
            sudo apt-get install -y "$package"
        elif [ -f /etc/arch-release ]; then
            sudo pacman -S --noconfirm "$package"
        else
            log "Unsupported distribution for $package installation."
        fi
    else
        log "$package is already installed."
    fi
}

# Function to install Zsh plugins if not already installed
install_zsh_plugin() {
    local plugin=$1
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin" ]; then
        log "Installing Zsh plugin: $plugin..."
        git clone "https://github.com/zsh-users/$plugin" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin"
    else
        log "Zsh plugin $plugin is already installed."
    fi
}

## Start of the setup script
log "Starting the setup script..."

# Detecting distribution
if [ -f /etc/debian_version ]; then
    log "Detected Debian-based distribution."

    log "Updating the system..."
    sudo apt-get update && sudo apt-get upgrade -y

    install_packages_from_file pacman.txt "sudo apt-get install -y"

elif [ -f /etc/arch-release ]; then
    log "Detected Arch-based distribution."

    log "Updating the system..."
    sudo pacman -Syu --noconfirm

    install_packages_from_file pacman.txt "sudo pacman -S --noconfirm"

fi

# Install flathub
log "Installing flathub..."
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Run flatpak.sh
log "Running flatpak.sh..."
./flatpak.sh

# Copy wallpapers to user's Pictures directory
log "Copying wallpapers..."
cp -r Wallpapers "$HOME/Pictures/"

# Set up scripts directory
log "Setting up scripts directory..."
mkdir -p "$HOME/.scripts"
chmod +x "$HOME/.scripts"
cp scripts/* "$HOME/.scripts/"
chmod +x "$HOME/.scripts/"*

# Detect Desktop Environment
log "Detecting Desktop Environment..."
DESKTOP_ENV=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')
AUTOSTART_SCRIPT="$HOME/.config/autostart-scripts.sh"

# Set keybindings based on Desktop Environment
if [ "$DESKTOP_ENV" = "gnome" ]; then
    log "Setting keybindings for GNOME..."
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings/custom0/ name "'Custom Shortcut'"
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings/custom0/ command "'$HOME/.scripts/newlook.sh'"
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings/custom0/ binding "'<Super>F8'"
    echo "$HOME/.scripts/newlook.sh" >> "$AUTOSTART_SCRIPT"
elif [ "$DESKTOP_ENV" = "kde" ]; then
    log "Setting keybindings for KDE..."
    echo '"alacritty"' >> ~/.xbindkeysrc
    echo '"exit"' >> ~/.xbindkeysrc
    echo '"kill -9 -1"' >> ~/.xbindkeysrc
    echo '"firefox"' >> ~/.xbindkeysrc
    if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
        echo '"kcmshell5"' >> ~/.xbindkeysrc
    else
        echo '"gnome-control-center"' >> ~/.xbindkeysrc
    fi
fi

# Install Zsh and set as default shell
log "Installing Zsh..."
install_if_not_installed zsh zsh
chsh -s "$(which zsh)"

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    log "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    log "Oh My Zsh is already installed."
fi

# Install Powerlevel10k theme if not already installed
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    log "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
else
    log "Powerlevel10k is already installed."
fi

# Install Zsh plugins
install_zsh_plugin zsh-autosuggestions
install_zsh_plugin zsh-syntax-highlighting
install_zsh_plugin zsh-completions

# Configure Zsh
log "Configuring Zsh..."
cp pk10k.zsh "$HOME/.pk10k.zsh"

# Append Zsh configuration to .zshrc
cat >> ~/.zshrc << 'EOF'

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$(hostname).zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$(hostname).zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git sudo zsh-autosuggestions zsh-syntax-highlighting zsh-completions)
source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="$HOME/.scripts:$PATH"
fcd() {
  local dir
  dir=$(find ${1:-.} -type d -not -path '*/\.*' 2> /dev/null | fzf +m) && cd "$dir"
}
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
alias cls='clear'
alias vim=nvim
alias ..="cd .."
alias ~='cd ~'
alias Desktop='cd ~/Desktop'
alias install='sudo pacman -S'
alias update='sudo pacman -Syu'
alias pkgf='sudo pacman -Ss'
alias gs='git status'
alias gp='git pull'
alias ga='git add'
alias hb='source ~/.scripts/hastebin.sh'

EOF

log "Installation complete. Please restart your terminal or run 'source ~/.zshrc' to start using Zsh with your new configuration."

# Install fonts
log "Installing fonts..."
find "$(dirname "$0")/Fonts" -type f -name "*.ttf" -exec cp {} ~/.local/share/fonts/ \;
fc-cache -f -v
log "Fonts installation complete."

# Create Alacritty configuration
log "Creating Alacritty configuration..."
mkdir -p ~/.config/alacritty
cp alacritty.toml ~/.config/alacritty
echo "export TERMINAL=alacritty" >> ~/.zshrc

# Set up keybindings
log "Setting up keybindings..."

# Ensure xbindkeys is installed
install_if_not_installed xbindkeys xbindkeys

# Create or update .xbindkeysrc for the required keybindings
cat >> ~/.xbindkeysrc << EOF
# Meta + F8 to run newlook.sh script
"bash $HOME/.scripts/newlook.sh"
    Mod4 + F8

# Meta + Enter to open Alacritty
"alacritty"
    Mod4 + Return

# Meta + Q to close applications
"xdotool getwindowfocus windowclose"
    Mod4 + q

# Meta + Shift + Q to forcefully kill applications
"xdotool getwindowfocus windowkill"
    Mod4 + Shift + q
EOF

# Start xbindkeys
log "Starting xbindkeys..."
xbindkeys

log "Setup script completed."
