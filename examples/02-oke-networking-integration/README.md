# Example 02: OKE Networking Integration

This example shows how to use `terraform-oci-fk-vcn` as a reusable networking foundation for the public `terraform-oci-fk-oke` module.

The VCN module creates the OCI network layer first:
- VCN
- subnets
- Internet Gateway
- Service Gateway
- route table
- security lists

The OKE module then consumes the resulting `vcn_id` and subnet IDs to create a basic OKE cluster without creating networking resources on its own.

---

## Architecture Overview

![](terraform-oci-fk-oke-lesson1-architecture.png)

This example creates:
- A new OCI VCN created by `terraform-oci-fk-vcn`
- A cluster API endpoint subnet created by `terraform-oci-fk-vcn`
- A load balancer subnet created by `terraform-oci-fk-vcn`
- A node pool subnet created by `terraform-oci-fk-vcn`, with worker nodes created by `terraform-oci-fk-oke`
- An Internet Gateway, Service Gateway, and shared route table created by `terraform-oci-fk-vcn`
- Security lists for the cluster networking created by `terraform-oci-fk-vcn`
- A basic OKE cluster created by `terraform-oci-fk-oke`

The network layer is created first by `terraform-oci-fk-vcn`.
That includes the VCN, subnets, gateways, route table, and security lists.
The OKE module then consumes the resulting subnet and VCN IDs through `use_existing_vcn = true`.

---

## OCI Console View

The following screenshot shows the created OKE resources in OCI Console:

![](terraform-oci-fk-oke-lesson1-oci-console.png)

---

## Module Composition

The example is split into two reusable modules:

- `networking.tf` creates the VCN layer with `terraform-oci-fk-vcn`, including subnets, gateways, route tables, and security lists.
- `oke.tf` creates the cluster with `terraform-oci-fk-oke` and injects the subnet and VCN IDs from the network module.

The important settings are:

- `terraform-oci-fk-vcn` creates the VCN, gateways, route table, security lists, and the three OKE-facing subnets.
- `use_existing_vcn = true` makes `terraform-oci-fk-oke` consume those network resources instead of creating its own.
- `vcn_id`, `api_endpoint_subnet_id`, `lb_subnet_id`, and `nodepool_subnet_id` are injected from `terraform-oci-fk-vcn` outputs into `terraform-oci-fk-oke`.
- `security_list_keys` in `terraform-oci-fk-vcn` attach the `oke_api` and `oke_nodes` security lists to the relevant subnets before OKE is created.
- `cluster_type = "basic"` keeps the example on the basic OKE path.
- `is_api_endpoint_subnet_public = true`, `is_lb_subnet_public = true`, and `is_nodepool_subnet_public = true` keep the example reachable in a simple public-network setup.

---

## Deployment Steps

Run the example from this directory:

```bash
tofu init
tofu plan
tofu apply
```

If the apply looks correct, it should create both the reusable VCN foundation and the OKE resources that consume it.

---

## Cleanup

```bash
tofu destroy
```

---

## Summary

This example demonstrates:
- How `terraform-oci-fk-vcn` can build the network foundation for OKE
- How `terraform-oci-fk-oke` can consume an existing OCI VCN and subnet layout
- How to keep networking and workload logic separated into reusable modules

---

## License

Licensed under the Universal Permissive License (UPL), Version 1.0.
See [LICENSE](../../LICENSE) for more details.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
