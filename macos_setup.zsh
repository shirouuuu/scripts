#!/usr/bin/env bash

# --- logging helpers -----------------------------------------------------
# Detect whether the terminal supports color
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors)" -ge 8 ]; then
    BOLD="$(tput bold)"
    RESET="$(tput sgr0)"
    RED="$(tput setaf 1)"
    GREEN="$(tput setaf 2)"
    YELLOW="$(tput setaf 3)"
    BLUE="$(tput setaf 4)"
    MAGENTA="$(tput setaf 5)"
    CYAN="$(tput setaf 6)"
else
    BOLD=""
    RESET=""
    RED=""
    GREEN=""
    YELLOW=""
    BLUE=""
    MAGENTA=""
    CYAN=""
fi

log() {
    local prefix="$1"; shift
    printf "%b %s%b\n" "$prefix" "$*" "$RESET"
}

info()    { log "${BLUE}${BOLD}[INFO]${RESET}" "$*"; }
warn()    { log "${YELLOW}${BOLD}[WARN]${RESET}" "$*"; }
success() { log "${GREEN}${BOLD}[OK]${RESET}" "$*"; }
error()   { log "${RED}${BOLD}[ERROR]${RESET}" "$*"; }
title()   { printf "\n%b%s%b\n" "${MAGENTA}${BOLD}" "$*" "${RESET}"; }
# ------------------------------------------------------------------------

title "Starting macOS setup"

# Check for Homebrew to be present, install if it's missing
if ! command -v brew >/dev/null 2>&1; then
    info "Homebrew not found — installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if command -v brew >/dev/null 2>&1; then
        success "Homebrew installed"
    else
        error "Homebrew installation failed"
        exit 1
    fi
else
    success "Homebrew is already installed"
fi

# Update homebrew recipes
info "Updating Homebrew..."
brew update || warn "brew update exited with non-zero status"

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
info "Installing packages: ${PACKAGES[*]}"
brew install ${PACKAGES[@]} || warn "Some brew installs exited non-zero — check output above"

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
info "Installing cask apps..."
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
info "Installing cask apps..."
brew install --cask ${CASKS[@]} || warn "Some cask installs exited non-zero — check output above"

info "Cleaning up Homebrew cache and old versions"
brew cleanup || warn "brew cleanup failed"

# Install apps from the App Store
info "Installing App Store apps via mas"
APP_STORE_APPS=(
    497799835  # Xcode
    1444383602 # GoodNotes 6
)
mas install ${APP_STORE_APPS[@]} || warn "mas install had issues; ensure you're signed in to the App Store"

info "Downloading Xcode iOS platform simulators (Rosetta/universal)"
xcodebuild -downloadPlatform iOS -architectureVariant universal || warn "xcodebuild simulator download may have failed or requires Xcode license acceptance"

title "Configuring macOS settings"
# Require password as soon as screensaver or sleep mode starts
info "Enabling password immediately after screensaver or sleep"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0
# Show filename extensions by default
info "Showing all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Enable tap-to-click
info "Enabling tap-to-click"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# Set dock animation speed to fast
info "Setting Dock autohide animation speed"
defaults write com.apple.dock autohide-time-modifier -float 0.25; killall Dock

success "macOS setup completed!"

# credits to https://medium.com/macoclock/automating-your-macos-setup-with-homebrew-and-cask-e2a103b51af1

