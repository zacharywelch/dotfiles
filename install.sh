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

# Remove OpenSearch if already installed or if Elasticsearch is running
if brew list | grep -q opensearch || lsof -i :9200 &>/dev/null; then
  echo "OpenSearch/Elasticsearch already running on port 9200, skipping OpenSearch..."
  sed -i '' '/opensearch/d' Brewfile.temp
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

# Setup asdf plugins only if Ruby isn't already installed system-wide
echo "Setting up asdf..."
if command -v asdf &>/dev/null; then
  if ! asdf plugin list | grep -q ruby; then
    echo "Installing Ruby plugin for asdf..."
    asdf plugin add ruby
  fi
  
  # Only install Ruby if not already available
  if ! command -v ruby &>/dev/null || ! ruby --version | grep -q "3.1.6"; then
    echo "Installing Ruby 3.1.6 via asdf..."
    asdf install ruby 3.1.6
  else
    echo "Ruby already installed, skipping asdf Ruby installation"
  fi
fi

# Only start PostgreSQL if port 5432 is free
if ! lsof -i :5432 &>/dev/null; then
  if brew list | grep -q postgresql@16; then
    echo "Starting postgresql@16..."
    brew services start postgresql@16
  fi
else
  echo "Port 5432 already in use, skipping PostgreSQL startup"
fi

# Only start OpenSearch if port 9200 is free
if ! lsof -i :9200 &>/dev/null; then
  if brew list | grep -q opensearch; then
    echo "Starting opensearch..."
    brew services start opensearch
  fi
else
  echo "Port 9200 already in use, skipping OpenSearch startup"
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
