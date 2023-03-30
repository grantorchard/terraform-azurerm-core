output "hub_subnet_ids" {
  value = module.hub.subnet_ids
}

output "canberra_resource_group_name" {
  value = module.hub.management_resource_group_name
}

output "canberra_resource_group_location" {
  value = module.hub.management_resource_group_location
}

output "sydney_subnet_ids" {
  value = module.spoke_sydney.subnet_ids
}

output "melbourne_subnet_ids" {
  value = module.spoke_melbourne.subnet_ids
}

output "container_pull_service_principal_id" {
  value = azuread_service_principal.container_pull.id
}