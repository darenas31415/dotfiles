#!/usr/bin/env bash

# Install packages
sudo apt update -y -qq
sudo apt full-upgrade -y -qq
sudo apt install -y -qq \
            apt-transport-https \
            ca-certificates \
            chromium-browser \
            curl \
            firefox \
            git \
            gnupg-agent \
            gpg \
            jq \
            software-properties-common \
            zsh

# Install docker
if ! [ -x "$(command -v docker)" ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt install -y -qq docker-ce docker-ce-cli containerd.io
  sudo usermod -aG docker $USER
fi

# Install docker-compose
if ! [ -x "$(command -v docker-compose)" ]; then
  DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq .name -r)
  DOCKER_COMPOSE_BINARY=/usr/local/bin/docker-compose
  sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o "${DOCKER_COMPOSE_BINARY}"
  sudo chmod +x "${DOCKER_COMPOSE_BINARY}"
fi

flatpak install -y flathub com.dropbox.Client
flatpak install -y flathub com.jetbrains.PhpStorm

# Clean
sudo apt autoremove -y -qq
sudo apt clean -y -qq
sudo apt autoclean -y -qq
