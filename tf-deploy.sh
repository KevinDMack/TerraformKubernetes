#!/bin/bash -e

THISSCRIPT=${BASH_SOURCE[0]:-$0}

VERBOSE=0

TF_ACTION=plan

TF_CLOUD=azure

export TF_PLUGIN_CACHE_DIR=.terraform/plugin-cache

TF_SECRETS=''

log ()
{
  if [ ! -z "$_system_type" -a "$_system_type" != 'Darwin' ]; then
    echo "$(date --rfc-3339=s) ${THISSCRIPT} $*"
  else
    echo $(date +"%Y-%m-%dT %H:%M:%S%z") ${THISSCRIPT} "$*"
  fi
}

check_environment_is_set()
{
    DO_ERROR=0
    log "Using $(terraform workspace show) workspace"
    log "Checking correct Terraform Environment Variables are set:"
    [ -z "$TF_ENVIRONMENT" ] && { log "Need to set TF_ENVIRONMENT"; DO_ERROR=1; }
    if [ $DO_ERROR = 1 ] ; then
       log "The above Environment Variables are not set."
       log "Please ensure you are using the correct credentials or set these"
       log "variables explicity."
       log "ERROR: EXITING - Can not continue."
       exit 2
    fi
    log "TF_CLOUD: ${TF_CLOUD}"
    log "TF_ENVIRONMENT: ${TF_ENVIRONMENT}"
}

setup_tf_modules()
{
  (cd ${TF_CLOUD} ; terraform init -get=true -get-plugins=true -upgrade=true -verify-plugins=true)
}

show_help() {
cat << EOF
Usage: ${0##*/} [-hv] [-a plan|apply|destroy|import] [-c aws|azure] [-e environment-name] <ARGS>

    -a          terraform action, defaults to plan
    -c          cloud provider, defaults to azure
    -h          show this help message
    -e          environment to stand up, defaults to ${TF_ENVIRONMENT}
    -t          optional -target
    -v          verbose mode. Can be used multiple times for increased
                verbosity
EOF
}

log Starting $0
OPTIND=1 
while getopts "a:c:e:t:hv" opt; do
    case "$opt" in
        a)  TF_ACTION=${OPTARG}
            ;;
        c)  TF_CLOUD=${OPTARG}
            ;;
        e)  TF_ENVIRONMENT=${OPTARG}
            ;;
        t)  TF_TARGET="-target ${OPTARG}"
            ;;
        h)
            show_help
            exit 0
            ;;
        v)  VERBOSE=$((VERBOSE+1))
            ;;
        '?')
            show_help >&2
            exit 1
            ;;
    esac
done
shift "$((OPTIND-1))" 

check_environment_is_set
setup_tf_modules

if [ "$TF_CLOUD" == "azure" ]; then
   TF_SECRETS="-var-file=${TF_ENVIRONMENT}/secrets.tfvars"

    if grep --quiet USGov $TF_CLOUD/${TF_ENVIRONMENT}/environment.tfvars; then
        AZURE_CLOUD="AzureUSGovernment"
    else
        AZURE_CLOUD="AzureCloud"
    fi

    az cloud set --name ${AZURE_CLOUD} 1>/dev/null 2>&1
    echo 'Set cloud to: '${AZURE_CLOUD}

    subscriptionGuid=$(grep subscription_id $TF_CLOUD/${TF_ENVIRONMENT}/environment.tfvars | awk -F= '{print $2}' | sed 's/^[ ]*//;s/\r$//;s/\"//g')
    az account set --subscription $subscriptionGuid

fi

if [ "$TF_ACTION" == "apply" ]; then
  (cd ${TF_CLOUD} ; terraform apply -auto-approve=false -var-file=${TF_ENVIRONMENT}/environment.tfvars $TF_SECRETS -state ${TF_ENVIRONMENT}/terraform.tfstate $TF_TARGET)
else
  (cd ${TF_CLOUD} ; terraform ${TF_ACTION} -var-file=${TF_ENVIRONMENT}/environment.tfvars $TF_SECRETS -state ${TF_ENVIRONMENT}/terraform.tfstate $TF_TARGET $*)
fi

log $0 finished!
