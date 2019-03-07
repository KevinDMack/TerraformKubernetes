#! /bin/bash

echo 'Executing kubenode.sh'
#Grab the location from IMDS to determine if this is AzureCloud or AzureUSGovernment
location=$(curl -sH Metadata:true "http://169.254.169.254/metadata/instance/compute/location?api-version=2017-08-01&format=text")
cloud="AzureCloud"
if [[ $location == "USGovIowa" ]]; then cloud="AzureUSGovernment"; fi
if [[ $location == "USGovTexas" ]]; then cloud="AzureUSGovernment"; fi
if [[ $location == "USGovVirginia" ]]; then cloud="AzureUSGovernment"; fi
if [[ $location == "USGovArizona" ]]; then cloud="AzureUSGovernment"; fi
echo "cloud = $cloud"
echo "location = $location"
sudo apt-get install -y jq
sudo az cloud set --name $cloud
sudo az login --service-principal -u $1 -p $2 -t $4
cmd=""
isSuccessful=0
echo 'Starting Loop'
while :
do
     echo 'Loop Started'
     echo 'Retrieving Key vault information'
     cmd=$(echo "$(sudo az keyvault secret show --vault-name $3 --name JoinCommand)" | jq -r '.value') || sleep 10s
     echo "$cmd"
     echo 'Checking if command is populated'
     echo "Command = *$cmd*"
     if [$cmd -eq ""]; then
        echo 'Sleeping 10s'
        sleep 10s
     else
        echo 'Command to Run'
        echo $cmd
        echo 'Run Join Command'
        ($cmd)
        break
     fi
done
echo 'Completed Successfully'

