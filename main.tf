module "hub" {
  source  = "app.terraform.io/tfo-apj-demos/networks/azurerm"
  version = "0.0.3"

  location = "Australia Central"

  network_type = "hub"
  name_prefix = "hub"
  address_space = "10.0.0.0/24"
  subnet_functions = [
    "Firewall",
    "Management",
    "Gateway"
  ]
}

module "spoke_sydney" {
  source  = "app.terraform.io/tfo-apj-demos/networks/azurerm"
  version = "0.0.3"

  network_type = "spoke"
  name_prefix = "sydney"
  address_space = "10.0.1.0/24"
  subnet_functions = [
    "workload"
  ]
  location = "Australia East"
  peering_ip_address = module.hub.hub_firewall_private_ip
  peering_network_id = module.hub.hub_virtual_network_id
}

module "spoke_melbourne" {
  source  = "app.terraform.io/tfo-apj-demos/networks/azurerm"
  version = "0.0.3"

  network_type = "spoke"
  name_prefix = "melbourne"
  address_space = "10.0.2.0/24"
  subnet_functions = [
    "workload"
  ]
  location = "Australia Southeast"
  peering_ip_address = module.hub.hub_firewall_private_ip
  peering_network_id = module.hub.hub_virtual_network_id
}


resource "azurerm_container_registry" "this" {
  name                = "DAFFContainerRegistry"
  resource_group_name = module.hub.management_resource_group_name
  location            = module.hub.management_resource_group_location
  sku                 = "Premium"
  admin_enabled       = false
}

resource "azuread_application" "container_pull" {
  display_name = "DAFFServicePrincipal"
}

resource "azuread_service_principal" "container_pull" {
  application_id = azuread_application.container_pull.id
}

resource "azurerm_role_assignment" "container_pull" {
  scope                = azurerm_container_registry.this.id
  principal_id = azuread_application.container_pull.id
  role_definition_name = "AcrPull"

}