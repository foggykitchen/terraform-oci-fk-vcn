output "vcn_id" {
  value = module.vcn.vcn_id
}

output "dhcp_options_ids" {
  value = module.vcn.dhcp_options_ids
}

output "subnet_dhcp_options_ids" {
  value = module.vcn.subnet_dhcp_options_ids
}

output "default_dhcp_options_id" {
  value = module.vcn.default_dhcp_options_id
}
