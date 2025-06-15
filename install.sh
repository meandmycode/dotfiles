#!/bin/sh

# This script personalizes a new container. It is written in POSIX sh
# for maximum compatibility and handles both root and non-root user scenarios.

set -e # Exit immediately if a command exits with a non-zero status.

# --- Determine if sudo is needed ---
SUDO_CMD=""
# Check if the user is not root (user ID is not 0)
if [ "$(id -u)" -ne 0 ]; then
    # Check if sudo is available
    if command -v sudo >/dev/null 2>&1; then
        SUDO_CMD="sudo"
    else
        echo "Error: Running as non-root user but 'sudo' is not installed."
        exit 1
    fi
fi

# --- Install Zsh and common tools ---
echo "Checking for package manager..."
if command -v apt-get >/dev/null 2>&1; then
    if ! command -v zsh >/dev/null 2>&1; then
        echo "Zsh not found. Installing with apt-get..."
        ${SUDO_CMD} apt-get update
        ${SUDO_CMD} apt-get install -y zsh curl git
    else
        echo "Zsh is already installed."
    fi
elif command -v apk >/dev/null 2>&1; then
    if ! command -v zsh >/dev/null 2>&1; then
        echo "Zsh not found. Installing with apk..."
        ${SUDO_CMD} apk add zsh curl git
    else
        echo "Zsh is already installed."
    fi
else
    echo "Skipping Zsh install: No supported package manager (apt-get, apk) found."
fi

# --- Install Oh My Zsh ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo "Oh My Zsh is already installed."
fi

# --- Set Zsh as the default shell ---
if [ "$(basename "$SHELL")" != "zsh" ]; then
    if command -v chsh >/dev/null 2>&1; then
        echo "Setting Zsh as default shell..."
        # The 'chsh' command usually requires root privileges to modify /etc/passwd
        ${SUDO_CMD} chsh -s "$(command -v zsh)" "$(whoami)"
    else
        echo "Warning: 'chsh' command not found. Cannot set default shell."
    fi
else
    echo "Default shell is already Zsh."
fi

echo "Dotfiles installation complete!"