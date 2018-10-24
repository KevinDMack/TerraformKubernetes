
resource "azurerm_network_security_group" "lkma" {
  name = "${var.environment_code}${var.deployment_code}${var.location_code}lkma-nsg"
  location = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.management.name}"
  count = "${lookup(var.instance_counts, "lkma", 0) == 0 ? 0 : 1}"

  security_rule {
    name = "SSH"
    priority = 105
    direction = "Inbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name = "kubernetes_outbound"
    priority = 110
    direction = "Outbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "6443"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes_inbound"
    priority = 111
    direction = "Inbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "6443"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes_master_inbound"
    priority = 112
    direction = "Inbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "443"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes_etcd_server_api_inbound"
    priority = 113
    direction = "Inbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "2379-2380"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes_kubelet_api_inbound"
    priority = 114
    direction = "Inbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "10250"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes_kubelet_scheduler_inbound"
    priority = 115
    direction = "Inbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "10251"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes_controller_inbound_10252"
    priority = 116
    direction = "Inbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "10252"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes_controller_inbound_10255"
    priority = 117
    direction = "Inbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "10255"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes_etcd_server_api_outbound"
    priority = 118
    direction = "Outbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "2379-2380"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes_kubelet_api_outbound"
    priority = 119
    direction = "Outbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "10250"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes_kubelet_scheduler_outbound"
    priority = 120
    direction = "Outbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "10251"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes_controller_outbound_10252"
    priority = 121
    direction = "Outbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "10252"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes_controller_outbound_10255"
    priority = 122
    direction = "Outbound"
    access = "Allow"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "10255"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
}

module "lkma" {
  source = "modules/create_vm_linux"
  os_code = "l"
  instance_type = "kma"
  ssh_key = "${var.ssh_key}"
  number_of_vms_in_avset = "${lookup(var.instance_counts, "lkma", 0)}"
  platform_fault_domain_count = "${var.platform_fault_domain_count}"
  environment_code = "${var.environment_code}"
  deployment_code = "${var.deployment_code}"
  location_code = "${var.location_code}"
  azure_location = "${var.azure_location}"
  instance_count = "${lookup(var.instance_counts, "lkma", 0)}"
  pip_count = "${lookup(var.instance_counts, "lkma", 0)}"
  vm_size = "${lookup(var.instance_sizes, "lkma", "")}"
  subnet_id = "${azurerm_subnet.management.id}"
  resource_group_name = "${azurerm_resource_group.management.name}"
  network_security_group_id = "${lookup(var.instance_counts, "lkma", 0) == 0 ? "" : element(concat(azurerm_network_security_group.lkma.*.id, list("")), 0)}"
  storage_type = "${lookup(var.storage_type, "lkma", var.storage_type_default)}"
  os_disk_image_id = "${data.azurerm_image.ubuntu.id}"
  os_disk_size = "${lookup(var.os_disk_sizes, "lkma", var.os_disk_size_default)}"
  data_disk_count = "${lookup(var.data_disk_counts, "lkma", 0)}"
  data_disk_size = "${lookup(var.data_disk_sizes, "lkma", 0)}"
  vm_extensions_command = "sudo /var/tmp/kubemaster.sh '${element(concat(azurerm_azuread_application.kub-ad-app-kv1.*.application_id, list("")), 0)}' '${element(concat(random_string.kub-rs-pd-kv.*.result, list("")), 0)}' '${var.environment_code}${var.deployment_code}${var.location_code}lkub-kv1' '${var.keyvault_tenantid}'"
}
