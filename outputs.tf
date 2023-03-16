output "resource_groups" {
  value = {
    "sydney" = azurerm_resource_group.sydney.name,
    "melbourne" = azurerm_resource_group.melbourne.name,
    "canberra" = azurerm_resource_group.canberra.name,
  }
}

output "workload_subnets" {
  value = {
    "sydney" = azurerm_subnet.sydney_workloads.id,
    "melbourne" = azurerm_subnet.melbourne_workloads.id,
    "canberra" = azurerm_subnet.canberra_workloads.id
  }
}

output "firewall_name" {
  value = azurerm_firewall.hub.name
}