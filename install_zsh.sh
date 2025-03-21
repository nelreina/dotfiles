#!/bin/bash
# Update package list
echo "Updating package list..."
sudo apt update

# Install Zsh
echo "Installing Zsh..."
sudo apt install -y zsh
sudo apt install -y stow
sudo apt install -y zoxide

# Check Zsh installation
echo "Checking Zsh installation..."
if [ -z "$(which zsh)" ]; then
  echo "Zsh installation failed."
  exit 1
fi

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

rm ~/.zshrc
rm ~/.tmux.conf
cd zsh
stow -t ~ remote
# First clone the repo
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git $ZSH_CUSTOM/plugins/zsh-autocomplete

# Set Zsh as the default shell
# echo "Changing default shell to Zsh..."
# chsh -s $(which zsh)

echo "Installation complete. Please restart your terminal or log out and back in to start using Zsh with Oh My Zsh."
