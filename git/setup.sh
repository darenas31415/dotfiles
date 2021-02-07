#!/usr/bin/env bash

SIGNINGKEY=$(gpg --list-secret-keys --keyid-format long | grep sec | cut -d' ' -f 4 | cut -d'/' -f 2)

if [ -z "${SIGNINGKEY}" ]; then
  echo "Missing GPG key!"
  exit 1
fi

USER_EMAIL=$(gpg --list-secret-keys --keyid-format long | grep uid | grep -o '[[:alnum:]+\.\_\-]*@[[:alnum:]+\.\_\-]*')

git config --global commit.gpgsign true
git config --global gpg.program $(which gpg)
git config --global user.signingkey ${SIGNINGKEY}
git config --global user.name $(git log -1 --pretty=format:'%an')
git config --global user.email ${USER_EMAIL}
git config --global core.excludesfile ~/.gitignore_global

cat <<EOT >> ~/.gitignore_global
.DS_Store
.idea

EOT
