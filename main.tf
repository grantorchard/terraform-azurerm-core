locals {
  address_space = {
    sydney = "10.0.0.0/24"
    melbourne = "10.0.1.0/24"
    canberra = "10.0.3.0/24"
  }
}

resource "azurerm_resource_group" "sydney" {
    name = "sydney"
    location = "Australia East"
}

resource "azurerm_resource_group" "canberra" {
    name = "canberra"
    location = "Australia Central"
}

resource "azurerm_resource_group" "melbourne" {
    name = "melbourne"
    location = "Australia Southeast"
}

/// Networks
resource "azurerm_virtual_network" "sydney" {
  resource_group_name = azurerm_resource_group.sydney.name
  location = azurerm_resource_group.sydney.location
  name = "vnet-sydney"
  address_space = [local.address_space.sydney]
}

resource "azurerm_virtual_network" "melbourne" {
  resource_group_name = azurerm_resource_group.melbourne.name
  location = azurerm_resource_group.melbourne.location
  name = "vnet-melbourne"
  address_space = [local.address_space.melbourne]
}

resource "azurerm_virtual_network" "canberra" {
  resource_group_name = azurerm_resource_group.canberra.name
  location = azurerm_resource_group.canberra.location
  name = "vnet-canberra"
  address_space = [local.address_space.canberra]
}

// Configure Peering
resource "azurerm_virtual_network_peering" "sydney-canberra" {
  name                         = "peering-sydney-to-canberra"
  resource_group_name          = azurerm_resource_group.sydney.name
  virtual_network_name         = azurerm_virtual_network.sydney.name
  remote_virtual_network_id    = azurerm_virtual_network.canberra.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  allow_gateway_transit = false
}

resource "azurerm_virtual_network_peering" "melbourne-canberra" {
  name                         = "peering-melbourne-to-canberra"
  resource_group_name          = azurerm_resource_group.melbourne.name
  virtual_network_name         = azurerm_virtual_network.melbourne.name
  remote_virtual_network_id    = azurerm_virtual_network.canberra.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true

  allow_gateway_transit = false
}

// Configure firewall in hub network
resource "azurerm_subnet" "hub_firewall" {
    name = "AzureFirewallSubnet'"
  address_prefixes = [
    cidrsubnet(azurerm_virtual_network.canberra.address_space[0], 2, 0)
  ]
  resource_group_name = azurerm_resource_group.canberra.name
  virtual_network_name = azurerm_virtual_network.canberra.name

}

resource "azurerm_public_ip" "hub_firewall" {
  name                = "hub-firewall-ip"
  location            = azurerm_resource_group.canberra.location
  resource_group_name = azurerm_resource_group.canberra.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "hub" {
  name                = "hub-firewall"
  location            = azurerm_resource_group.canberra.location
  resource_group_name = azurerm_resource_group.canberra.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub_firewall.id
    public_ip_address_id = azurerm_public_ip.hub_firewall.id
  }
}