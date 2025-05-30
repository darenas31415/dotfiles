#!/usr/bin/env bash

main() {
  configure_dock
  configure_finder
  configure_iterm
}

function configure_dock() {
  # Don’t show recent applications in Dock
  defaults write com.apple.dock show-recents -bool false
  # Set the icon size of Dock items to 48 pixels
  defaults write com.apple.dock tilesize -int 48
  # Remove all (default) app icons from the Dock
  defaults write com.apple.dock persistent-apps -array
  defaults write com.apple.dock recent-apps -array
  # Add custom apps to the Dock
  declare -a apps=("Google Chrome" "Firefox" "PhpStorm" "Sourcetree" "iTerm" "Slack")
  for app in "${apps[@]}"
  do
    defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/${app}.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
  done
  # Automatically hide and show the Dock
  defaults write com.apple.dock autohide -bool true
  # Quit Dock to rollout the changes
  quit "Dock"
}

function configure_finder() {
  # Save screenshots to Downloads folder
  defaults write com.apple.screencapture location -string "${HOME}/Downloads"
  # Require password immediately after sleep or screen saver begins
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0
  # allow quitting via ⌘ + q; doing so will also hide desktop icons
  defaults write com.apple.finder QuitMenuItem -bool true
  # disable window animations and Get Info animations
  defaults write com.apple.finder DisableAllAnimations -bool true
  # Set Downloads as the default location for new Finder windows
  defaults write com.apple.finder NewWindowTarget -string "PfLo"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Downloads/"
  # disable status bar
  defaults write com.apple.finder ShowStatusBar -bool false
  # disable path bar
  defaults write com.apple.finder ShowPathbar -bool false
  # Display full POSIX path as Finder window title
  defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
  # Keep folders on top when sorting by name
  defaults write com.apple.finder _FXSortFoldersFirst -bool true
  # When performing a search, search the current folder by default
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
  # Use list view in all Finder windows by default
  # Four-letter codes for view modes: icnv, clmv, Flwv, Nlsv
  defaults write com.apple.finder FXPreferredViewStyle -string clmv
  # Disable the warning before emptying the Trash
  defaults write com.apple.finder WarnOnEmptyTrash -bool false
  # Set tap to click as true
  defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
}

function configure_iterm() {
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "${HOME}/.dotfiles/macOS/iTerm"
}

function quit() {
  app=$1
  killall "$app" > /dev/null 2>&1
}

main "$@"
