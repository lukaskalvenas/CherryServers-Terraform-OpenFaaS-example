#!/usr/bin/env bash
cd ~
sudo apt install -y curl
sudo apt install -y git
sudo git clone https://github.com/openfaas/faas.git
sudo curl -sSL -o faas-cli.sh https://cli.openfaas.com
sudo chmod +x faas-cli.sh
sudo ./faas-cli.sh
