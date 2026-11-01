############################################
# Make powershell environment
############################################

# Get Scoop
try {
    # Confirm installed scoop
    get-command scoop -ErrorAction Stop
} catch [Exception] {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

try {
    get-command scoop -ErrorAction Stop
} catch {
    Write-Output "Scoop is not installed"
    exit 1
}

# Add buckets
Write-Output "Scoop: Add Buckets"
scoop bucket add extras
scoop bucket add versions
scoop bucket add java 

###############################
# Install package using scoop
###############################
Write-Output "Scoop: Install Apps"

# for faster scoop downloads
scoop install aria2
scoop config aria2-enabled false
scoop config aria2-warning-enabled false

# requirement
scoop install git
scoop install 7zip
scoop install curl
scoop install wget
scoop install unzip

# language 
# C/C++
scoop install gcc
scoop install gdb
scoop install make
scoop install cmake

scoop install gcc-arm-none-eabi
scoop install openocd

# Rust
scoop install rustup

# Node.js 
scoop install bun       # for javascript & typescript all-in-one toolkit
scoop install nvm       # Node.js Version Manager
scoop install deno      # JS/TS runtime

# Python
scoop install python

# Java
scoop install openjdk

# Dependencies
scoop install nasm
scoop install openssl
scoop install chafa
scoop install dark

# Neovim
scoop install neovim
scoop install fd
scoop install ripgrep
scoop install lazygit
scoop install lua
scoop install luarocks

# Other tool
scoop install doxygen
scoop install graphviz
scoop install clangd        # for LSP

scoop install blender
scoop install brave
scoop install coretemp
scoop install gimp
scoop install kicad
scoop install obsidian
scoop install vlc

# python setup
python.exe -m pip install --upgrade pip --user
pip install neovim
pip install pynvim

# Node.js setup
nvm install 20.18.0
nvm use 20.18.0
npm install -g neovim
npm install -g yarn

# Set environment variable
$ENV:XDG_CONFIG_HOME = $HOME+"\.config"
$ENV:XDG_CACHE_HOME = $HOME+"\.cache"
$ENV:GIT_CONFIG = $ENV:XDG_CONFIG_HOME+"\git"

if ($ENV:XDG_CONFIG_HOME -eq $null) {
    mkdir -p $ENV:XDG_CONFIG_HOME
}
if ($ENV:XDG_CACHE_HOME -eq $null) {
    mkdir -p $ENV:XDG_CACHE_HOME
}
if ($ENV:GIT_CONFIG -eq $null) {
    mkdir -p $ENV:GIT_CONFIG
}

[Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", $ENV:XDG_CONFIG_HOME, [EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("XDG_CACHE_HOME", $ENV:XDG_CACHE_HOME, [EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("GIT_CONFIG", $ENV:XDG_CONFIG_HOME+"\git\.gitconfig", [EnvironmentVariableTarget]::User)

# Neovim config
git clone https://github.com/htkyst/nvim.git $ENV:XDG_CONFIG_HOME
