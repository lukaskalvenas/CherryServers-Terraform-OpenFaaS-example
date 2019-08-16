#!/usr/bin/env bash
while sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1; done;
sudo apt-get update; apt-get upgrade -y 
sudo apt-get install -y jq
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
sudo apt-get update
sudo apt-get install -y docker-ce --allow-unauthenticated 
