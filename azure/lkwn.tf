
resource "azurerm_network_security_group" "lkwn" {
  name = "${var.environment_code}${var.deployment_code}${var.location_code}lkwn-nsg"
  location = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.data.name}"
  count = "${lookup(var.instance_counts, "lkwn", 0) == 0 ? 0 : 1}"

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
    access = "${lookup(var.instance_counts, "lkma", 0) == 0 ? "Block" : "Allow"}"
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
    access = "${lookup(var.instance_counts, "lkma", 0) == 0 ? "Block" : "Allow"}"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "6443"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes_kublet_api_inbound"
    priority = 112
    direction = "Inbound"
    access = "${lookup(var.instance_counts, "lkma", 0) == 0 ? "Block" : "Allow"}"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "10250"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes_readonly_api_inbound"
    priority = 113
    direction = "Inbound"
    access = "${lookup(var.instance_counts, "lkma", 0) == 0 ? "Block" : "Allow"}"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "10255"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes_nodeport_inbound"
    priority = 114
    direction = "Inbound"
    access = "${lookup(var.instance_counts, "lkma", 0) == 0 ? "Block" : "Allow"}"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "30000-32767"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes__kublet_api_outbound"
    priority = 115
    direction = "Outbound"
    access = "${lookup(var.instance_counts, "lkma", 0) == 0 ? "Block" : "Allow"}"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "10250"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes_readonly_api_outbound"
    priority = 116
    direction = "Outbound"
    access = "${lookup(var.instance_counts, "lkma", 0) == 0 ? "Block" : "Allow"}"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "10255"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
  security_rule {
    name = "kubernetes_nodeport_outbound"
    priority = 117
    direction = "Outbound"
    access = "${lookup(var.instance_counts, "lkma", 0) == 0 ? "Block" : "Allow"}"
    protocol = "TCP"
    source_port_range = "*"
    destination_port_range = "30000-32767"
    source_address_prefix = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }
}

resource "azurerm_lb" "lb_int" {
  name = "${var.environment_code}${var.deployment_code}${var.location_code}lkwn-lb-int"
  resource_group_name = "${azurerm_resource_group.data.name}"
  count = "${lookup(var.instance_counts, "lkwn", 0) == 0 ? 0 : 1}"
  location = "${var.azure_location}"

  frontend_ip_configuration {
    name = "loadBalancerFrontEnd"
    subnet_id = "${azurerm_subnet.data.id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "lb_int_backend_pool" {
 name = "${var.environment_code}${var.deployment_code}${var.location_code}-lkwn-pool"
 resource_group_name = "${azurerm_resource_group.data.name}"
 count = "${lookup(var.instance_counts, "lkwn", 0) == 0 ? 0 : 1}"
 loadbalancer_id = "${azurerm_lb.lb_int.id}"
}
resource "azurerm_lb_probe" "lb_int_postres_probe" {
 resource_group_name = "${azurerm_resource_group.data.name}"
 count = "${lookup(var.instance_counts, "lkwn", 0) == 0 ? 0 : 1}"
 loadbalancer_id = "${azurerm_lb.lb_int.id}"
 name = "postres"
 port = 5432
 interval_in_seconds = 5
}

resource "azurerm_lb_rule" "lb_int_kwn_rule" {
 resource_group_name = "${azurerm_resource_group.data.name}"
 count = "${lookup(var.instance_counts, "lkwn", 0) == 0 ? 0 : 1}"
 loadbalancer_id = "${azurerm_lb.lb_int.id}"
 name = "postres-lbrule"
 protocol = "TCP"
 frontend_port = 5432
 backend_port = 5432
 frontend_ip_configuration_name = "loadBalancerFrontEnd"  
 backend_address_pool_id = "${azurerm_lb_backend_address_pool.lb_int_backend_pool.id}"
 probe_id = "${azurerm_lb_probe.lb_int_postres_probe.id}"
}

module "lkwn" {
  source = "modules/create_vm_linux"
  os_code = "l"
  instance_type = "kwn"
  ssh_key = "${var.ssh_key}"
  number_of_vms_in_avset = "${lookup(var.instance_counts, "lkwn", 0)}"
  platform_fault_domain_count = "${var.platform_fault_domain_count}"
  environment_code = "${var.environment_code}"
  deployment_code = "${var.deployment_code}"
  location_code = "${var.location_code}"
  azure_location = "${var.azure_location}"
  instance_count = "${lookup(var.instance_counts, "lkwn", 0)}"
  pip_count = "${lookup(var.instance_counts, "lkwn", 0)}"
  vm_size = "${lookup(var.instance_sizes, "lkwn", "")}"
  subnet_id = "${azurerm_subnet.data.id}"
  lb_pools_ids = ["${lookup(var.instance_counts, "lkwn", 0) == 0 ? "" : element(concat(azurerm_lb_backend_address_pool.lb_int_backend_pool.*.id, list("")), 0)}"]
  resource_group_name = "${azurerm_resource_group.data.name}"
  network_security_group_id = "${lookup(var.instance_counts, "lkwn", 0) == 0 ? "" : element(concat(azurerm_network_security_group.lkwn.*.id, list("")), 0)}"
  storage_type = "${lookup(var.storage_type, "lkwn", var.storage_type_default)}"
  os_disk_image_id = "${data.azurerm_image.ubuntu.id}"
  os_disk_size = "${lookup(var.os_disk_sizes, "lkwn", var.os_disk_size_default)}"
  data_disk_count = "${lookup(var.data_disk_counts, "lkwn", 0)}"
  data_disk_size = "${lookup(var.data_disk_sizes, "lkwn", 0)}"
  vm_extensions_command = "${lookup(var.instance_counts, "lkma", 0) == 0 ? "" : "sudo /var/tmp/kubenode.sh '${element(concat(azurerm_azuread_application.kub-ad-app-kv1.*.application_id,list("")), 0)}' '${element(concat(random_string.kub-rs-pd-kv.*.result, list("")), 0)}' '${var.environment_code}${var.deployment_code}${var.location_code}lkub-kv1' '${var.keyvault_tenantid}'"}"
}
