#!/usr/bin/env bash

### Install Rust
yay -S --noconfirm rustup
rustup default stable

### Install tree-sitter-cli (for Neovim)
cargo install --locked tree-sitter-cli
### Install Rust
yay -S --noconfirm rustup
rustup default stable

### Install tree-sitter-cli (for Neovim)
cargo install --locked tree-sitter-cli

### Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
nvm install node
nvm use node

### Install pyenv
yay -S --noconfirm --needed openssl zlib xz tk
curl -fsSL https://pyenv.run | bash
pyenv install 3.13.5
pyenv global 3.13.5

