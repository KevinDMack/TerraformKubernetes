data "azurerm_image" "ubuntu" {
 name_regex = "^Ubuntu_16"
 resource_group_name = "${azurerm_resource_group.packer.name}"
 sort_descending = true
}
data "azurerm_image" "windows" {
    name_regex = "^windows"
 resource_group_name = "${azurerm_resource_group.packer.name}"
 sort_descending = true
}
