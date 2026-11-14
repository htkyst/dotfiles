#!/usr/bin/env bash

# ANSI Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

info() {
    printf "${GREEN}[INFO] %s${NC}\n" "$1"
}

error() {
    printf "${RED}[ERROR] %s${NC}\n" "$1" >&2
}

warning() {
    printf "${YELLOW}[WARN] %s${NC}\n" "$1" >&2
}

message() {
    printf "${BLUE}[****] %s${NC}\n" "$1" >&2
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

    # Check command
    if command -v "$cmd" >/dev/null 2>&1; then
        print_cmd_already_installed $cmd
        return 0
    fi

    info "Installing $cmd..."

    # Install package
    if ! sudo pacman -S --needed --noconfirm "$cmd"; then
        error "Failed to install $cmd."
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

move_to_repository_dir() {
    # Get repository root directory
    repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
    cd "$repo_dir" || exit 1
    message "Moved to $repo_dir"
}

update_package_manager() {
    message "Update package manager"
    sudo -v || exit 1
    sudo pacman -Syu --noconfirm
}

check_requirement() {
    local commands=("git" "curl")
    local cmd
    local failed=0

    for cmd in "${commands[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            error "$cmd : not installed."
            failed = 1
        else
            info "$cmd : already installed."
        fi
    done

    return "$failed"
}

install_requirment() {
    install_command_if_missing fzf
    install_command_if_missing stow
}

install_shell() {
    ### Install zsh
    install_packages zsh
    ### Install oh-my-zsh
    # sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_aur_helper() {
    ### Install yay
    if ! command -v yay >/dev/null 2>&1; then
        git clone https://aur.archlinux.org/yay.git
        pushd yay
        makepkg -si
        popd
    else
        print_cmd_already_installed "yay"
    fi
}

main() {
    message "Run installation"

    move_to_repository_dir
    update_package_manager
    check_requirement
    install_requirment
    # Install fonts
    install_packages ttf-jetbrains-mono-nerd
    # Install jp input
    install_packages fcitx5-im fcitx5-mozc fcitx5-configtool fcitx5-gtk fcitx5-qt
    # Install audio control
    install_packages pipewire pipewire-audio pipewire-pulse wireplumber alsa-utils
    install_shell
    install_aur_helper

    message "Completed."
}

main "$@"
