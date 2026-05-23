# OCI VCN with Terraform/OpenTofu - Training Examples

This directory contains all progressive examples used with the **terraform-oci-fk-vcn** module.
The examples are designed as **incremental building blocks**, starting from a minimal OCI Virtual Cloud Network (VCN)
and preparing the networking foundation for real-world workloads such as **OKE** and future private connectivity scenarios.

These examples are part of the **[FoggyKitchen.com training ecosystem](https://foggykitchen.com/courses-2/)** and are used across OCI
and multicloud courses covering networking, Kubernetes, and infrastructure automation.

---

## 🧭 Example Overview

| Example | Title | Key Topics |
|:-------:|:------|:-----------|
| 01 | **Basic VCN** | Minimal VCN with one public subnet, Internet Gateway, and route table |

Each example builds on the **concepts** introduced in the previous one, but can be applied
independently for learning and experimentation.

---

## ⚙️ How to Use

Each example directory contains:
- Terraform/OpenTofu configuration (`.tf`)
- A focused `README.md` explaining the goal of the example
- A minimal, runnable architecture

To run an example:

```bash
cd examples/01-basic-vcn
tofu init
tofu plan
tofu apply
```

You can apply examples independently. As additional examples are added, the **recommended approach is sequential**.

This mirrors real-world network design, where complexity is added only when required.

---

## 🧩 Design Principles

- One example = one architectural goal
- No unused or placeholder resources
- Clear separation of concerns
- Networking designed to be consumed by other modules such as OKE

These examples intentionally avoid:
- Full landing zones
- Opinionated enterprise frameworks
- Hidden dependencies between examples

---

## 🧩 Related Resources

- [FoggyKitchen OCI VCN Module (terraform-oci-fk-vcn)](../)
- [FoggyKitchen OCI OKE Module (terraform-oci-fk-oke)](https://github.com/mlinxfeld/terraform-oci-fk-oke)
- [FoggyKitchen Azure VNet Module (terraform-az-fk-vnet)](https://github.com/mlinxfeld/terraform-az-fk-vnet)

---

## 🪪 License

Licensed under the **Universal Permissive License (UPL), Version 1.0**.  
See [LICENSE](../LICENSE) for details.

---

© 2026 [FoggyKitchen.com](https://foggykitchen.com) - Cloud. Code. Clarity.
