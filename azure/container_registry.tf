resource "azurerm_container_registry" "container-registry" {
  count = "${lookup(var.instance_counts, "lkma", 0) == 0 ? 0 : 1}"
  name                = "containerRegistry1"
  resource_group_name = "${azurerm_resource_group.management.name}"
  location            = "${var.azure_location}"
  admin_enabled       = true
  sku                 = "Standard"

  depends_on = ["azurerm_role_assignment.kub-ad-sp-ra-kv1"]
}