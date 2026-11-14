#!/usr/bin/env bash

set -euo pipefail

pkg_yay=(
    # Background manager
    awww
    # Battery
    acpi
    # Resource monitor
    btop
    # Audio visualizer
    cava
    # File manager
    dolphin
    # File manager on Terminal
    ranger
    # Ranger image viewer
    python-pillow
    # Fetching system information
    fastfetch
    # Widget toolkit
    gtk3
    # Tile window manager
    hyprland
    # Screen locking
    hyprlock
    # Idle
    hypridle
    # Terminal
    kitty
    # Luncher
    rofi-wayland
    # Web browser
    firefox
    # Command history
    atuin
    # Bluetooth
    blueman
    # Audio
    pavucontrol
    # Logout menu
    wlogout
    # Editor
    neovim
)

pkg_pacman=(
    # Qt toolkit
    quickshell
)

if ! command -v yay &>/dev/null; then
    echo "Error: yay is not installed."
    exit 1
fi

echo "Installing packages..."
yay -S --needed --noconfirm "${pkg_yay[@]}"
sudo pacman -S --needed --noconfirm "${pkg_pacman[@]}"

echo "All packages installed successfully."


