#! /bin/bash

sudo apt-get update -y
sudo apt-get upgrade -y

#Azure-CLI
AZ_REPO=$(sudo lsb_release -cs)
sudo echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo apt-get install apt-transport-https
sudo apt-get update && sudo apt-get install azure-cli