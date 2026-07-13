#!/usr/bin/env bash

DOTFILES_LOCAL_REPO=~/Projects/Personal/dotfiles

main() {
  clone_dotfiles_repo
  install_homebrew
  install_packages_with_brewfile
  install_claude_code
  setup_git_and_ssh
  setup_symlinks
  setup_macOS_defaults
  update_macOS_login_items
}

clone_dotfiles_repo() {
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

install_packages_with_brewfile() {
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

install_claude_code() {
  info "Installing/updating Claude Code..."
  # Installed via the native installer (not Homebrew) so it self-updates on
  # every run of this script, rather than being pinned to a brewed version.
  if curl -fsSL https://claude.ai/install.sh | bash; then
    success "Claude Code installed/updated successfully!"
  else
    error "Claude Code installation failed!"
    exit 1
  fi

  info "Installing caveman plugin for Claude Code..."
  if claude plugin marketplace add JuliusBrussee/caveman && claude plugin install caveman@caveman; then
    success "caveman plugin installed successfully!"
  else
    error "caveman plugin installation failed!"
    exit 1
  fi
}

setup_git_and_ssh() {
  info "Setting up git config and SSH (from Bitwarden)..."
  local current_dir=$(pwd)
  cd ${DOTFILES_LOCAL_REPO}/git
  if bash setup.sh; then
      cd $current_dir
      success "git config and SSH setup succeeded!"
  else
      cd $current_dir
      error "git config and SSH setup failed!"
      exit 1
  fi
}

setup_symlinks() {
  info "Setting up symlinks..."

  # Disable shell login message
  symlink "hushlogin" /dev/null ~/.hushlogin
  symlink "dotfiles" ${DOTFILES_LOCAL_REPO} ~/.dotfiles
  symlink "terminal/zshrc" ${DOTFILES_LOCAL_REPO}/terminal/zshrc ~/.zshrc
  symlink "terminal/starship.toml" ${DOTFILES_LOCAL_REPO}/terminal/starship.toml ~/.config/starship.toml
  symlink "ssh/config" ${DOTFILES_LOCAL_REPO}/ssh/config ~/.ssh/config
  symlink "ghostty/config" ${DOTFILES_LOCAL_REPO}/ghostty/config ~/.config/ghostty/config
  symlink "claude/settings.json" ${DOTFILES_LOCAL_REPO}/claude/settings.json ~/.claude/settings.json

  success "Symlinks successfully setup!"
}

setup_macOS_defaults() {
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

pull_latest() {
  substep "Pulling latest changes in ${1} repository..."
  if git -C "$1" fetch &> /dev/null && git -C "$1" reset --hard origin/main &> /dev/null; then
    return
  else
    error "Please pull latest changes in ${1} repository manually!"
  fi
}

colored_echo() {
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

info() {
    colored_echo "$1" cyan "========>"
}

success() {
    colored_echo "$1" green "========>"
}

error() {
    colored_echo "$1" red "========>"
}

substep() {
    colored_echo "$1" magenta "===="
}

main "$@"
