#!/usr/bin/env bash

DOTFILES_LOCAL_REPO=~/Projects/Personal/dotfiles

main() {
  ask_for_sudo
  install_homebrew
  clone_dotfiles_repo
  install_packages_with_brewfile
  install_ohmyzsh
  import_gpg_keys
  setup_git
  setup_symlinks
  setup_macOS_defaults
  update_login_items
  update_hosts_file
}

function ask_for_sudo() {
  info "Prompting for sudo password..."
  if sudo --validate; then
    while true; do sudo --non-interactive true; \
      sleep 10; kill -0 "$$" || exit; done 2>/dev/null &
    success "Sudo password correct!"
  else
    error "Sudo password failed!"
    exit 1
  fi
}

function install_homebrew() {
  if [[ $(command -v brew) == "" ]]; then
    info "Installing Hombrew..."
    local url=https://raw.githubusercontent.com/Homebrew/install/master/install
    if /usr/bin/ruby -e "$(curl -fsSL ${url})"; then
      success "Homebrew installation succeeded!"
    else
      error "Homebrew installation failed!"
      exit 1
    fi
  else
    info "Updating Homebrew..."
    brew update
  fi
}

function clone_dotfiles_repo() {
  info "Cloning dotfiles repository into ${DOTFILES_LOCAL_REPO}"
  if test -e $DOTFILES_LOCAL_REPO; then
    substep "${DOTFILES_LOCAL_REPO} already exists"
    pull_latest $DOTFILES_LOCAL_REPO
    success "Pull successful in ${DOTFILES_LOCAL_REPO} repository"
  else
    local url=https://github.com/darenas31415/dotfiles.git
    if git clone "$url" $DOTFILES_LOCAL_REPO; then
      success "Dotfiles repository cloned into ${DOTFILES_LOCAL_REPO}"
    else
      error "Dotfiles repository cloning failed"
      exit 1
    fi
  fi
}

function install_packages_with_brewfile() {
  local BREW_FILE_PATH="${DOTFILES_LOCAL_REPO}/brew/Brewfile"
  info "Installing packages within ${BREW_FILE_PATH}"
  if brew bundle check --file="$BREW_FILE_PATH" &> /dev/null; then
    success "Brewfile's dependencies are already satisfied!"
  else
    if brew bundle --file="$BREW_FILE_PATH"; then
      success "Brewfile installation succeeded!"
    else
      error "Brewfile installation failed!"
      exit 1
    fi
  fi
}

function install_ohmyzsh() {
  info "Installing oh-my-zsh..."
  if [ ! -e ~/.oh-my-zsh ]; then
    local url=https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh
    sh -c "$(curl -fsSL ${url})"
  fi
}

import_gpg_keys() {
  info "Importing GPG keys from Dropbox..."
  local dropbox_gpg=~/Dropbox/dotfiles/gpg
  if [ ! -e $dropbox_gpg ]; then
      error "connect to Dropbox and sync dotfiles folder!"
      exit 1
  fi
  gpg --import $dropbox_gpg/pgp-public-keys.asc
  gpg --import $dropbox_gpg/pgp-private-keys.asc
  gpg --import-ownertrust $dropbox_gpg/pgp-ownertrust.asc
  success "GPG import succeeded!"
}

function setup_git() {
  info "Setting up git defaults..."
  local current_dir=$(pwd)
  cd ${DOTFILES_LOCAL_REPO}/git
  if bash setup.sh; then
      cd $current_dir
      success "git defaults updated successfully!"
  else
      cd $current_dir
      error "git defaults update failed!"
      exit 1
  fi
}

function setup_symlinks() {
  info "Setting up symlinks..."

  # Disable shell login message
  symlink "hushlogin" /dev/null ~/.hushlogin
  symlink "dotfiles" ${DOTFILES_LOCAL_REPO} ~/.dotfiles
  symlink ".ssh/config" ${DOTFILES_LOCAL_REPO}/.ssh/config ~/.ssh/config
  symlink "terminal/custom.zsh" ${DOTFILES_LOCAL_REPO}/terminal/custom.zsh ~/.oh-my-zsh/custom/custom.zsh

  success "Symlinks successfully setup!"
}

function setup_macOS_defaults() {
  info "Updating macOS defaults..."

  local current_dir=$(pwd)
  cd ${DOTFILES_LOCAL_REPO}/macOS
  if bash defaults.sh; then
      cd $current_dir
      success "macOS defaults updated successfully!"
  else
      cd $current_dir
      error "macOS defaults update failed!"
      exit 1
  fi
}

function update_login_items() {
  info "Updating login items..."
  if osascript ${DOTFILES_LOCAL_REPO}/macOS/login_items.applescript &> /dev/null; then
    success "Login items updated successfully!"
  else
    error "Login items update failed!"
    exit 1
  fi
}

function update_hosts_file() {
  info "Updating /etc/hosts..."
  local own_hosts_file_path=${DOTFILES_LOCAL_REPO}/hosts/own_hosts_file
  local downloaded_hosts_file_path=/etc/downloaded_hosts_file

  if sudo cp "${own_hosts_file_path}" /etc/hosts; then
    substep "Copying ${own_hosts_file_path} to /etc/hosts succeeded!"
  else
    error "Copying ${own_hosts_file_path} to /etc/hosts failed!"
    exit 1
  fi

  if sudo curl --silent https://someonewhocares.org/hosts/hosts --output "${downloaded_hosts_file_path}"; then
    substep "hosts file downloaded successfully"

    if cat "${downloaded_hosts_file_path}" | \
      sudo tee -a /etc/hosts > /dev/null; then
      success "/etc/hosts updated"
    else
      error "Failed to update /etc/hosts"
      exit 1
    fi

  else
    error "Failed to download hosts file"
    exit 1
  fi

  sudo rm -f ${downloaded_hosts_file_path}
}

function symlink() {
  application=$1
  point_to=$2
  destination=$3
  destination_dir=$(dirname "$destination")

  if test ! -e "$destination_dir"; then
    substep "Creating ${destination_dir}"
    mkdir -p "$destination_dir"
  fi
  if rm -rf "$destination" && ln -s "$point_to" "$destination"; then
    substep "Symlinking for \"${application}\" done!"
  else
    error "Symlinking for \"${application}\" failed!"
    exit 1
  fi
}

function pull_latest() {
  substep "Pulling latest changes in ${1} repository..."
  if git -C "$1" fetch &> /dev/null && git -C "$1" reset --hard origin/master &> /dev/null; then
    return
  else
    error "Please pull latest changes in ${1} repository manually!"
  fi
}

function coloredEcho() {
  local text="$1";
  local color="$2";
  local arrow="$3";
  if ! [[ $color =~ ^[0-9]$ ]] ; then
    case $(echo "$color" | tr '[:upper:]' '[:lower:]') in
      black) color=0 ;;
      red) color=1 ;;
      green) color=2 ;;
      yellow) color=3 ;;
      blue) color=4 ;;
      magenta) color=5 ;;
      cyan) color=6 ;;
      white|*) color=7 ;;
    esac
  fi
  tput bold;
  tput setaf "$color";
  echo "$arrow $text";
  tput sgr0;
}

function info() {
    coloredEcho "$1" cyan "========>"
}

function success() {
    coloredEcho "$1" green "========>"
}

function error() {
    coloredEcho "$1" red "========>"
}

function substep() {
    coloredEcho "$1" magenta "===="
}

main "$@"
