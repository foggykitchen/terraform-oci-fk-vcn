# Synthetic fixtures only. Every run is plan-only; no tenancy credentials are used.
mock_provider "oci" {
  mock_data "oci_core_services" {
    defaults = { "id" = "MOCK_OCID_SERVICES", "services" = [{ "cidr_block" = "all-fra-services-in-oracle-services-network", "description" = "mock-value", "id" = "mock-service", "name" = "All FRA Services In Oracle Services Network" }] }
  }
  mock_resource "oci_core_dhcp_options" {
    defaults = { "id" = "MOCK_OCID_OPTIONS", "state" = "AVAILABLE", "time_created" = "mock-value" }
  }
  mock_resource "oci_core_internet_gateway" {
    defaults = { "id" = "MOCK_OCID_GATEWAY", "state" = "AVAILABLE", "time_created" = "mock-value" }
  }
  mock_resource "oci_core_nat_gateway" {
    defaults = { "id" = "MOCK_OCID_GATEWAY", "nat_ip" = "mock-value", "state" = "AVAILABLE", "time_created" = "mock-value" }
  }
  mock_resource "oci_core_route_table" {
    defaults = { "id" = "MOCK_OCID_TABLE", "state" = "AVAILABLE", "time_created" = "mock-value" }
  }
  mock_resource "oci_core_security_list" {
    defaults = { "id" = "MOCK_OCID_LIST", "state" = "AVAILABLE", "time_created" = "mock-value" }
  }
  mock_resource "oci_core_service_gateway" {
    defaults = { "block_traffic" = false, "id" = "MOCK_OCID_GATEWAY", "state" = "AVAILABLE", "time_created" = "mock-value" }
  }
  mock_resource "oci_core_subnet" {
    defaults = { "id" = "MOCK_OCID_SUBNET", "ipv6virtual_router_ip" = "mock-value", "state" = "AVAILABLE", "subnet_domain_name" = "mock-value", "time_created" = "mock-value", "virtual_router_ip" = "mock-value", "virtual_router_mac" = "mock-value" }
  }
  mock_resource "oci_core_vcn" {
    defaults = { "byoipv6cidr_blocks" = ["mock-value"], "default_dhcp_options_id" = "MOCK_OCID_MOCK", "default_route_table_id" = "MOCK_OCID_MOCK", "default_security_list_id" = "MOCK_OCID_MOCK", "id" = "MOCK_OCID_VCN", "ipv6cidr_blocks" = ["mock-value"], "state" = "AVAILABLE", "time_created" = "mock-value", "vcn_domain_name" = "mock-value" }
  }
}
variables {
  compartment_ocid = "MOCK_OCID_COMPARTMENT"
  name             = "compatibility"
  vcn_cidr_blocks  = ["10.0.0.0/16"]
}

run "oci9_plan" {
  command = plan
}
