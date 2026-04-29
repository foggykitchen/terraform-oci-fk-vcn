locals {
  route_rule_refs_service_gateway = anytrue(flatten([
    for rt in values(var.route_tables) : [
      for rr in try(rt.route_rules, []) : try(rr.network_entity_key, "") == "service_gateway"
    ]
  ]))

  create_service_gateway_effective = var.create_service_gateway || local.route_rule_refs_service_gateway

  network_entity_ids = merge(
    var.extra_network_entity_ids,
    {
      internet_gateway = try(oci_core_internet_gateway.this[0].id, null)
      nat_gateway      = try(oci_core_nat_gateway.this[0].id, null)
      service_gateway  = try(oci_core_service_gateway.this[0].id, null)
    }
  )
}

resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_ocid
  display_name   = var.name
  cidr_blocks    = var.vcn_cidr_blocks
  dns_label      = var.dns_label

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
}

data "oci_core_services" "oracle_services_network" {
  count = local.create_service_gateway_effective ? 1 : 0

  filter {
    name   = "name"
    values = [var.oracle_services_network_service_name]
    regex  = true
  }
}

resource "oci_core_internet_gateway" "this" {
  count = var.create_internet_gateway ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name}-igw"
  enabled        = var.internet_gateway_enabled

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_core_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name}-natgw"
  block_traffic  = var.nat_gateway_block_traffic

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_core_service_gateway" "this" {
  count = local.create_service_gateway_effective ? 1 : 0

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = "${var.name}-sgw"

  services {
    service_id = data.oci_core_services.oracle_services_network[0].services[0].id
  }

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_core_route_table" "this" {
  for_each = var.route_tables

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = try(each.value.display_name, each.key)

  dynamic "route_rules" {
    for_each = try(each.value.route_rules, [])
    content {
      description      = try(route_rules.value.description, null)
      destination      = try(route_rules.value.network_entity_key, "") == "service_gateway" && try(route_rules.value.destination_type, "CIDR_BLOCK") == "SERVICE_CIDR_BLOCK" && route_rules.value.destination == "all-services" ? data.oci_core_services.oracle_services_network[0].services[0].cidr_block : route_rules.value.destination
      destination_type = try(route_rules.value.destination_type, "CIDR_BLOCK")
      network_entity_id = try(route_rules.value.network_entity_id, null) != null ? route_rules.value.network_entity_id : lookup(
        local.network_entity_ids,
        try(route_rules.value.network_entity_key, ""),
        null
      )
    }
  }

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_core_security_list" "this" {
  for_each = var.security_lists

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = try(each.value.display_name, each.key)

  dynamic "ingress_security_rules" {
    for_each = try(each.value.ingress_rules, [])
    content {
      description = try(ingress_security_rules.value.description, null)
      protocol    = ingress_security_rules.value.protocol
      source      = ingress_security_rules.value.source
      source_type = try(ingress_security_rules.value.source_type, "CIDR_BLOCK")
      stateless   = try(ingress_security_rules.value.stateless, false)

      dynamic "tcp_options" {
        for_each = try(ingress_security_rules.value.tcp_options, null) != null ? [ingress_security_rules.value.tcp_options] : []
        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = try(ingress_security_rules.value.udp_options, null) != null ? [ingress_security_rules.value.udp_options] : []
        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = try(ingress_security_rules.value.icmp_options, null) != null ? [ingress_security_rules.value.icmp_options] : []
        content {
          type = icmp_options.value.type
          code = try(icmp_options.value.code, null)
        }
      }
    }
  }

  dynamic "egress_security_rules" {
    for_each = try(each.value.egress_rules, [])
    content {
      description      = try(egress_security_rules.value.description, null)
      protocol         = egress_security_rules.value.protocol
      destination      = egress_security_rules.value.destination
      destination_type = try(egress_security_rules.value.destination_type, "CIDR_BLOCK")
      stateless        = try(egress_security_rules.value.stateless, false)

      dynamic "tcp_options" {
        for_each = try(egress_security_rules.value.tcp_options, null) != null ? [egress_security_rules.value.tcp_options] : []
        content {
          min = tcp_options.value.min
          max = tcp_options.value.max
        }
      }

      dynamic "udp_options" {
        for_each = try(egress_security_rules.value.udp_options, null) != null ? [egress_security_rules.value.udp_options] : []
        content {
          min = udp_options.value.min
          max = udp_options.value.max
        }
      }

      dynamic "icmp_options" {
        for_each = try(egress_security_rules.value.icmp_options, null) != null ? [egress_security_rules.value.icmp_options] : []
        content {
          type = icmp_options.value.type
          code = try(icmp_options.value.code, null)
        }
      }
    }
  }

  defined_tags  = var.defined_tags
  freeform_tags = var.freeform_tags
}

resource "oci_core_subnet" "this" {
  for_each = var.subnets

  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this.id
  display_name   = try(each.value.display_name, each.key)
  cidr_block     = each.value.cidr_block
  dns_label      = try(each.value.dns_label, null)

  dhcp_options_id            = try(each.value.dhcp_options_id, null)
  prohibit_internet_ingress  = try(each.value.prohibit_internet_ingress, false)
  prohibit_public_ip_on_vnic = try(each.value.prohibit_public_ip_on_vnic, true)

  route_table_id = try(each.value.route_table_key, null) != null ? oci_core_route_table.this[each.value.route_table_key].id : try(each.value.route_table_id, null)

  security_list_ids = concat(
    try(each.value.include_default_security_list, true) ? [oci_core_vcn.this.default_security_list_id] : [],
    try(each.value.security_list_ids, []),
    [for key in try(each.value.security_list_keys, []) : oci_core_security_list.this[key].id]
  )

  defined_tags  = try(each.value.defined_tags, {})
  freeform_tags = try(each.value.freeform_tags, {})
}
