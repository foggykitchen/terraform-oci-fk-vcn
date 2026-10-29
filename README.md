# terraform-oci-fk-vcn

This repository contains a reusable **Terraform/OpenTofu module** and progressive examples for deploying an **Oracle Cloud Infrastructure (OCI) Virtual Cloud Network (VCN)** with **subnets** and core network primitives, designed for real-world cloud architectures and hands-on learning.

It is part of the **[FoggyKitchen.com training ecosystem](https://foggykitchen.com/)** and serves as a foundational building block for OCI and multicloud courses, including **OKE**, private connectivity, and advanced networking scenarios.

Support expectations are documented in [SUPPORT.md](SUPPORT.md).

---

## Used By

This module is used as a building block by the higher-level [FoggyKitchen Landing Zone Orchestrator](https://github.com/foggykitchen/foggykitchen-landing-zone-orchestrator), where it is composed into Azure, OCI, and multicloud landing zone patterns.

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
- Optional custom DHCP option sets, selected explicitly by subnet key

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
│   ├── 02-oke-networking-integration/
│   ├── 03-custom-dhcp-options/
│   └── README.md
├── main.tf
├── variables.tf
├── outputs.tf
├── versions.tf
├── LICENSE
└── README.md
```

Examples **01, 02 and 03** are independent root configurations with their own state. Example 02 creates an OKE workload on networking supplied by this module; example 03 focuses on custom DHCP. Use OpenTofu to initialize and validate each example. Actual deployment depends on OCI permissions, quotas and regional service availability.

## Run an example

```sh
cd examples/01-basic-vcn
cp terraform.tfvars.example terraform.tfvars
# Edit your OCI API-key inputs, compartment and region.
tofu init
tofu fmt -check
tofu validate
tofu plan -out=example.tfplan
# Review before deploying.
tofu apply example.tfplan
```

Every example provides a `terraform.tfvars.example` template. Keep real variable files, API keys, state, kubeconfig and plans out of Git. For example 02, review `k8s_version` against the target region and the public endpoint/node network configuration. See the [examples index](examples/README.md) for the full sequence and cleanup instructions.

---

## 🚀 Example Usage

```hcl
module "vcn" {
  source = "git::https://github.com/foggykitchen/terraform-oci-fk-vcn.git?ref=v0.2.0"

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
| `dhcp_options` | `map(object)` | ❌ | Custom DHCP option sets; defaults to `{}` |

### Subnet object schema

```hcl
subnets = map(object({
  cidr_block                    = string
  display_name                  = optional(string)
  dns_label                     = optional(string)
  dhcp_options_id               = optional(string)
  dhcp_options_key              = optional(string)
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

### Custom DHCP options

`dhcp_options` is an opt-in map. A set is associated with a subnet only through `dhcp_options_key`; existing `dhcp_options_id` inputs continue to work. The VCN-generated default DHCP options are never modified.

```hcl
dhcp_options = {
  application = {
    display_name        = "FoggyKitchenDHCPOptions1"
    server_type         = "VcnLocalPlusInternet" # default
    search_domain_names = ["foggykitchen.com"]
  }
  custom_dns = {
    server_type        = "CustomDnsServer"
    custom_dns_servers = ["10.20.0.10", "10.20.0.11"]
  }
}

subnets = {
  app = {
    cidr_block       = "10.20.1.0/24"
    dhcp_options_key = "application"
  }
  existing = {
    cidr_block      = "10.20.2.0/24"
    dhcp_options_id = var.existing_dhcp_options_id
  }
  default = {
    cidr_block = "10.20.3.0/24"
  }
}
```

Custom DHCP is available in `v0.2.0` and newer, or in the local checkout. The `v0.1.0` tag retains its original interface. See the runnable local example in [`examples/03-custom-dhcp-options`](examples/03-custom-dhcp-options).

```hcl
dhcp_options = map(object({
  display_name        = optional(string)
  domain_name_type    = optional(string)
  server_type         = optional(string, "VcnLocalPlusInternet")
  custom_dns_servers  = optional(list(string), [])
  search_domain_names = optional(list(string), [])
  defined_tags        = optional(map(string), {})
  freeform_tags       = optional(map(string), {})
}))
```

- `VcnLocalPlusInternet` uses OCI DNS and must not specify custom DNS servers. `VcnLocal` is reserved by OCI and is not accepted.
- `CustomDnsServer` requires one to three IP addresses. The module configures DHCP clients; it does not create DNS servers or their network connectivity.
- `search_domain_names` accepts zero or one non-empty domain. An empty list omits `SearchDomain` entirely, following the [OCI provider contract](https://docs.oracle.com/en-us/iaas/tools/terraform-provider-oci/latest/docs/r/core_dhcp_options.html).
- Per-set tags override matching module tags. The default display name is `<name>-<key>-dhcp`.
- A subnet can use a managed `dhcp_options_key` or external `dhcp_options_id`, not both. Unknown keys fail with a subnet-specific diagnostic.
- `domain_name_type` is optional and passed through to OCI. Leaving it unset preserves provider/service defaults.

### Backward compatibility and migration

Existing inputs, resource addresses and output names remain unchanged, including the object shape of the `subnets` output. Runtime/provider version constraints are unchanged. Omitting `dhcp_options` (or passing null) creates no custom DHCP resources. Omitting both subnet selectors retains the previous default-DHCP behavior. `default_dhcp_options_id` still returns the VCN-generated default, never a custom set.

New outputs are `dhcp_options_ids` and `subnet_dhcp_options_ids`. Custom sets have stable addresses `oci_core_dhcp_options.this["<key>"]`.

To migrate an equivalent caller-managed DHCP resource, define a matching map entry and subnet key, remove the old resource block and place this move in the **caller configuration**:

```hcl
moved {
  from = oci_core_dhcp_options.FoggyKitchenDhcpOptions1
  to   = module.vcn.oci_core_dhcp_options.this["application"]
}
```

Keep names, DNS/search-domain options, domain-name type and tags aligned with the existing resource. Back up state and review `tofu plan`. Renaming a map key requires its own move. To adopt a resource not already in that state, use `tofu import` instead. Clients may need to renew DHCP leases after deliberate configuration changes.

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
| `default_dhcp_options_id` | Default VCN DHCP options OCID (unchanged) |
| `dhcp_options_ids` | Map of custom DHCP option set key to OCID |
| `subnet_dhcp_options_ids` | Map of subnet key to resolved DHCP options OCID |
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
| [`01-basic-vcn`](examples/01-basic-vcn/README.md) | Minimal OCI VCN with one public subnet, Internet Gateway, and route table |
| [`02-oke-networking-integration`](examples/02-oke-networking-integration/README.md) | Existing VCN/subnet integration with the pinned FoggyKitchen OKE module |
| [`03-custom-dhcp-options`](examples/03-custom-dhcp-options/README.md) | Custom DNS/search-domain options selected per subnet alongside unchanged default DHCP |

See the [examples index](examples/README.md) for requirements, inputs and links to all three examples.

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

- [terraform-oci-fk-oke](https://github.com/foggykitchen/terraform-oci-fk-oke)
- [terraform-az-fk-vnet](https://github.com/foggykitchen/terraform-az-fk-vnet)

---

## Related technical articles

- [OCI Terraform Modules: Compose VCN, Compute and Load Balancing](https://foggykitchen.com/2026/05/18/oci-terraform-modules-vcn-compute-load-balancer/)
  — Compose VCN, Compute and Load Balancer modules, with private backends, instance pools, health checks and autoscaling.

## Validation

Run with OpenTofu from the module root:

```sh
tofu init -backend=false
tofu fmt -recursive -check
tofu validate
tofu test
```

The 15 DHCP tests use a mock OCI provider and plan-only runs, with no credentials or cloud resources. They cover legacy defaults/external IDs, managed and mixed subnet associations, DNS/search domains, tag inheritance and invalid inputs. See [`tests/README.md`](tests/README.md). The tests use a mock-capable OpenTofu release; the module keeps its existing Terraform/OpenTofu runtime constraint.

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](LICENSE) for details.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
