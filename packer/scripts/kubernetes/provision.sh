#! /bin/bash

echo "1"
sudo wget https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add
echo "2"
sudo add-apt-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main "
echo "3"
sudo touch /etc/apt/sources.list.d/kubernetes.list 
echo "4"
sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
echo "5"
sudo apt-get update -y
echo "6"
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni --allow-unauthenticated
sudo apt-get install -y jq