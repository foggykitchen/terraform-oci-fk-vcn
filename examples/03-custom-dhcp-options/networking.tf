module "vcn" {
  source = "../.."

  compartment_ocid = var.compartment_ocid
  name             = "foggykitchen-dhcp-vcn"
  vcn_cidr_blocks  = ["10.20.0.0/16"]
  dns_label        = "fkdhcp"

  dhcp_options = {
    application = {
      display_name        = "FoggyKitchenDHCPOptions1"
      search_domain_names = ["foggykitchen.com"]
    }
    custom_dns = {
      server_type        = "CustomDnsServer"
      custom_dns_servers = ["10.20.0.10", "10.20.0.11"]
    }
  }

  subnets = {
    application = {
      cidr_block       = "10.20.1.0/24"
      dns_label        = "app"
      dhcp_options_key = "application"
    }
    custom_dns_clients = {
      cidr_block       = "10.20.2.0/24"
      dns_label        = "custom"
      dhcp_options_key = "custom_dns"
    }
    default_dns_clients = {
      cidr_block = "10.20.3.0/24"
      dns_label  = "default"
    }
  }
}
