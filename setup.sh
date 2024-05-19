#!/bin/bash

# Function to install packages from a file
install_packages_from_file() {
    local file=$1
    local install_cmd=$2
    local alt_install_cmds=(sudo apt-get install -y flatpak install flathub -y yay -S --noconfirm)
    
    if [ -f "$file" ]; then
        echo "Installing packages from $file..."
        while read -r package; do
            local package_installed=false
            for cmd in $install_cmd "${alt_install_cmds[@]}"; do
                if command -v "$package" &> /dev/null; then
                    echo "$package is already installed."
                    package_installed=true
                    break
                elif $cmd "$package"; then
                    package_installed=true
                    break
                fi
            done

            if ! $package_installed; then
                echo "Failed to install $package using any available method."
            fi
        done < "$file"
    fi
}

echo "Starting the setup script..."

# Detecting Debian-based distribution
if [ -f /etc/debian_version ]; then
    echo "Detected Debian-based distribution."

    echo "Updating the system..."
    sudo apt-get update && sudo apt-get upgrade -y

    echo "Installing Flatpak..."
    if ! command -v flatpak &> /dev/null; then
        sudo apt-get install -y flatpak
    else
        echo "Flatpak is already installed."
    fi

    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    install_packages_from_file pacman.txt "sudo apt-get install -y"
    install_packages_from_file flatpak.txt "flatpak install flathub -y"

# Detecting Arch-based distribution
elif [ -f /etc/arch-release ]; then
    echo "Detected Arch-based distribution."

    echo "Updating the system..."
    sudo pacman -Syu --noconfirm

    echo "Installing Flatpak..."
    if ! command -v flatpak &> /dev/null; then
        sudo pacman -S --noconfirm flatpak
    else
        echo "Flatpak is already installed."
    fi

    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

    echo "Checking for Yay installation..."
    if ! command -v yay &> /dev/null; then
        echo "Installing Yay..."
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ..
        rm -rf yay
    else
        echo "Yay is already installed."
    fi

    install_packages_from_file pacman.txt "sudo pacman -S --noconfirm"
    install_packages_from_file flatpak.txt "flatpak install flathub -y"
    install_packages_from_file yay.txt "yay -S --noconfirm"
fi

echo "Copying wallpapers..."
cp -r Wallpapers "$HOME/Pictures/"

echo "Setting up scripts directory..."
mkdir -p "$HOME/.scripts"
chmod +x "$HOME/.scripts"
cp scripts/* "$HOME/.scripts/"
chmod +x "$HOME/.scripts/"*

echo "Detecting Desktop Environment..."
DESKTOP_ENV=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')
AUTOSTART_SCRIPT="$HOME/.config/autostart-scripts.sh"

# Setting keybindings based on Desktop Environment
if [ "$DESKTOP_ENV" = "gnome" ]; then
    echo "Setting keybindings for GNOME..."
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings/custom0/ name "'Custom Shortcut'"
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings/custom0/ command "'$HOME/.scripts/newlook.sh'"
    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings/custom0/ binding "'<Super>F8'"
    echo "$HOME/.scripts/newlook.sh" >> "$AUTOSTART_SCRIPT"
elif [ "$DESKTOP_ENV" = "kde" ]; then
    echo "Setting keybindings for KDE..."
    kwriteconfig5 --file ~/.config/kglobalshortcutsrc --group "khotkeys" --key "Meta+F8" "Meta+F8"
    qdbus org.kde.kglobalaccel /component/khotkeys invokeShortcut "Meta+F8"
    echo "$HOME/.scripts/newlook.sh" >> "$AUTOSTART_SCRIPT"
fi

# Function to install a package if not already installed
install_if_not_installed() {
    local cmd=$1
    local package=$2
    if ! command -v "$cmd" &> /dev/null; then
        echo "Installing $package..."
        if [ -f /etc/debian_version ]; then
            sudo apt-get install -y "$package"
        elif [ -f /etc/arch-release ]; then
            sudo pacman -S --noconfirm "$package"
        fi
    else
        echo "$package is already installed."
    fi
}

echo "Installing Zsh..."
install_if_not_installed zsh zsh
chsh -s "$(which zsh)"

# Installing Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh is already installed."
fi

# Installing Powerlevel10k theme if not already installed
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    echo "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
else
    echo "Powerlevel10k is already installed."
fi

# Function to install Zsh plugins if not already installed
install_zsh_plugin() {
    local plugin=$1
    if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin" ]; then
        echo "Installing Zsh plugin: $plugin..."
        git clone "https://github.com/zsh-users/$plugin" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/$plugin"
    else
        echo "Zsh plugin $plugin is already installed."
    fi
}
install_zsh_plugin zsh-autosuggestions
install_zsh_plugin zsh-syntax-highlighting
install_zsh_plugin zsh-completions

echo "Configuring Zsh..."
cp pk10k.zsh "$HOME/.pk10k.zsh"

# Appending Zsh configuration to .zshrc
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

echo "Installation complete. Please restart your terminal or run 'source ~/.zshrc' to start using Zsh with your new configuration."

echo "Installing fonts..."
find "$(dirname "$0")/Fonts" -type f -name "*.ttf" -exec cp {} ~/.local/share/fonts/ \;
fc-cache -f -v
echo "Fonts installation complete."


echo "Creating Alacritty configuration..."
mkdir -p ~/.config/alacritty
cp alacritty.toml ~/.config/alacritty
echo "export TERMINAL=alacritty" >> ~/.zshrc

echo "Setting up keybindings..."
bindkey '^[M' exec alacritty
bindkey '^[Q' exec exit
bindkey '^[Q' exec kill -9 -1
bindkey '^[F' exec firefox
if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
    bindkey '^[i' exec kcmshell5
else
    bindkey '^[i' exec gnome-control-center
fi

echo "Setup script completed."
