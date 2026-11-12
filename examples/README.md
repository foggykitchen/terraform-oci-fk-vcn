# Examples

This directory contains runnable Terraform/OpenTofu examples for `terraform-oci-fk-vcn`.

| Example | Description |
|--------|-------------|
| `01-basic-vcn` | Minimal OCI VCN with one public subnet, Internet Gateway, and route table |
| `02-oke-networking-integration` | Reusable VCN foundation injected into `terraform-oci-fk-oke` for a basic OKE deployment |
| `03-custom-dhcp-options` | Opt-in custom DHCP and unchanged default DHCP behavior |

The examples are intentionally progressive:
- `01-basic-vcn` focuses only on core OCI networking.
- `02-oke-networking-integration` shows how the module can be composed with another reusable workload module.
- `03-custom-dhcp-options` configures DHCP sets selected per subnet; it does not create DNS servers.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
