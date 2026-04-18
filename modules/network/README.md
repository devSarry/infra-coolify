# network module

Creates the private Hetzner network used by the Coolify deployment.

This module provisions a `hcloud_network` and one cloud subnet for server attachment. It provides the network ID and subnet range so other modules can place control-plane and app servers on the same private address space.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `string` | n/a | Base name for network resources. |
| `ip_range` | `string` | n/a | CIDR of whole private network. |
| `subnet_ip_range` | `string` | n/a | CIDR of subnet servers attach to. |
| `network_zone` | `string` | n/a | Hetzner network zone. |

## Outputs

| Name | Description |
| --- | --- |
| `network_id` | ID of Hetzner network. |
| `subnet_ip_range` | CIDR of created subnet. |

