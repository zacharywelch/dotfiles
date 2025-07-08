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

# Check what's already installed and remove from Brewfile temporarily
echo "Checking for existing installations..."
cp Brewfile Brewfile.temp

# Remove PostgreSQL if already installed
if brew list | grep -q postgresql; then
  echo "PostgreSQL already installed, skipping..."
  sed -i '' '/postgresql/d' Brewfile.temp
fi

# Install remaining packages
echo "Installing packages..."
brew bundle install --file=Brewfile.temp --no-upgrade
rm Brewfile.temp

# Link dotfiles
echo "Linking dotfiles..."
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/.tool-versions ~/.tool-versions

# Setup colima config
echo "Setting up colima..."
mkdir -p ~/.colima/default
ln -sf ~/dotfiles/colima/colima.yaml ~/.colima/default/colima.yaml

# Setup asdf plugins
echo "Setting up asdf..."
if command -v asdf &>/dev/null; then
  if ! asdf plugin list | grep -q ruby; then
    echo "Installing Ruby plugin for asdf..."
    asdf plugin add ruby
  fi
  
  if ! asdf current ruby &>/dev/null; then
    echo "Installing Ruby 3.1.6 via asdf..."
    asdf install ruby 3.1.6
  else
    echo "Ruby already managed by asdf"
  fi
fi

# Only start PostgreSQL if port 5432 is free
if ! lsof -i :5432 &>/dev/null; then
  if brew list | grep -q postgresql@16; then
    echo "Starting postgresql@16..."
    brew services start postgresql@16 || echo "Failed to start PostgreSQL, but continuing..."
  fi
else
  echo "Port 5432 already in use, skipping PostgreSQL startup"
fi

# Start colima if not running
if ! colima status &>/dev/null; then
  echo "Starting colima..."
  colima start
else
  echo "Colima already running"
fi

echo "✅ Setup complete!"
echo "💡 Import terminal profile from ~/dotfiles/terminal/Default.terminal manually"
