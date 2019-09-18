#!/usr/bin/env bash

DOTFILES_LOCAL_REPO=~/Projects/Personal/dotfiles

main() {
  clone_dotfiles_repo
  install_homebrew
  install_packages
  install_ohmyzsh
  setup_symlinks
  setup_macOS_defaults
  update_macOS_login_items
}

clone_dotfiles_repo() {
  info "Cloning dotfiles repository into ${DOTFILES_LOCAL_REPO}"
  if test -e $DOTFILES_LOCAL_REPO; then
    substep "${DOTFILES_LOCAL_REPO} already exists"
    pull_latest $DOTFILES_LOCAL_REPO
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

install_homebrew() {
  if [[ $(command -v brew) == "" ]]; then
    info "Installing Hombrew..."
    local url=https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
    if /bin/bash -c "$(curl -fsSL ${url})"; then
      echo >> ~/.zprofile
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"
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

install_packages() {
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

install_ohmyzsh() {
  info "Installing oh-my-zsh..."
  if [ ! -e ~/.oh-my-zsh ]; then
    local url=https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
    sh -c "$(curl -fsSL ${url})"
  fi
}

setup_symlinks() {
  info "Setting up symlinks..."

  # Disable shell login message
  symlink ~/.hushlogin /dev/null
  symlink ~/.dotfiles "${DOTFILES_LOCAL_REPO}"
  symlink ~/.zshrc "${DOTFILES_LOCAL_REPO}/terminal/zshrc"

  success "Symlinks successfully setup!"
}

setup_macOS_defaults() {
  info "Updating macOS defaults..."

  if bash "${DOTFILES_LOCAL_REPO}/macOS/defaults.sh"; then
    success "macOS defaults updated successfully!"
  else
    error "macOS defaults update failed!"
    exit 1
  fi
}

update_macOS_login_items() {
  info "Updating login items..."
  if osascript ${DOTFILES_LOCAL_REPO}/macOS/login_items.applescript &> /dev/null; then
    success "Login items updated successfully!"
  else
    error "Login items update failed!"
    exit 1
  fi
}

symlink() {
  destination=$1
  point_to=$2
  destination_dir=$(dirname "$destination")

  if test ! -e "$destination_dir"; then
    substep "Creating ${destination}"
    mkdir -p "$destination_dir"
  fi
  if rm -rf "$destination" && ln -s "$point_to" "$destination"; then
    substep "Symlinking for \"${destination}\" done!"
  else
    error "Symlinking for \"${destination}\" failed!"
    exit 1
  fi
}

pull_latest() {
  if [[ -n "$(git -C "$1" status --porcelain)" ]]; then
    error "Skipping pull for ${1}: local changes detected."

    return
  fi

  substep "Pulling latest changes in ${1} repository..."
  if git -C "$1" pull --ff-only &> /dev/null; then
    success "Pull successful in ${DOTFILES_LOCAL_REPO} repository"

    return
  fi

  error "Please pull latest changes in ${1} repository manually!"
}

colored_echo() {
  local text="$1";
  local color="$2";
  local icon="$3";
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
  echo "$icon $text";
  tput sgr0;
}

info() {
  colored_echo "$1" cyan "→"
}

success() {
  colored_echo "$1" green "✔"
}

error() {
  colored_echo "$1" red "✘"
}

substep() {
  colored_echo "$1" magenta "  ↳"
}

main "$@"
