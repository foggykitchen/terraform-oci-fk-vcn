# DHCP contract and backward compatibility tests

The suite uses OpenTofu mock providers and plan-only runs. It never contacts OCI or applies infrastructure and needs no cloud credentials.

Run from the module root:

```sh
tofu init -backend=false
tofu validate
tofu test
```

Use a release with mock-provider support (verified with OpenTofu 1.11.6). Tests do not increase the module's existing `>= 1.6.0` runtime requirement.

The 15 cases cover legacy calls with no DHCP configuration, external IDs, the unchanged legacy output shape, managed resolver/search-domain and custom-DNS options, shared/mixed subnet selection, tag inheritance, explicit null defaults, and rejection of invalid selectors, server options and search domains.

Mock plans exercise HCL and dependency evaluation. They do not verify real DNS reachability, client lease renewal, OCI permissions or service-side behavior.
