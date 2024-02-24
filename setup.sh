#!/bin/bash

set -e

sudoIfAvailable() {
  if command -v sudo; then
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

  # Install alacrity on macOS
  # Install rust if not already installed
  if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    # Add cargo to PATH
    export PATH="$HOME/.cargo/bin:$PATH"
  fi

  # Use cargo to install alacritty
  cargo install alacritty

  # Copy alacritty config to $HOME/.config/alacritty/alacritty.toml
  mkdir -p $HOME/.config/alacritty/themes
  cp alacritty/alacritty.yml $HOME/.config/alacritty/alacritty.yml

  # Copy alacritty theme files to $HOME/.config/alacritty
  curl -LO --output-dir ~/.config/alacritty/themes https://github.com/catppuccin/alacritty/raw/yaml/catppuccin-latte.yml
  curl -LO --output-dir ~/.config/alacritty/themes https://github.com/catppuccin/alacritty/raw/yaml/catppuccin-frappe.yml
  curl -LO --output-dir ~/.config/alacritty/themes https://github.com/catppuccin/alacritty/raw/yaml/catppuccin-macchiato.yml
  curl -LO --output-dir ~/.config/alacritty/themes https://github.com/catppuccin/alacritty/raw/yaml/catppuccin-mocha.yml
fi

# Linux
if [ "$(uname)" == "Linux" ]; then
  # Install with apt
  export DEBIAN_FRONTEND=noninteractive
  if [ -x "$(command -v apt)" ]; then
    sudoIfAvailable apt-get update
    # Check for git and install if we don't have it
    if test ! $(which git); then
      sudoIfAvailable apt-get install -y git-all
    fi
    sudoIfAvailable apt-get install -y curl
    # Install tmux
    sudoIfAvailable apt-get install -y tmux
    sudoIfAvailable apt-get install -y gcc
  # Install with pacman
  elif [ -x "$(command -v pacman)" ]; then
      sudoIfAvailable pacman -Sy which
    # Check for git and install if we don't have it
    if test ! $(which git); then
      sudoIfAvailable pacman -Sy --noconfirm git
    fi
    sudoIfAvailable pacman -Sy --noconfirm curl
    # Install tmux
    sudoIfAvailable pacman -Sy --noconfirm tmux
    sudoIfAvailable pacman -Sy --noconfirm gcc
  # Install with dnf
  elif [ -x "$(command -v dnf)" ]; then
    # Check for git and install if we don't have it
    sudoIfAvailable dnf install -y which
    if test ! $(which git); then
      sudoIfAvailable dnf install -y git
    fi
    sudoIfAvailable dnf install -y curl
    # Install tmux
    sudoIfAvailable dnf install -y http://galaxy4.net/repo/galaxy4-release-8-current.noarch.rpm
    sudoIfAvailable dnf install -y tmux
    sudoIfAvailable dnf install -y gcc
  # Install with yum
  elif [ -x "$(command -v yum)" ]; then
    sudoIfAvailable yum install -y which
    # Check for git and install if we don't have it
    if test ! $(which git); then
      sudoIfAvailable yum install -y git
    fi
    sudoIfAvailable yum install -y curl
    # Install tmux
    sudoIfAvailable yum install -y http://galaxy4.net/repo/galaxy4-release-8-current.noarch.rpm
    sudoIfAvailable yum install -y tmux
    sudoIfAvailable yum install -y gcc
  # Install with zypper
  elif [ -x "$(command -v zypper)" ]; then
    # Check for git and install if we don't have it
    sudoIfAvailable zypper install -y which tar gzip
    if test ! $(which git); then
      sudoIfAvailable zypper install -y git
    fi
    sudoIfAvailable zypper install -y curl
    # Install tmux
    sudoIfAvailable zypper install -y tmux
    sudoIfAvailable zypper install -y gcc
  # Catch unsupported Linux distros
  else
    echo "Unsupported Linux distro"
    exit 1
  fi

  # Install neovim if not already installed
  if ! command -v nvim &> /dev/null; then
    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
    sudoIfAvailable rm -rf /opt/nvim
    sudoIfAvailable tar -C /opt -xzf nvim-linux64.tar.gz
    sudoIfAvailable ln -s /opt/nvim-linux64/bin/nvim /usr/local/bin/nvim
  fi
fi

# Install kickstart neovim if no existing neovim config
if [ ! -d "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim ]; then
  git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.config}"/nvim
fi


# Install tmux plugin manager if not already installed
if [ ! -d $HOME/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Copy tmux config to $HOME/.tmux.conf
cp tmux/tmux.conf $HOME/.tmux.conf

# Copy neovim config to $HOME/.config/nvim/init.lua
cp nvim/init.lua $HOME/.config/nvim/init.lua

# Add neovim plugin configuration
cp -r nvim/lua $HOME/.config/nvim/

# Add neovim alias to .bashrc or .zshrc
if [ -f $HOME/.bashrc ]; then
  echo "alias vim=nvim" >> $HOME/.bashrc
fi
if [ -f $HOME/.zshrc ]; then
  echo "alias vim=nvim" >> $HOME/.zshrc
fi
