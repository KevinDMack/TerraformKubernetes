variable "environment_code" {
  description = "Environment code e.g. s or p"
}

variable "deployment_code" {
  description = "Deployment code e.g. us1"
}

variable "location_code" {
  description = "Location code e.g. ue1"
}

variable "os_code" {
  description = "os code: l or w"
}

variable "azure_location" {
  description = "Location in which to deploy resources"
}

variable "instance_count" {
  description = "how many instances (and associated resources) to create"
  default = 1
}

variable "vm_size" {}

variable "load_balancer_pool_exclusions" {
  description = "List of VMs to exclude from load balancer pools. "
  type = "list"
  default = []
}

variable "storage_type" {
  description = "Storage type used for all disks"
  default = "Premium_LRS"
}

variable "instance_type" {}

variable "subnet_id" {}

variable "pip_count" {
  description = "how many public IPs to create"
  default = 0
}

variable "lb_pools_ids" {
  description = "Load balancer pool IDs to add NICs to"
  type = "list"
  default = []
}

variable "resource_group_name" {}

variable "availability_set_id" {
  description = "Availability set for instances."
  default = ""
}

variable "network_security_group_id" {}

variable "os_disk_image_id" {
  description = "OS disk image ID for this subscription"
}

variable "ssh_key" {
  description = "Default user ssh key"
}

variable "ip_forwarding" {
  description = "Enable IP forwarding (OVP, VPN, ...)"
  default = false
}

variable "number_of_vms_in_avset" {
 description = "Number of VMs in a AVset"
}

variable "platform_fault_domain_count" {
 description = "Fault Domain Count for Azure"
 default = "3"
}

variable "data_disk_count" {
 description = "Number of Data Disks to attach"
 default = 0
}
variable "data_disk_size" {
  description = "data disk size in GB"
  default = 0
}

variable "os_disk_size" {
  description = "data disk size in GB"
  default = 80
}

variable "vm_extensions_command" {
  description = "Commands to execute on the vm"
  default = ""
}

variable "lb_backend_address_pool" {
  description = "The ids of the backend address pool for the load balancer"
  default = ""
}