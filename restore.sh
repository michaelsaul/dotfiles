#!/bin/sh

echo "Setting up your Mac..."

#Check for Xcode tools and install if we don't have it
if test ! $(which xcode-select -p);then
  echo "Installing Xcode tools..."
  xcode-select --install
fi

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Update homebrew

brew update
brew tap homebrew/bundle
brew tap azure/functions
brew bundle

# Remove .zshrc from $HOME (if it exists) and symlinks the .zshrc file from the .dotfiles
echo "Linking dotfiles..."
rm -rf $HOME/.zshrc
ln -s $HOME/.dotfiles/.zshrc $HOME/.zshrc

rm -rf $HOME/.aliases.zsh
ln -s $HOME/.dotfiles/.aliases.zsh $HOME/.aliases.zsh