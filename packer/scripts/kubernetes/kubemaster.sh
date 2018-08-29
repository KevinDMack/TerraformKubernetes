#! /bin/bash

echo 'Executing kubemaster.sh'
#Grab the location from IMDS to determine if this is AzureCloud or AzureUSGovernment
location=$(curl -sH Metadata:true "http://169.254.169.254/metadata/instance/compute/location?api-version=2017-08-01&format=text")
cloud="AzureCloud"
if [[ $location == USGov* ]]; then cloud="AzureUSGovernment"; fi
echo "cloud = $cloud"
echo "location = $location"
echo 'Initiate Kube Master Node'
sudo kubeadm init
echo 'Updating permissions to run Kubernetes'
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo 'Log into Azure CLI'
sudo az cloud set --name $cloud
sudo az login --service-principal -u $1 -p $2 -t $4
echo 'Push print command to KeyVault'
sudo az keyvault secret set --vault-name $3 --name 'JoinCommand' --value "sudo $(sudo kubeadm token create --print-join-command)"
echo 'Configure permissions for uadmin'
sudo mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown uadmin:uadmin $HOME/.kube/config
echo 'Configure networking for cluster'
kubectl apply --filename https://git.io/weave-kube-1.6
echo 'Script Completed'