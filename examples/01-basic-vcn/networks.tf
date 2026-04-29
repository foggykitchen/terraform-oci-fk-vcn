module "vcn" {
  source = "../.."

  compartment_ocid = var.compartment_ocid
  name             = "foggykitchen-vcn"
  vcn_cidr_blocks  = ["10.20.0.0/16"]

  create_internet_gateway = true

  route_tables = {
    public = {
      route_rules = [
        {
          destination        = "0.0.0.0/0"
          destination_type   = "CIDR_BLOCK"
          network_entity_key = "internet_gateway"
        }
      ]
    }
  }

  subnets = {
    public = {
      display_name               = "foggykitchen-subnet"
      cidr_block                 = "10.20.10.0/24"
      route_table_key            = "public"
      prohibit_public_ip_on_vnic = false
    }
  }
}
