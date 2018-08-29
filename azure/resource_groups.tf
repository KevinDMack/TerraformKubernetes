

resource "azurerm_resource_group" "app" {
  name = "${coalesce(var.app_resource_group_name, format("%s%s%s-App", upper(var.environment_code), upper(var.deployment_code), upper(var.location_code)))}"
  location = "${var.azure_location}"

  lifecycle {
    ignore_changes = ["name"]
  }
}

resource "azurerm_resource_group" "data" {
  name = "${coalesce(var.data_resource_group_name, format("%s%s%s-Data", upper(var.environment_code), upper(var.deployment_code), upper(var.location_code)))}"
  location = "${var.azure_location}"

  lifecycle {
    ignore_changes = ["name"]
  }
}


resource "azurerm_resource_group" "dmz" {
  name = "${coalesce(var.dmz_resource_group_name, format("%s%s%s-DMZ", upper(var.environment_code), upper(var.deployment_code), upper(var.location_code)))}"
  location = "${var.azure_location}"

  lifecycle {
    ignore_changes = ["name"]
  }
}
resource "azurerm_resource_group" "management" {
  name = "${coalesce(var.management_resource_group_name, format("%s%s%s-Management", upper(var.environment_code), upper(var.deployment_code), upper(var.location_code)))}"
  location = "${var.azure_location}"

  lifecycle {
    ignore_changes = ["name"]
  }
}

resource "azurerm_resource_group" "network" {
  name = "${coalesce(var.network_resource_group_name, format("%s%s%s-Network", upper(var.environment_code), upper(var.deployment_code), upper(var.location_code)))}"
  location = "${var.azure_location}"

  lifecycle {
    ignore_changes = ["name"]
  }
}

resource "azurerm_resource_group" "web" {
  name = "${coalesce(var.network_resource_group_name, format("%s%s%s-Web", upper(var.environment_code), upper(var.deployment_code), upper(var.location_code)))}"
  location = "${var.azure_location}"

  lifecycle {
    ignore_changes = ["name"]
  }
}
resource "azurerm_resource_group" "packer" {
  name = "${format("%s%s%s-Packer", upper(var.environment_code), upper(var.deployment_code), upper(var.location_code))}"
  location = "${var.azure_location}"
}



