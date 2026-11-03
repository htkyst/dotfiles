#!/usr/bin/env bash

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

info() {
    printf "${GREEN}[INFO] %s${NC}\n" "$1"
}

error() {
    printf "${RED}[ERROR] %s${NC}\n" "$1" >&2
}

print_cmd_already_installed() {
    local packages=("$@")

    for package in "${packages[@]}"; do
        info "$package : already installed."
    done
}

install_packages() {
    local packages=("$@")
    local missing=()

    # Check installed packages
    for package in "${packages[@]}"; do
        if pacman -Q "$package" >/dev/null 2>&1; then
            print_cmd_already_installed $package
        else
            missing+=("$package")
        fi
    done

    # Install missing packages
    if [[ ${#missing[@]} -eq 0 ]]; then
        return 0
    fi

    info "Installing ${missing[*]}..."

    if ! sudo pacman -S --needed --noconfirm "${missing[@]}"; then
        error "Failed to install packages: ${missing[*]}"
        return 1
    fi

    info "All packages installed successfully."
    return 0
}

install_command_if_missing() {
    local cmd="$1"
    local package="${2:-$1}"

    # Check command
    if command -v "$cmd" >/dev/null 2>&1; then
        print_cmd_already_installed $cmd
        return 0
    fi

    info "Installing $package..."

    # Install package
    if ! sudo pacman -S --needed --noconfirm "$package"; then
        error "Failed to install $package."
        return 1
    fi

    # Verify installation
    if command -v "$cmd" >/dev/null 2>&1; then
        info "$cmd installed successfully."
        return 0
    else
        error "$cmd is not available after installation."
        return 1
    fi
}

# Get repository root directory
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd "$repo_dir" || exit 1

info "Update pacman"
#sudo pacman -Syu --noconfirm

# Install requirement
install_command_if_missing git
install_command_if_missing curl
install_packages base-devel

install_command_if_missing fzf
install_command_if_missing stow

### Install fonts
install_packages ttf-jetbrains-mono-nerd
### Install jp input
install_packages fcitx5-im fcitx5-mozc fcitx5-configtool fcitx5-gtk fcitx5-qt
### Install sound control
install_packages pipewire pipewire-audio pipewire-pulse wireplumber alsa-utils

### Install zsh
install_packages zsh
### Install oh-my-zsh
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

### Install yay
if ! command -v yay >/dev/null 2>&1; then
    git clone https://aur.archlinux.org/yay.git
    pushd yay
    makepkg -si
    popd
else
    print_cmd_already_installed "yay"
fi

echo ""
echo "Completed."
