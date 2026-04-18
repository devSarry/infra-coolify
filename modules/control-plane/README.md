# control-plane module

Creates the Coolify control-plane node on Hetzner Cloud.

This module provisions a server, a dedicated persistent data volume, a firewall, and cloud-init bootstrap logic to install and configure Coolify. The server is attached to the private Hetzner network and prepared for Tailscale-based operator access.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `string` | n/a | Server hostname. |
| `server_type` | `string` | n/a | Hetzner server type. |
| `location` | `string` | n/a | Hetzner location code. |
| `image` | `string` | `"ubuntu-24.04"` | Hetzner image slug. |
| `network_id` | `string` | n/a | ID of Hetzner private network. |
| `private_ip` | `string` | n/a | Static private IP inside subnet. |
| `ssh_public_key_openssh` | `string` | n/a | Public half of Coolify management key. |
| `ssh_private_key_openssh` | `string` | n/a | Private half of Coolify management key. (sensitive) |
| `tailscale_auth_key` | `string` | n/a | One-shot tagged Tailscale auth key. (sensitive) |
| `tailscale_hostname` | `string` | n/a | Tailscale hostname for this node. |
| `coolify_version` | `string` | `"latest"` | Coolify version to install. |
| `data_volume_size` | `number` | `20` | Data volume size in GB. |
| `operator_ssh_public_keys` | `list(string)` | `[]` | Extra SSH public keys for break-glass access. |

## Outputs

| Name | Description |
| --- | --- |
| `id` | Hetzner server ID. |
| `public_ipv4` | Public IPv4 of control plane. |
| `private_ipv4` | Private IPv4 of control plane. |
| `tailscale_hostname` | Tailscale hostname of control plane. |

