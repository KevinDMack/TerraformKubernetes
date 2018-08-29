provider "azurerm" {
  subscription_id = "${var.subscription_id}"
  environment = "${var.azure_environment}"
}
