module "oke" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-oke.git?ref=v0.3.0"

  region                        = var.region
  tenancy_ocid                  = var.tenancy_ocid
  compartment_ocid              = var.compartment_ocid
  cluster_type                  = "basic"
  k8s_version                   = var.k8s_version
  node_linux_version            = "8.10"
  node_shape                    = "VM.Standard.A1.Flex"
  node_ocpus                    = 1
  node_memory                   = 4
  use_existing_vcn              = true
  use_existing_nsg              = false
  vcn_id                        = module.vcn.vcn_id
  api_endpoint_subnet_id        = module.vcn.subnet_ids["api_endpoint"]
  lb_subnet_id                  = module.vcn.subnet_ids["lb"]
  nodepool_subnet_id            = module.vcn.subnet_ids["nodes"]
  is_api_endpoint_subnet_public = true
  is_lb_subnet_public           = true
  is_nodepool_subnet_public     = true
}
