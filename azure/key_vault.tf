/* output "kub-ad-app-kv_application_id" {
  value = "${element(azurerm_azuread_application.kub-ad-app-kv.*.application_id, 0)}"
} */

resource "random_string" "kub-rs-pd-kv" {
   count  = "${lookup(var.instance_counts, "lkma", 0) == 0 ? 0 : 1}"
  length = 32
  special = true
}

data "azurerm_subscription" "current" {
    subscription_id =  "${var.subscription_id}"
}
resource "azurerm_azuread_application" "kub-ad-app-kv" {
  count  = "${lookup(var.instance_counts, "lkma", 0) == 0 ? 0 : 1}"
  name = "${format("%s%s%s-KUB", upper(var.environment_code), upper(var.deployment_code), upper(var.location_code))}"
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azurerm_azuread_service_principal" "kub-ad-sp-kv" {
  count = "${lookup(var.instance_counts, "lkma", 0) == 0 ? 0 : 1}"
  application_id = "${azurerm_azuread_application.kub-ad-app-kv.application_id}"
}

resource "azurerm_azuread_service_principal_password" "kub-ad-spp-kv" {
  count = "${lookup(var.instance_counts, "lkma", 0) == 0 ? 0 : 1}"
  service_principal_id = "${azurerm_azuread_service_principal.kub-ad-sp-kv.id}"
  value                = "${element(random_string.kub-rs-pd-kv.*.result, count.index)}"
  end_date             = "2020-01-01T01:02:03Z"
}

resource "azurerm_key_vault" "kub-kv" {
  count = "${lookup(var.instance_counts, "lkma", 0) == 0 ? 0 : 1}"
  name = "${var.environment_code}${var.deployment_code}${var.location_code}lkub-kv1"
  location = "${var.azure_location}"
  resource_group_name = "${azurerm_resource_group.management.name}"

  sku {
    name = "standard"
  }

  tenant_id = "${var.keyvault_tenantid}"

  access_policy {
    tenant_id = "${var.keyvault_tenantid}"
    object_id = "${azurerm_azuread_service_principal.kub-ad-sp-kv.id}"

    key_permissions = [
      "get",
    ]

    secret_permissions = [
      "get",
    ]
  }
  access_policy {
    tenant_id = "${var.keyvault_tenantid}"
    object_id = "${azurerm_azuread_service_principal.kub-ad-sp-kv.id}"

    key_permissions = [
      "create",
    ]

    secret_permissions = [
      "set",
    ]
  }
}