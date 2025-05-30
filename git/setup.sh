#!/usr/bin/env bash

dropbox_dir=~/Dropbox/dotfiles
for directory in $dropbox_dir/*; do
  profile=$(basename $directory)
  content=$(gpg --import-options show-only --import $directory/gpg/public-key.asc)
  username=$(echo $content | sed -E 's/.*uid (.*) <.*/\1/')
  email=$(echo $content | sed -E 's/.*<(.*)>.*/\1/')
  signingkey=$(echo $content | sed -E 's/.*\[SC\] (.*) uid.*/\1/')
  cat <<EOT >> ~/.gitconfig-${profile}
[user]
    signingkey = ${signingkey}
    name = ${username}
    email = ${email}
[core]
    sshCommand = "ssh -i ~/.ssh/${profile}/id_rsa"

EOT
done

cat <<EOT >> ~/.gitconfig
[commit]
    gpgsign = true
[gpg]
    program = /usr/local/bin/gpg
[core]
    excludesfile = ~/.gitignore_global
[includeIf "gitdir:~/Projects/Personal/"]
    path = ~/.gitconfig-personal
[includeIf "gitdir:~/Projects/Work/"]
    path = ~/.gitconfig-work
EOT

cat <<EOT >> ~/.gitignore_global
.DS_Store
.idea
.scratch

EOT
