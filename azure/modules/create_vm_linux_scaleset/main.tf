
locals {
  base_hostname = "${format("%s%s%s%s%s", var.environment_code, var.deployment_code, var.location_code, var.os_code, var.instance_type)}"
}

resource "azurerm_public_ip" "vm_pip" {
  count = "${var.pip_count}"
  name = "${format("%s%03d", local.base_hostname, count.index + 1)}"
  location = "${var.azure_location}"
  resource_group_name = "${var.resource_group_name}"
  public_ip_address_allocation = "static"
  domain_name_label = "${var.instance_type == "net" ? format("%s%s-%d", var.deployment_code, var.location_code, count.index + 1) : format("%s%03d", local.base_hostname, count.index + 1)}"
}

resource "azurerm_network_interface" "vm_nic" {
  count = "${var.instance_count}"
  name = "${format("%s%03dNetworkInterface", local.base_hostname, count.index + 1)}"
  location = "${var.azure_location}"
  resource_group_name = "${var.resource_group_name}"
  network_security_group_id = "${var.network_security_group_id}"
  enable_ip_forwarding = "${var.ip_forwarding}"

  ip_configuration {
    name = "ipconfig"
    load_balancer_backend_address_pools_ids = ["${compact(split(",", contains(var.load_balancer_pool_exclusions, "${format("%s%03d", local.base_hostname, count.index + 1)}") ? "" : join(",", var.lb_pools_ids)))}"]
    subnet_id = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = "${var.pip_count == 0 ? "" : element(concat(azurerm_public_ip.vm_pip.*.id, list("")), count.index)}"
  }
}

resource "azurerm_storage_account" "diag_storage_account" {
  count = "${var.instance_count}"
  name = "${format("%sstg%03ddiag", local.base_hostname, count.index + 1)}"
  resource_group_name = "${var.resource_group_name}"
  location = "${var.azure_location}"
  account_tier = "Standard"
  account_replication_type = "LRS"
  enable_blob_encryption = "true"
}

resource "azurerm_lb" "vmss" {
 name                = "${var.number_of_vms_in_avset == var.instance_count ? format("%s-lb", local.base_hostname) : format("%s-AVSet%03d", local.base_hostname, count.index + 1)}"
 location            = "${var.azure_location}"
 resource_group_name = "${var.resource_group_name}"

 frontend_ip_configuration {
   name                 = "PublicIPAddress"
   public_ip_address_id = "${azurerm_public_ip.vmss.id}"
 }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
 resource_group_name = "${var.resource_group_name}"
 loadbalancer_id     = "${azurerm_lb.vmss.id}"
 name                = "${var.number_of_vms_in_avset == var.instance_count ? format("%s-beap", local.base_hostname) : format("%s-AVSet%03d", local.base_hostname, count.index + 1)}"
}

resource "azurerm_lb_probe" "vmss" {
 resource_group_name = "${var.resource_group_name}"
 loadbalancer_id     = "${azurerm_lb.vmss.id}"
 name                = "${var.number_of_vms_in_avset == var.instance_count ? format("%s-running-probe", local.base_hostname) : format("%s-AVSet%03d", local.base_hostname, count.index + 1)}"
 port                = "${var.application_port}"
}

resource "azurerm_lb_rule" "lbnatrule" {
   resource_group_name            = "${var.resource_group_name}"
   loadbalancer_id                = "${azurerm_lb.vmss.id}"
   name                           = "${var.nat_rule_name}"
   protocol                       = "Tcp"
   frontend_port                  = "${var.application_port}"
   backend_port                   = "${var.application_port}"
   backend_address_pool_id        = "${azurerm_lb_backend_address_pool.bpepool.id}"
   frontend_ip_configuration_name = "PublicIPAddress"
   probe_id                       = "${azurerm_lb_probe.vmss.id}"
}

resource "azurerm_public_ip" "vmss" {
 name                         = "${var.number_of_vms_in_avset == var.instance_count ? format("%s-pip", local.base_hostname) : format("%s-AVSet%03d", local.base_hostname, count.index + 1)}"
 location                     = "${var.azure_location}"
 resource_group_name          = "${var.resource_group_name}"
 public_ip_address_allocation = "static"
 domain_name_label            = "${var.public_dns_name}"
}

resource "azurerm_virtual_machine_scale_set" "vm" {
  count = "${ var.instance_count}"
  name = "${format("%s%03d", local.base_hostname, count.index + 1)}"
  location = "${var.azure_location}"
  resource_group_name = "${var.resource_group_name}"
  upgrade_policy_mode = "Manual"

  lifecycle {
    #prevent_destroy = true
  }

  sku {
    name = "${var.vm_size}"
    tier = ""
    capacity = "${var.instance_count}"
  }

  storage_profile_image_reference {
   id = "${var.os_disk_image_id}"
  }

  storage_profile_os_disk {
    name              = "${format("%s%03d", local.base_hostname, count.index + 1)}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${var.storage_type}"
  }

  os_profile {
    computer_name_prefix = "${format("%s%03d", local.base_hostname, count.index + 1)}"
    admin_username = "uadmin"
  }

  boot_diagnostics {
    enabled = false
    storage_uri = "${element(azurerm_storage_account.diag_storage_account.*.primary_blob_endpoint, count.index)}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys = [
      {
        path = "/home/uadmin/.ssh/authorized_keys"
        key_data = "${var.ssh_key}"
      }]
  }

  network_profile {
    name="IPConfiguration"
    primary = true

    ip_configuration {
      name = "${format("%s%03dNetworkInterface", local.base_hostname, count.index + 1)}_Configuration"
      subnet_id = "${var.subnet_id}"
      primary = true
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.bpepool.id}"]
      load_balancer_inbound_nat_rules_ids    = ["${element(azurerm_lb_rule.lbnatrule.id, count.index)}"]
    }
  }
}

 resource "azurerm_virtual_machine_extension" "vm_extension" {
  count                = "${var.instance_count}"
  name                 = "CustomScript"
  location             = "${var.azure_location}"
  resource_group_name  = "${var.resource_group_name}"
  virtual_machine_name = "${element(azurerm_virtual_machine_scale_set.vm.*.name, count.index)}"
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
    {
        "commandToExecute": "${var.vm_extensions_command}"
    }
SETTINGS
}
