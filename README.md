# terraform-oci-fk-vcn

This repository contains a reusable **Terraform/OpenTofu module** and progressive examples for deploying an **Oracle Cloud Infrastructure (OCI) Virtual Cloud Network (VCN)** with **subnets** and core network primitives, designed for real-world cloud architectures and hands-on learning.

It is part of the **[FoggyKitchen.com training ecosystem](https://foggykitchen.com/courses-2/)** and serves as a foundational building block for OCI and multicloud courses, including **OKE**, private connectivity, and advanced networking scenarios.

---

## 🎯 Purpose

The goal of this module is to provide a **clean, composable, and educational reference implementation** for OCI networking:

- Focused on **VCN, subnets, and core routing primitives**
- No hidden magic or implicit topology decisions
- Designed to be consumed by other modules such as **OKE** and future connectivity components

This is **not** a full landing zone replacement. It is a **learning-first, architecture-aware module**.

---

## ✨ What the module does

The module creates:

- OCI Virtual Cloud Network (VCN)
- One or more Subnets (map-based)
- Optional Internet Gateway
- Optional NAT Gateway
- Optional Service Gateway
- Optional Route Tables
- Optional Security Lists

The module intentionally does **not** create:
- OKE clusters
- DRGs
- Load Balancers
- NSGs
- Private Endpoints
- Bastion hosts

Each of those concerns belongs in its own dedicated module.

---

## 📂 Repository Structure

```bash
terraform-oci-fk-vcn/
├── examples/
│   ├── 01-basic-vcn/
│   └── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── LICENSE
└── README.md
```

All examples are runnable and demonstrate **incremental network design**, starting from the simplest public VCN layout.

---

## 🚀 Example Usage

```hcl
module "vcn" {
  source = "git::https://github.com/mlinxfeld/terraform-oci-fk-vcn.git?ref=v0.1.0"

  compartment_ocid = var.compartment_ocid
  name             = "fk-vcn-demo"
  vcn_cidr_blocks  = ["10.20.0.0/16"]

  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = true

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
    private = {
      route_rules = [
        {
          destination        = "0.0.0.0/0"
          destination_type   = "CIDR_BLOCK"
          network_entity_key = "nat_gateway"
        },
        {
          destination        = "all-services"
          destination_type   = "SERVICE_CIDR_BLOCK"
          network_entity_key = "service_gateway"
        }
      ]
    }
  }

  security_lists = {
    private_nodes = {
      ingress_rules = [
        {
          protocol = "6"
          source   = "10.20.0.0/16"
          tcp_options = {
            min = 22
            max = 22
          }
        }
      ]
      egress_rules = [
        {
          protocol    = "all"
          destination = "0.0.0.0/0"
        }
      ]
    }
  }

  subnets = {
    public_lb = {
      cidr_block                 = "10.20.10.0/24"
      route_table_key            = "public"
      prohibit_public_ip_on_vnic = false
    }
    private_nodes = {
      cidr_block         = "10.20.20.0/24"
      route_table_key    = "private"
      security_list_keys = ["private_nodes"]
    }
  }
}
```

---

## ⚙️ Module Inputs

### Core inputs

| Variable | Type | Required | Description |
|--------|------|----------|-------------|
| `compartment_ocid` | `string` | ✅ | OCI compartment OCID |
| `name` | `string` | ✅ | VCN display name |
| `vcn_cidr_blocks` | `list(string)` | ✅ | VCN CIDR blocks |
| `subnets` | `map(object)` | ❌ | Subnet definitions |
| `dns_label` | `string` | ❌ | Optional VCN DNS label |
| `defined_tags` | `map(string)` | ❌ | Defined tags |
| `freeform_tags` | `map(string)` | ❌ | Freeform tags |

### Network primitives

| Variable | Type | Required | Description |
|--------|------|----------|-------------|
| `create_internet_gateway` | `bool` | ❌ | Create Internet Gateway |
| `internet_gateway_enabled` | `bool` | ❌ | Enable created Internet Gateway |
| `create_nat_gateway` | `bool` | ❌ | Create NAT Gateway |
| `nat_gateway_block_traffic` | `bool` | ❌ | Block traffic on created NAT Gateway |
| `create_service_gateway` | `bool` | ❌ | Create Service Gateway |
| `oracle_services_network_service_name` | `string` | ❌ | Regex used to resolve Oracle Services Network |
| `extra_network_entity_ids` | `map(string)` | ❌ | Extra route target IDs, for example DRG or LPG |
| `route_tables` | `map(object)` | ❌ | Route table definitions |
| `security_lists` | `map(object)` | ❌ | Security list definitions |

### Subnet object schema

```hcl
subnets = map(object({
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
```

### Route table object schema

```hcl
route_tables = map(object({
  display_name = optional(string)
  route_rules = optional(list(object({
    description        = optional(string)
    destination        = string
    destination_type   = optional(string, "CIDR_BLOCK")
    network_entity_key = optional(string)
    network_entity_id  = optional(string)
  })), [])
}))
```

`network_entity_key` may refer to:
- `internet_gateway`
- `nat_gateway`
- `service_gateway`
- any key provided through `extra_network_entity_ids`

For Service Gateway route rules, the module supports `destination = "all-services"` together with `destination_type = "SERVICE_CIDR_BLOCK"`. In that case, it resolves the OCI Oracle Services Network CIDR automatically.

---

## 📤 Outputs

| Output | Description |
|------|-------------|
| `vcn_id` | VCN OCID |
| `vcn_name` | VCN display name |
| `vcn_cidr_blocks` | VCN CIDR blocks |
| `default_route_table_id` | Default VCN route table OCID |
| `default_security_list_id` | Default VCN security list OCID |
| `default_dhcp_options_id` | Default VCN DHCP options OCID |
| `internet_gateway_id` | Internet Gateway OCID, if created |
| `nat_gateway_id` | NAT Gateway OCID, if created |
| `service_gateway_id` | Service Gateway OCID, if created |
| `oracle_services_network_cidr_block` | Resolved Oracle Services Network CIDR when used |
| `gateway_ids` | Map of built-in gateway IDs |
| `route_table_ids` | Map of route table key to route table OCID |
| `security_list_ids` | Map of security list key to security list OCID |
| `subnet_ids` | Map of subnet key to subnet OCID |
| `subnets` | Map of subnet attributes |

---

## 🧩 Examples Overview

| Example | Description |
|-------|-------------|
| `01-basic-vcn` | Minimal OCI VCN with one public subnet, Internet Gateway, and route table |

See [`examples/`](examples) for details.

---

## 🧠 Design Philosophy

- Explicit over implicit
- Small modules over monoliths
- Generic networking first, workload logic later
- Optimized for **learning, reuse, and composition**

This makes the module ideal for:
- OKE foundations
- Training material
- Architecture workshops
- Multicloud comparisons (Azure ↔ OCI)

---

## 🧩 Related Modules & Training

- [terraform-oci-fk-oke](https://github.com/mlinxfeld/terraform-oci-fk-oke)
- [terraform-az-fk-vnet](https://github.com/mlinxfeld/terraform-az-fk-vnet)

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](LICENSE) for details.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com/courses-2/) - *Cloud. Code. Clarity.*
