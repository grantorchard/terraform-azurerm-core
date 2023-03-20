output "hub_subnet_ids" {
  value = module.hub.subnet_ids
}

output "management_resource_group_name" {
  value = module.hub.management_resource_group.name
}

output "management_resource_group_location" {
  value = module.hub.management_resource_group.location
}

output "sydney_subnet_ids" {
  value = module.spoke_sydney.subnet_ids
}

output "melbourne_subnet_ids" {
  value = module.spoke_melbourne.subnet_ids
}