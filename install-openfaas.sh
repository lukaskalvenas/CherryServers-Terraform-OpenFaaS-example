#!/usr/bin/env bash
cd ~
sudo apt install -y curl
sudo apt install -y git
sudo git clone https://github.com/openfaas/faas.git
sudo chmod +x faas-cli.sh
sudo ./faas-cli.sh
