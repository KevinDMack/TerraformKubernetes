variable "environment_code" {
  description = "Environment code"
}

variable "deployment_code" {
  description = "Deployment code"
}

variable "location_code" {
  description = "Location code"
}

variable "azure_location" {
  description = "Location in which to deploy resources"
}

variable "azure_environment" {
  description = "Azure environment type"
  default = "public"
}

variable "azure_network_octets" {
  description = "First two octects of data center subnet e.g. the X.Y in X.Y.0.0"
}

variable "platform_fault_domain_count" {
 description = "Fault Domain Count for Azure"
 default = "3"
}

variable "app_resource_group_name" {
  description = "Name of the resource group for application components. e.g. "
  default = ""
}

variable "data_resource_group_name" {
  description = "Name of the resource group for persistence components. e.g. "
  default = ""
}

variable "dmz_resource_group_name" {
  description = "Name of the resource group for dmz components. e.g. "
  default = ""
}

variable "management_resource_group_name" {
  description = "Name of the resource group for management components. e.g. "
  default = ""
}

variable "network_resource_group_name" {
  description = "Name of the resource group for network components. e.g. "
  default = ""
}

# Network name override. Avoid in new deployments.
variable "network_name" {
  description = "Name of the network. e.g. XXXXX-network"
  type = "string"
  default = ""
}
variable "ssh_key" {
  description = "Default user ssh key"
}

variable "subscription_id" {}

variable "instance_counts" {
  description = "Map of os code + type code"
  type = "map"
}

variable "instance_sizes" {
  description = "Map of os code + type code and Azure instance size e.g. lnet => Standard_D3"
  type = "map"
  default = {
    "lnoc" = "Standard_DS2_V2"
    "lovp" = "Standard_DS1_V2"
  }
}

variable "data_disk_sizes" {
  description = "Map of os code + type code and data disk sizes in GB"
  type = "map"
  default = {}
}

variable "os_disk_sizes" {
  description = "Map of os code + type code and is disk sizes in GB"
  type = "map"
  default = {}
}

variable "os_disk_size_default" {
  description = ""
  default = 80
}


variable "data_disk_counts" {
  description = "Map of number of datadisks"
  type = "map"
  default = {}
}

variable "storage_type_default" {
  description = "Default storage type if not specified in storage_account_type"
  default = "Premium_LRS"
}

variable "storage_type" {
  description = "Map of instances to Azure storage types"
  type = "map"
  default = {}
}

variable "subnet" {
  type = "map"
  default = {
    "DMZ"           = "0"
    "Web"           = "1"
    "App"           = "2"
    "Data"          = "3"
    "Management"    = "4"
    "GatewaySubnet" = "5"
  }
}

variable "name_servers" {
  description = "Name server IP list"
  type = "list"
  default = []
}

variable "emtpy_servers" {
  description = "Empty place holder for DNS should Azure DNS be needed"
  type="list"
  default = []
}

variable "enable_vpn_scaffolding" {
  description = "Enable VPN scaffolding which includes Subnet, Puplic IP and Gateway"
  default = 0
}

variable "keyvault_tenantid" {
  description = "The tenent id for the keyvault implementation for kubernetes"
}

variable "keyvault_objectid" {
  description = "The object id of the user to implement for kubernetes with key vault"
  default = ""
}

variable "docker_secret_email" {
  description = "Email address required for configuring docker secret"
}
