#!/bin/bash

# Update package list
echo "Updating package list..."
sudo apt update

# Install Zsh
echo "Installing Zsh..."
sudo apt install -y zsh

# Check Zsh installation
echo "Checking Zsh installation..."
if [ -z "$(which zsh)" ]; then
  echo "Zsh installation failed."
  exit 1
fi

# Set Zsh as the default shell
echo "Changing default shell to Zsh..."
chsh -s $(which zsh)

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Installation complete. Please restart your terminal or log out and back in to start using Zsh with Oh My Zsh."