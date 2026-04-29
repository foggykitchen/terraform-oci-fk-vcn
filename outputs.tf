output "vcn_id" {
  description = "VCN OCID."
  value       = oci_core_vcn.this.id
}

output "vcn_name" {
  description = "VCN display name."
  value       = oci_core_vcn.this.display_name
}

output "vcn_cidr_blocks" {
  description = "VCN CIDR blocks."
  value       = oci_core_vcn.this.cidr_blocks
}

output "default_route_table_id" {
  description = "Default route table OCID for the VCN."
  value       = oci_core_vcn.this.default_route_table_id
}

output "default_security_list_id" {
  description = "Default security list OCID for the VCN."
  value       = oci_core_vcn.this.default_security_list_id
}

output "default_dhcp_options_id" {
  description = "Default DHCP options OCID for the VCN."
  value       = oci_core_vcn.this.default_dhcp_options_id
}

output "internet_gateway_id" {
  description = "Created Internet Gateway OCID, if any."
  value       = try(oci_core_internet_gateway.this[0].id, null)
}

output "nat_gateway_id" {
  description = "Created NAT Gateway OCID, if any."
  value       = try(oci_core_nat_gateway.this[0].id, null)
}

output "service_gateway_id" {
  description = "Created Service Gateway OCID, if any."
  value       = try(oci_core_service_gateway.this[0].id, null)
}

output "oracle_services_network_cidr_block" {
  description = "Resolved Oracle Services Network CIDR block when the Service Gateway path is used."
  value       = try(data.oci_core_services.oracle_services_network[0].services[0].cidr_block, null)
}

output "gateway_ids" {
  description = "Map of built-in gateway keys to their created OCIDs."
  value = {
    internet_gateway = try(oci_core_internet_gateway.this[0].id, null)
    nat_gateway      = try(oci_core_nat_gateway.this[0].id, null)
    service_gateway  = try(oci_core_service_gateway.this[0].id, null)
  }
}

output "route_table_ids" {
  description = "Map of route table key to OCID."
  value = {
    for key, rt in oci_core_route_table.this : key => rt.id
  }
}

output "security_list_ids" {
  description = "Map of security list key to OCID."
  value = {
    for key, sl in oci_core_security_list.this : key => sl.id
  }
}

output "subnet_ids" {
  description = "Map of subnet key to OCID."
  value = {
    for key, subnet in oci_core_subnet.this : key => subnet.id
  }
}

output "subnets" {
  description = "Map of subnet key to selected subnet attributes."
  value = {
    for key, subnet in oci_core_subnet.this : key => {
      id                         = subnet.id
      name                       = subnet.display_name
      cidr_block                 = subnet.cidr_block
      route_table_id             = subnet.route_table_id
      security_list_ids          = subnet.security_list_ids
      prohibit_public_ip_on_vnic = subnet.prohibit_public_ip_on_vnic
      prohibit_internet_ingress  = subnet.prohibit_internet_ingress
    }
  }
}
