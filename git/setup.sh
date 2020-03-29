#!/usr/bin/env bash

SIGNINGKEY=$(gpg --list-secret-keys --keyid-format long | grep sec | cut -d' ' -f 4 | cut -d'/' -f 2)

if [ -z "${SIGNINGKEY}" ]; then
  echo "Missing GPG key!"
  exit 1
fi

git config --global commit.gpgsign true
git config --global gpg.program $(which gpg)
git config --global user.signingkey ${SIGNINGKEY}
git config --global user.name $(git log -1 --pretty=format:'%an')
git config --global user.email $(git log -1 --pretty=format:'%ae')
