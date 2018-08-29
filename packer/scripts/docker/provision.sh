#! /bin/bash

sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
sudo apt-get install -y gnupg-curl
sudo wget https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs)  stable" 
sudo gpg --keyserver https://download.docker.com/linux/ubuntu/gpg --recv-keys 0EBFCD88
sudo apt-get update -y
sudo apt-get install docker-ce -y --allow-unauthenticated
sudo wget -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo systemctl start docker
sudo systemctl enable docker