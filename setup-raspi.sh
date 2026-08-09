#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Required "sudo""
	exit 1
fi

USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)

run_step() {
    local mess="$1"
    shift

    echo "==> $mess"

    if "$@"; then
        echo "==> Completed."
    else
        echo "==> Failed."
    fi
}

# Install requirement
install_requirement() {
    apt update
    apt upgrade -y
    apt install git curl wget build-essential
    apt install tmux
}
run_step "Install requirement" install_requirement


# Neovim
install_neovim() {
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.appimage

    mkdir -p /opt/nvim
    mv nvim-linux-arm64.appimage /opt/nvim/nvim
    chmod +x /opt/nvim/nvim
    echo 'export PATH="/opt/nvim/nvim:$PATH"' >> "$USER_HOME/.bashrc"
    source "$USER_HOME/.bashrc"
}
run_step "Install Neovim" install_neovim

# Setup Neovim
setup_neovim() {
    git clone https://github.com/htkyst/nvim.git "$USER_HOME/.config/nvim"
}
run_step "Setup Neovim" setup_neovim

# Symbolic link dotfiles
ln -s tmux/.tmux.conf $USER_HOME
ln -s others/.inputrc $USER_HOME
