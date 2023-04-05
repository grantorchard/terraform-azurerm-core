module "hub" {
  source  = "app.terraform.io/tfo-apj-demos/networks/azurerm"
  version = "0.0.6"

  location = "Australia Central"

  network_type = "hub"
  name_prefix = "hub"
  address_space = "10.0.0.0/24"
  subnet_functions = [
    "Firewall",
    "Management",
    "Gateway"
  ]
  tags = {
    "DoNotDelete" = "true"
    "owner" = "go"
  }
}

module "spoke_sydney" {
  source  = "app.terraform.io/tfo-apj-demos/networks/azurerm"
  version = "0.0.6"

  network_type = "spoke"
  name_prefix = "sydney"
  address_space = "10.0.1.0/24"
  subnet_functions = [
    "workload"
  ]
  location = "Australia East"
  peering_ip_address = module.hub.firewall_private_ip
  peering_vnet_id = module.hub.virtual_network_id
  tags = {
    "DoNotDelete" = "true"
    "owner" = "go"
  }
}

module "spoke_melbourne" {
  source  = "app.terraform.io/tfo-apj-demos/networks/azurerm"
  version = "0.0.6"

  network_type = "spoke"
  name_prefix = "melbourne"
  address_space = "10.0.2.0/24"
  subnet_functions = [
    "workload"
  ]
  location = "Australia Southeast"
  peering_ip_address = module.hub.firewall_private_ip
  peering_vnet_id = module.hub.virtual_network_id
  peering_vnet_name = module.hub.virtual_network_name
  peering_resource_group_name = module.hub.resource_group_name
  tags = {
    "DoNotDelete" = "true"
    "owner" = "go"
  }
}


resource "azurerm_container_registry" "this" {
  name                = "DAFFContainerRegistry"
  resource_group_name = module.hub.resource_group_name
  location            = module.hub.resource_group_location
  sku                 = "Premium"
  admin_enabled       = false
}

resource "azuread_application" "container_pull" {
  display_name = "DAFFServicePrincipal"
}

resource "azuread_service_principal" "container_pull" {
  application_id = azuread_application.container_pull.application_id
}

resource "azurerm_role_assignment" "container_pull" {
  scope                = azurerm_container_registry.this.id
  principal_id = azuread_service_principal.container_pull.id
  role_definition_name = "AcrPull"

}