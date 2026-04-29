variable "compartment_ocid" {
  description = "Compartment OCID where the VCN resources will be created."
  type        = string
}

variable "name" {
  description = "VCN display name."
  type        = string
}

variable "vcn_cidr_blocks" {
  description = "CIDR blocks for the VCN."
  type        = list(string)
}

variable "dns_label" {
  description = "Optional DNS label for the VCN."
  type        = string
  default     = null
}

variable "defined_tags" {
  description = "Defined tags applied to all top-level resources created by the module."
  type        = map(string)
  default     = {}
}

variable "freeform_tags" {
  description = "Freeform tags applied to all top-level resources created by the module."
  type        = map(string)
  default     = {}
}

variable "create_internet_gateway" {
  description = "Create an Internet Gateway for the VCN."
  type        = bool
  default     = false
}

variable "internet_gateway_enabled" {
  description = "Whether the created Internet Gateway is enabled."
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Create a NAT Gateway for the VCN."
  type        = bool
  default     = false
}

variable "nat_gateway_block_traffic" {
  description = "Whether the created NAT Gateway blocks traffic."
  type        = bool
  default     = false
}

variable "create_service_gateway" {
  description = "Create a Service Gateway for the VCN."
  type        = bool
  default     = false
}

variable "oracle_services_network_service_name" {
  description = "Regex used to discover the Oracle Services Network entry for the Service Gateway."
  type        = string
  default     = "All .* Services In Oracle Services Network"
}

variable "extra_network_entity_ids" {
  description = "Additional network entity IDs that route tables can reference by key, for example a DRG or LPG."
  type        = map(string)
  default     = {}
}

variable "route_tables" {
  description = "Map of route tables to create."
  type = map(object({
    display_name = optional(string)
    route_rules = optional(list(object({
      description        = optional(string)
      destination        = string
      destination_type   = optional(string, "CIDR_BLOCK")
      network_entity_key = optional(string)
      network_entity_id  = optional(string)
    })), [])
  }))
  default = {}
}

variable "security_lists" {
  description = "Map of security lists to create."
  type = map(object({
    display_name = optional(string)
    ingress_rules = optional(list(object({
      description = optional(string)
      protocol    = string
      source      = string
      source_type = optional(string, "CIDR_BLOCK")
      stateless   = optional(bool, false)
      tcp_options = optional(object({
        min = number
        max = number
      }))
      udp_options = optional(object({
        min = number
        max = number
      }))
      icmp_options = optional(object({
        type = number
        code = optional(number)
      }))
    })), [])
    egress_rules = optional(list(object({
      description      = optional(string)
      protocol         = string
      destination      = string
      destination_type = optional(string, "CIDR_BLOCK")
      stateless        = optional(bool, false)
      tcp_options = optional(object({
        min = number
        max = number
      }))
      udp_options = optional(object({
        min = number
        max = number
      }))
      icmp_options = optional(object({
        type = number
        code = optional(number)
      }))
    })), [])
  }))
  default = {}
}

variable "subnets" {
  description = "Map of subnets to create."
  type = map(object({
    cidr_block                    = string
    display_name                  = optional(string)
    dns_label                     = optional(string)
    dhcp_options_id               = optional(string)
    route_table_key               = optional(string)
    route_table_id                = optional(string)
    security_list_keys            = optional(list(string), [])
    security_list_ids             = optional(list(string), [])
    include_default_security_list = optional(bool, true)
    prohibit_internet_ingress     = optional(bool, false)
    prohibit_public_ip_on_vnic    = optional(bool, true)
    defined_tags                  = optional(map(string), {})
    freeform_tags                 = optional(map(string), {})
  }))
  default = {}
}
