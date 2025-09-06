#!/bin/bash

sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm --needed git base-devel
sudo pacman -S --noconfirm --needed fzf 

# Check command
for cmd in git curl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "Error: Not installed $cmd" >&2
        exit 1
    fi
done

### Install yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ../

### Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

### Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# Setup nvm
nvm install node
nvm use node

### Install pyenv
yay -S --noconfirm --needed openssl zlib xz tk
curl -fsSL https://pyenv.run | bash

# Setup pyenv
pyenv install 3.13.5
pyenv global 3.13.5

### Install Rust
yay -S --noconfirm rustup
rustup default stable

# symbolic link dotfiles
ln -s ~/dotfiles/zsh/.zshrc ~/
ln -s ~/dotfiles/tmux/.tmux.conf ~/
ln -s ~/dotfiles/others/.inputrc ~/

# Reload zsh configuration
source ~/.zshrc

