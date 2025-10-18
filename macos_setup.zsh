echo "Starting setup"

# Check for Homebrew to be present, install if it's missing
if test ! $(which brew); then
    echo "Installing homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
echo "Homebrew is installed"

# Update homebrew recipes
brew update

# Install packages
PACKAGES=(
    python@3.13
    taiscale
    cocoapods
    git
    ruby
    xcodes
    openvpn
    mas
)
echo "Installing packages..."
brew install ${PACKAGES[@]}

# Install Python packages
echo "Installing Python packages..."
PYTHON_PACKAGES=(
    virtualenv
    virtualenvwrapper
)
sudo pip install ${PYTHON_PACKAGES[@]}

# Install casks
echo "Installing cask..."
CASKS=(
  # Produktivität & Organisation
  1password
  notion
  readdle-spark
  ticktick
  microsoft-excel
  microsoft-word
  microsoft-powerpoint
  obsidian
  raycast
  applite

  # Entwicklung
  android-studio
  jetbrains-toolbox
  postman
  github
  docker-desktop
  textmate
  lm-studio
  openvpn-connect
  windows-app
  utm

  # Design & Kreativität
  figma

  # Kommunikation & Zusammenarbeit
  discord
  mattermost
  slack
  whatsapp
  zoom

  # Medien & Unterhaltung
  spotify
  iina
  steam

  # System & Dienstprogramme
  iterm2
  monitorcontrol
  rectangle
  shottr
  keka
  logi-options+
  jordanbaird-ice
  caffeine
  appcleaner
  chatgpt
  zen
  google-chrome
)
echo "Installing cask apps..."
brew cask install --cask ${CASKS[@]}

echo "Cleaning up..."
brew cleanup

# Install apps from the App Store
echo "Installing App Store apps..."
APP_STORE_APPS=(
    497799835  # Xcode
    1444383602 # GoodNotes 6
)
mas install ${APP_STORE_APPS[@]}

echo "Installing Rosetta Simulators for Xcode..."
xcodebuild -downloadPlatform iOS -architectureVariant universal

echo "Configuring OS..."
# Require password as soon as screensaver or sleep mode starts
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
# Show filename extensions by default
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Enable tap-to-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# Set dock animation speed to fast
defaults write com.apple.dock autohide-time-modifier -float 0.25; killall Dock

echo "Macbook setup completed!"

# credits to https://medium.com/macoclock/automating-your-macos-setup-with-homebrew-and-cask-e2a103b51af1

