#!/bin/bash
set -e

echo "🚀 Setting up development environment..."
echo

# Function to ask yes/no questions
ask() {
  while true; do
    read -p "$1 (y/n): " yn
    case $yn in
      [Yy]* ) return 0;;
      [Nn]* ) return 1;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}

# Install Homebrew if not present
if ! command -v brew &> /dev/null; then
  if ask "Install Homebrew?"; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi

# Development tools
if ask "Install development tools (Node, Python, Docker, etc.)?"; then
  echo "Checking for existing installations..."
  cp Brewfile Brewfile.temp

  # Remove PostgreSQL if already installed
  if brew list | grep -q postgresql; then
    echo "PostgreSQL already installed, skipping..."
    sed -i '' '/postgresql/d' Brewfile.temp
  fi

  echo "Installing packages..."
  brew bundle install --file=Brewfile.temp --no-upgrade
  rm Brewfile.temp
fi

# Shell configuration
if ask "Setup shell configuration (.zshrc with starship prompt)?"; then
  echo "Linking shell config..."
  ln -sf ~/dotfiles/.zshrc ~/.zshrc
fi

# Git configuration
if ask "Setup Git configuration?"; then
  echo "Linking Git config..."
  ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
fi

# Ruby/asdf setup
if ask "Setup Ruby development with asdf?"; then
  ln -sf ~/dotfiles/.tool-versions ~/.tool-versions
  
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
fi

# Docker/Colima setup
if ask "Setup Docker with Colima?"; then
  echo "Setting up colima..."
  mkdir -p ~/.colima/default
  ln -sf ~/dotfiles/colima/colima.yaml ~/.colima/default/colima.yaml

  if ! colima status &>/dev/null; then
    if ask "Start Colima now?"; then
      echo "Starting colima..."
      colima start
    fi
  else
    echo "Colima already running"
  fi
fi

# PostgreSQL
if ask "Start PostgreSQL service?"; then
  if ! lsof -i :5432 &>/dev/null; then
    if brew list | grep -q postgresql@16; then
      echo "Starting postgresql@16..."
      brew services start postgresql@16 || echo "Failed to start PostgreSQL, but continuing..."
    fi
  else
    echo "Port 5432 already in use, skipping PostgreSQL startup"
  fi
fi

if ask "Setup Sublime Text 4 settings?"; then
  if [ -d ~/dotfiles/sublime ]; then
    echo "Linking Sublime Text settings..."
    mkdir -p ~/Library/Application\ Support/Sublime\ Text/Packages/User
    cp ~/dotfiles/sublime/* ~/Library/Application\ Support/Sublime\ Text/Packages/User/
  fi
fi

# Terminal profile
if ask "Import terminal profile? (requires manual import)"; then
  echo "💡 Import terminal profile from ~/dotfiles/terminal/Default.terminal manually"
  echo "   Terminal → Preferences → Profiles → Import"
fi

echo
echo "✅ Setup complete!"
echo "💡 Restart your terminal to apply shell changes"
