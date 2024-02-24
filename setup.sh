#!/bin/bash

set -e

sudoIfAvailable() {
  if command -v sudoIfAvailable; then
    sudo "$@"
  else
    "$@"
  fi
}

# macOS
if [ "$(uname)" == "Darwin" ]; then
  # Check for Homebrew and install if we don't have it
  if test ! $(which brew); then
    echo "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  # Check for git and install if we don't have it
  if test ! $(which git); then
    echo "Installing git..."
    brew install git
  fi
  # Install neovim
  brew install neovim
  # Install tmux
  brew install tmux
fi

# Linux
if [ "$(uname)" == "Linux" ]; then
  # Install with apt if on Ubuntu
  if [ -x "$(command -v apt)" ]; then
    # Check for git and install if we don't have it
    if test ! $(which git); then
      sudoIfAvailable apt install -y git
    fi
    sudoIfAvailable apt-get update
    sudoIfAvailable apt install -y neovim
    sudoIfAvailable apt install -y tmux
    # Install alacritty dependencies
    sudoIfAvailable apt install -y \
      cmake \
      pkg-config \
      libfreetype6-dev \
      libfontconfig1-dev \
      libxcb-xfixes0-dev \
      libxkbcommon-dev \
      python3
  # Install with pacman if on Arch
  elif [ -x "$(command -v pacman)" ]; then
    # Check for git and install if we don't have it
    if test ! $(which git); then
      sudoIfAvailable pacman -S git
    fi
    sudoIfAvailable pacman -S neovim
    sudoIfAvailable pacman -S tmux
    # Install alacritty dependencies
    sudoIfAvailable pacman -S \
      cmake \
      freetype2 \
      fontconfig \
      pkg-config \
      make \
      libxcb \
      libxkbcommon \
      python
  # Install with dnf if on Fedora
  elif [ -x "$(command -v dnf)" ]; then
    # Check for git and install if we don't have it
    if test ! $(which git); then
      sudoIfAvailable dnf install -y git
    fi
    sudoIfAvailable dnf install -y neovim
    sudoIfAvailable dnf install -y tmux
    sudoIfAvailable dnf install -y \
      cmake \
      freetype-devel \
      fontconfig-devel \
      libxcb-devel \
      libxkbcommon-devel \
      g++
  # Install with yum if on CentOS
  elif [ -x "$(command -v yum)" ]; then
    # Check for git and install if we don't have it
    if test ! $(which git); then
      sudoIfAvailable yum install -y git
    fi
    sudoIfAvailable yum install -y neovim
    sudoIfAvailable yum install -y tmux
    sudoIfAvailable yum install -y \
      cmake \
      freetype-devel \
      fontconfig-devel \
      libxcb-devel \
      libxkbcommon-devel \
      xcb-util-devel
    sudoIfAvailable yum group install -y "Development Tools"
  # Install with zypper if on OpenSUSE
  elif [ -x "$(command -v zypper)" ]; then
    # Check for git and install if we don't have it
    if test ! $(which git); then
      sudoIfAvailable zypper install -y git
    fi
    sudoIfAvailable zypper install -y neovim
    sudoIfAvailable zypper install -y tmux
    sudoIfAvailable zypper install -y \
      cmake \
      freetype-devel \
      fontconfig-devel \
      libxcb-devel \
      libxkbcommon-devel
  # Catch unsupported Linux distros
  else
    echo "Unsupported Linux distro"
    exit 1
  fi
fi

# Install kickstart neovim
git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim

# Install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# Use cargo to install alacritty
cargo install alacritty

# Copy alacritty config to $HOME/.config/alacritty/alacritty.toml
mkdir -p $HOME/.config/alacritty/themes
cp alacritty/alacritty.yml $HOME/.config/alacritty/alacritty.yml

# Copy alacritty theme files to $HOME/.config/alacritty
curl -LO --output-dir ~/.config/alacritty/themes https://github.com/catppuccin/alacritty/raw/main/catppuccin-latte.toml
curl -LO --output-dir ~/.config/alacritty/themes https://github.com/catppuccin/alacritty/raw/main/catppuccin-frappe.toml
curl -LO --output-dir ~/.config/alacritty/themes https://github.com/catppuccin/alacritty/raw/main/catppuccin-macchiato.toml
curl -LO --output-dir ~/.config/alacritty/themes https://github.com/catppuccin/alacritty/raw/main/catppuccin-mocha.toml

# Install tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Copy tmux config to $HOME/.tmux.conf
cp tmux/tmux.conf $HOME/.tmux.conf

# Copy neovim config to $HOME/.config/nvim/init.vim
cp nvim/init.vim $HOME/.config/nvim/init.vim

# Add neovim plugin configuration
cp -r nvim/lua $HOME/.config/nvim/lua

# Add neovim alias to .bashrc or .zshrc
if [ -f $HOME/.bashrc ]; then
  echo "alias vim=nvim" >> $HOME/.bashrc
fi
if [ -f $HOME/.zshrc ]; then
  echo "alias vim=nvim" >> $HOME/.zshrc
fi
