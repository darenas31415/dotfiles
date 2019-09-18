#!/usr/bin/env bash

set -euo pipefail

# Requires a Bitwarden vault containing "SSH key" items named "git-personal"
# and "git-work", each with custom text fields "name" and "email" set
# alongside the SSH keypair. Field names assumed from Bitwarden's docs
# (sshKey.publicKey, custom fields array) — verify with:
#   bw get item git-personal | jq
# if this doesn't produce the expected output.

profiles=(personal work)

mkdir -p ~/.ssh
chmod 700 ~/.ssh

if [ "$(bw status | jq -r .status)" != "unlocked" ]; then
  BW_SESSION="$(bw unlock --raw)"
  export BW_SESSION
fi

allowed_signers=""

for profile in "${profiles[@]}"; do
  item=$(bw get item "git-${profile}")
  name=$(echo "$item" | jq -r '.fields[] | select(.name=="name") | .value')
  email=$(echo "$item" | jq -r '.fields[] | select(.name=="email") | .value')
  signingkey=$(echo "$item" | jq -r '.sshKey.publicKey')

  if [ -z "$name" ] || [ -z "$email" ] || [ -z "$signingkey" ] || [ "$signingkey" = "null" ]; then
    echo "git-${profile}: couldn't read name/email/signingkey from Bitwarden - check field names" >&2
    exit 1
  fi

  printf '%s\n' "$signingkey" > ~/.ssh/git-"${profile}".pub
  chmod 644 ~/.ssh/git-"${profile}".pub

  cat <<EOT > ~/.gitconfig-"${profile}"
[user]
    name = ${name}
    email = ${email}
    signingkey = ${signingkey}
[core]
    sshCommand = "ssh -i $HOME/.ssh/git-${profile}.pub -o IdentitiesOnly=yes -o IdentityAgent=$HOME/.bitwarden-ssh-agent.sock"
EOT

  allowed_signers+="${email} ${signingkey}"$'\n'
done

printf '%s' "$allowed_signers" > ~/.ssh/allowed_signers
