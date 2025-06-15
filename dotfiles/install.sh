#!/bin/sh

set -e

# --- Install Zsh and common tools ---
# Check if apt-get is available
if command -v apt-get >/dev/null 2>&1; then
    # Check if zsh is already installed
    if ! command -v zsh >/dev/null 2>&1; then
        echo "Zsh not found. Installing..."
        # The 'sudo' is important because the script may run as a non-root user
        sudo apt-get update
        sudo apt-get install -y zsh curl git
    else
        echo "Zsh is already installed."
    fi
# You could add more package manager checks here (e.g., apk for Alpine, dnf for Fedora)
elif command -v apk >/dev/null 2>&1; then
    if ! command -v zsh >/dev/null 2>&1; then
        echo "Zsh not found. Installing with apk..."
        sudo apk add zsh curl git
    else
        echo "Zsh is already installed."
    fi
else
    echo "Skipping Zsh install: apt-get or apk not found."
fi

# --- Install Oh My Zsh ---
# Use the HOME environment variable for the path, which is very portable.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    # The installer script itself is run with sh, making it compatible.
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh is already installed."
fi

# --- Set Zsh as the default shell ---
# Check if the user's shell is already Zsh. Use `basename` for safety.
if [ "$(basename "$SHELL")" != "zsh" ]; then
    # Only try to change shell if 'chsh' command exists
    if command -v chsh >/dev/null 2>&1; then
        echo "Setting Zsh as default shell..."
        sudo chsh -s "$(command -v zsh)" "$(whoami)"
    else
        echo "Warning: 'chsh' command not found. Cannot set default shell."
    fi
else
    echo "Default shell is already Zsh."
fi

echo "Dotfiles installation complete!"