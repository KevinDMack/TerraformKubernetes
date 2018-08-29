resource "azurerm_virtual_network" "network" {
  name = "${coalesce(var.network_name, format("%s%s%s-net", upper(var.environment_code), upper(var.deployment_code), upper(var.location_code)))}"
  resource_group_name = "${azurerm_resource_group.network.name}"
  address_space = ["${var.azure_network_octets}.0.0/16"]
  location = "${var.azure_location}"

  dns_servers = ["${contains(var.name_servers,"0.0.0.0") == true ? "" : element(concat(var.name_servers,list("")),0)}"]

  lifecycle {
    ignore_changes = [
      "name"
    ]
  }
}

resource "azurerm_subnet" "dmz" {
  name = "DMZ"
  resource_group_name = "${azurerm_resource_group.network.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix = "${var.azure_network_octets}.${var.subnet["DMZ"]}.0/24"
  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "web" {
  name = "Web"
  resource_group_name = "${azurerm_resource_group.network.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix = "${var.azure_network_octets}.${var.subnet["Web"]}.0/24"
  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "app" {
  name = "App"
  resource_group_name = "${azurerm_resource_group.network.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix = "${var.azure_network_octets}.${var.subnet["App"]}.0/24"
  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "data" {
  name = "Data"
  resource_group_name = "${azurerm_resource_group.network.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix = "${var.azure_network_octets}.${var.subnet["Data"]}.0/24"
  service_endpoints = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "management" {
  name = "Management"
  resource_group_name = "${azurerm_resource_group.network.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix = "${var.azure_network_octets}.${var.subnet["Management"]}.0/24"
  service_endpoints = ["Microsoft.Storage"]
}

#Start VPN Configuration

resource "azurerm_subnet" "gateway" {
  count = "${var.enable_vpn_scaffolding}"
  name = "GatewaySubnet"
  resource_group_name = "${azurerm_resource_group.network.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix = "${var.azure_network_octets}.${var.subnet["GatewaySubnet"]}.0/24"
}

resource "azurerm_public_ip" "gatewayip" {
  count = "${var.enable_vpn_scaffolding}"
  name = "${format("%s-gateway-pip", azurerm_virtual_network.network.name)}"
  location = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.network.name}"
  public_ip_address_allocation = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "network_gateway" {
  count = "${var.enable_vpn_scaffolding}"
  name = "${format("%s-gateway", azurerm_virtual_network.network.name)}"
  location = "${azurerm_resource_group.network.location}"
  resource_group_name = "${azurerm_resource_group.network.name}"

  type = "Vpn"
  vpn_type = "RouteBased"
  active_active = false
  enable_bgp = true
  sku = "VpnGw3"

  ip_configuration {
    name = "VnetGatewayIPConfig"
    public_ip_address_id = "${azurerm_public_ip.gatewayip.id}"
    private_ip_address_allocation = "Dynamic"
    subnet_id = "${azurerm_subnet.gateway.id}"
  }
}

