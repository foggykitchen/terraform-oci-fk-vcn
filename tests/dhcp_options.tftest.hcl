mock_provider "oci" {
  mock_resource "oci_core_vcn" {
    defaults = {
      id                      = "ocid1.vcn.oc1..mock"
      default_dhcp_options_id = "ocid1.dhcpoptions.oc1..default"
    }
  }
  mock_resource "oci_core_dhcp_options" {
    defaults = {
      id = "ocid1.dhcpoptions.oc1..managed"
    }
  }
}

variables {
  compartment_ocid = "ocid1.compartment.oc1..mock"
  name             = "fk-test-vcn"
  vcn_cidr_blocks  = ["10.20.0.0/16"]
}

run "legacy_defaults_create_no_custom_dhcp" {
  command = plan
  override_resource {
    target = oci_core_subnet.this
    values = { dhcp_options_id = "ocid1.dhcpoptions.oc1..default" }
  }
  variables {
    subnets = { legacy = { cidr_block = "10.20.1.0/24" } }
  }
  assert {
    condition     = length(oci_core_dhcp_options.this) == 0 && length(output.dhcp_options_ids) == 0
    error_message = "Legacy calls must not create custom DHCP resources."
  }
  assert {
    condition     = oci_core_subnet.this["legacy"].dhcp_options_id == "ocid1.dhcpoptions.oc1..default" && output.default_dhcp_options_id == "ocid1.dhcpoptions.oc1..default"
    error_message = "Legacy default DHCP behavior must be preserved."
  }
  assert {
    condition     = toset(keys(output.subnets["legacy"])) == toset(["id", "name", "cidr_block", "route_table_id", "security_list_ids", "prohibit_public_ip_on_vnic", "prohibit_internet_ingress"])
    error_message = "The original subnet output schema must be preserved."
  }
}

run "legacy_external_id_is_preserved" {
  command = plan

  variables {
    subnets = { legacy = { cidr_block = "10.20.1.0/24", dhcp_options_id = "ocid1.dhcpoptions.oc1..external" } }
  }
  assert {
    condition     = oci_core_subnet.this["legacy"].dhcp_options_id == "ocid1.dhcpoptions.oc1..external" && output.subnet_dhcp_options_ids["legacy"] == "ocid1.dhcpoptions.oc1..external"
    error_message = "Existing external DHCP IDs must retain their value."
  }
}

run "managed_resolver_and_shared_search_domain" {
  command = plan

  variables {
    defined_tags  = { "Operations.Owner" = "platform" }
    freeform_tags = { project = "network", owner = "platform" }
    dhcp_options  = { shared = { display_name = "FoggyKitchenDHCPOptions1", search_domain_names = ["foggykitchen.com"], freeform_tags = { owner = "application" } } }
    subnets = {
      app = { cidr_block = "10.20.1.0/24", dhcp_options_key = "shared" }
      db  = { cidr_block = "10.20.2.0/24", dhcp_options_key = "shared" }
    }
  }
  assert {
    condition     = length(oci_core_dhcp_options.this) == 1 && oci_core_dhcp_options.this["shared"].display_name == "FoggyKitchenDHCPOptions1"
    error_message = "One named DHCP set must be shared by both subnets."
  }
  assert {
    condition     = alltrue([for subnet in values(oci_core_subnet.this) : subnet.dhcp_options_id == output.dhcp_options_ids["shared"]])
    error_message = "Subnet keys must resolve to the created DHCP set."
  }
  assert {
    condition     = anytrue([for option in oci_core_dhcp_options.this["shared"].options : option.type == "DomainNameServer" && option.server_type == "VcnLocalPlusInternet"]) && anytrue([for option in oci_core_dhcp_options.this["shared"].options : option.type == "SearchDomain" && try(option.search_domain_names[0], "") == "foggykitchen.com"])
    error_message = "Both DNS and search-domain options must be configured."
  }
  assert {
    condition     = oci_core_dhcp_options.this["shared"].freeform_tags == tomap({ project = "network", owner = "application" }) && oci_core_dhcp_options.this["shared"].defined_tags["Operations.Owner"] == "platform"
    error_message = "Set tags must inherit and override module tags."
  }
}

run "custom_dns_without_search_domain" {
  command = plan

  variables {
    dhcp_options = { custom = { server_type = "CustomDnsServer", custom_dns_servers = ["10.20.0.10", "10.20.0.11", "10.20.0.12"] } }
    subnets      = { app = { cidr_block = "10.20.1.0/24", dhcp_options_key = "custom" } }
  }
  assert {
    condition     = length(oci_core_dhcp_options.this["custom"].options) == 1
    error_message = "An empty search-domain list must not emit a SearchDomain block."
  }
  assert {
    condition     = one(oci_core_dhcp_options.this["custom"].options).custom_dns_servers == tolist(["10.20.0.10", "10.20.0.11", "10.20.0.12"]) && one(oci_core_dhcp_options.this["custom"].options).server_type == "CustomDnsServer"
    error_message = "All custom DNS servers must be passed to OCI."
  }
  assert {
    condition     = oci_core_dhcp_options.this["custom"].display_name == "fk-test-vcn-custom-dhcp"
    error_message = "DHCP names must have a stable default."
  }
}

run "mixed_subnet_selection_is_explicit" {
  command = plan

  variables {
    dhcp_options = { managed = {} }
    subnets = {
      managed  = { cidr_block = "10.20.1.0/24", dhcp_options_key = "managed" }
      external = { cidr_block = "10.20.2.0/24", dhcp_options_id = "ocid1.dhcpoptions.oc1..external" }
      default  = { cidr_block = "10.20.3.0/24" }
    }
  }
  assert {
    condition     = output.subnet_dhcp_options_ids["managed"] == output.dhcp_options_ids["managed"] && output.subnet_dhcp_options_ids["external"] == "ocid1.dhcpoptions.oc1..external" && try(var.subnets["default"].dhcp_options_id, null) == null && try(var.subnets["default"].dhcp_options_key, null) == null
    error_message = "Custom DHCP must be selected explicitly without overriding other subnets."
  }
}

run "null_dhcp_map_uses_empty_default" {
  command = plan

  variables {
    dhcp_options = null
  }
  assert {
    condition     = length(oci_core_dhcp_options.this) == 0
    error_message = "An explicit null must use the empty default."
  }
}

run "reject_unknown_key" {
  command = plan

  variables {
    subnets = { bad = { cidr_block = "10.20.1.0/24", dhcp_options_key = "missing" } }
  }
  expect_failures = [oci_core_subnet.this["bad"]]
}

run "reject_key_and_id_together" {
  command = plan

  variables {
    dhcp_options = { managed = {} }
    subnets      = { bad = { cidr_block = "10.20.1.0/24", dhcp_options_key = "managed", dhcp_options_id = "ocid1.dhcpoptions.oc1..external" } }
  }
  expect_failures = [var.subnets]
}

run "reject_unsupported_server_type" {
  command = plan

  variables {
    dhcp_options = { bad = { server_type = "VcnLocal" } }
  }
  expect_failures = [var.dhcp_options]
}

run "reject_missing_custom_dns_servers" {
  command = plan

  variables {
    dhcp_options = { bad = { server_type = "CustomDnsServer" } }
  }
  expect_failures = [var.dhcp_options]
}

run "reject_too_many_custom_dns_servers" {
  command = plan

  variables {
    dhcp_options = { bad = { server_type = "CustomDnsServer", custom_dns_servers = ["10.20.0.10", "10.20.0.11", "10.20.0.12", "10.20.0.13"] } }
  }
  expect_failures = [var.dhcp_options]
}

run "reject_custom_servers_with_oci_resolver" {
  command = plan

  variables {
    dhcp_options = { bad = { custom_dns_servers = ["10.20.0.10"] } }
  }
  expect_failures = [var.dhcp_options]
}

run "reject_invalid_dns_server_address" {
  command = plan

  variables {
    dhcp_options = { bad = { server_type = "CustomDnsServer", custom_dns_servers = ["not-an-ip"] } }
  }
  expect_failures = [var.dhcp_options]
}

run "reject_empty_search_domain" {
  command = plan

  variables {
    dhcp_options = { bad = { search_domain_names = [" "] } }
  }
  expect_failures = [var.dhcp_options]
}

run "reject_multiple_search_domains" {
  command = plan

  variables {
    dhcp_options = { bad = { search_domain_names = ["one.example.com", "two.example.com"] } }
  }
  expect_failures = [var.dhcp_options]
}
