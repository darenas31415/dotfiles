#!/usr/bin/env bash

DOTFILES_LOCAL_REPO=~/Projects/Personal/dotfiles

main() {
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
