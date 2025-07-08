#!/bin/bash
set -e

echo "🚀 Setting up development environment..."

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install all packages from Brewfile
echo "Installing packages from Brewfile..."
brew bundle install

# Link dotfiles
echo "Linking dotfiles..."
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig

# Setup colima config
echo "Setting up colima..."
mkdir -p ~/.colima/default
ln -sf ~/dotfiles/colima/colima.yaml ~/.colima/default/colima.yaml

# Start services
echo "Starting services..."
brew services start postgresql@16
brew services start opensearch

# Start colima with your settings
echo "Starting colima..."
colima start

echo "✅ Setup complete! Restart your terminal."
echo "💡 Don't forget to configure asdf plugins if you use them"
echo "💡 Import terminal profile from ~/dotfiles/terminal/Default.terminal manually"
