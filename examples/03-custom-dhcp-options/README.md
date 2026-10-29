# Example 03: Custom DHCP options

This example uses the local VCN module to create two opt-in DHCP sets and three private subnets:

| Subnet | DHCP behavior |
| --- | --- |
| `application` | OCI resolver with `foggykitchen.com` as its search domain |
| `custom_dns_clients` | Custom DNS servers at `10.20.0.10` and `10.20.0.11`, without a search-domain option |
| `default_dns_clients` | Unchanged VCN default DHCP options |

This configures DHCP, not DNS servers, instances or gateways. Replace the sample DNS addresses with reachable resolvers and configure routing/security for your consumers. A search domain is a client suffix; it does not create a private DNS zone. Additional subnets can share a set by reusing its key.

The VCN module is taken from `../..`, so this example exercises the checked-out code. Examples [01](../01-basic-vcn/README.md) and [02](../02-oke-networking-integration/README.md) use the same module with default DHCP behavior.

## Run with OpenTofu

Use OpenTofu >= 1.6 and OCI API-key credentials with network permissions:

```sh
cp terraform.tfvars.example terraform.tfvars
# Edit the copied file with your OCI configuration.
tofu init
tofu fmt -check
tofu validate
tofu plan -out=dhcp.tfplan
# Review the plan before deployment.
tofu apply dhcp.tfplan
tofu output
```

Keep credentials and state private. Review `tofu plan -destroy` and use `tofu destroy` when finished.

Custom DHCP is included in `v0.2.0` and newer. This example uses the local checkout; the older `v0.1.0` tag does not include this feature. See the [DHCP contract and compatibility notes](../../README.md#custom-dhcp-options) and [all examples](../README.md).

## Support and license

See the [support policy](../../SUPPORT.md) and [UPL license](../../LICENSE).

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
