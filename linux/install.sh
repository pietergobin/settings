#!/bin/bash

pkgs=(fzf zsh kubectx git golang-go tree unzip)
sudo apt-get -y --ignore-missing install "${pkgs[@]}" 


curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"

OK="$(cat kubectl.sha256)  kubectl" | sha256sum --check

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

sudo rm -rf kubectl
sudo rm kubectl.sha256

go install github.com/asdf-vm/asdf/cmd/asdf@v0.16.0
sudo mv go/bin/asdf /usr/local/bin/asdf

asdf plugin add kubelogin
asdf install kubelogin latest
asdf set kubelogin latest

curl -o ~./zshrc "https://raw.githubusercontent.com/pietergobin/settings/refs/heads/main/linux/.zshrc"

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --keep-zshrc