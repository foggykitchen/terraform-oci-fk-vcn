# OCI VCN examples

Three independent examples show how to use `terraform-oci-fk-vcn`. Each directory owns its own configuration and state; they are not sequential state upgrades.

| Example | Focus | Resources |
| --- | --- | --- |
| [01: Basic VCN](01-basic-vcn/README.md) | Public network foundation | VCN, public subnet, Internet Gateway and route table |
| [02: OKE networking integration](02-oke-networking-integration/README.md) | Compose networking and Kubernetes modules | VCN, three public subnets, Internet/Service Gateways, security lists, Basic OKE cluster and worker pool |
| [03: Custom DHCP options](03-custom-dhcp-options/README.md) | Per-subnet DHCP selection | Two custom DHCP sets and three private subnets, including a subnet using VCN defaults |

## Requirements and authentication

Use OpenTofu >= 1.6, Git, an OCI API signing key and permissions/quotas for the selected example. Network primitives use `oracle/oci ~> 6.0`. Example 02 also downloads the pinned OKE module; its Kubernetes version and worker shape must be available in your region.

Every example includes `terraform.tfvars.example` with tenancy/user OCIDs, fingerprint, private-key path, compartment OCID and region. Copy and edit the template, or use the corresponding `TF_VAR_` variables. Never commit actual credentials, variable files, state, plans or kubeconfig.

## Run independently

```sh
cd 01-basic-vcn # or 02-oke-networking-integration / 03-custom-dhcp-options
cp terraform.tfvars.example terraform.tfvars
# Edit the copied file.
tofu init
tofu fmt -check
tofu validate
tofu plan -out=example.tfplan
# Review the proposed billable resources.
tofu apply example.tfplan
tofu output
```

After using the lab, review `tofu plan -destroy` and run `tofu destroy` from that example's directory. Example 02 creates worker VMs and boot volumes. The examples' CIDRs overlap intentionally for separate labs; do not peer them without changing the address plan.

Module initialization and configuration validation do not prove OCI permissions, DNS reachability or OKE version availability. The root [DHCP test suite](../tests/README.md) uses mock OCI providers and creates no cloud resources.

[Module contract and compatibility](../README.md)

## Support and license

See the [support policy](../SUPPORT.md) and [UPL license](../LICENSE).

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
