# app-server module

Creates a Coolify app worker node on Hetzner Cloud.

This module provisions a server, attaches a minimal public firewall for HTTP/HTTPS, joins the node to the private Hetzner network, and bootstraps it with cloud-init (including Tailscale and SSH keys). It is intended for application workloads, not for running the Coolify control plane.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `name` | `string` | n/a | Server hostname. |
| `server_type` | `string` | n/a | Hetzner server type. |
| `location` | `string` | n/a | Hetzner location code. |
| `image` | `string` | `"ubuntu-24.04"` | Hetzner image slug. |
| `network_id` | `string` | n/a | ID of Hetzner private network. |
| `private_ip` | `string` | n/a | Static private IP inside subnet. |
| `authorized_ssh_public_keys` | `list(string)` | n/a | SSH public keys installed into root `authorized_keys`. |
| `tailscale_auth_key` | `string` | n/a | One-shot Tailscale auth key. (sensitive) |
| `tailscale_hostname` | `string` | n/a | Tailscale hostname for this node. |

## Outputs

| Name | Description |
| --- | --- |
| `id` | Hetzner server ID. |
| `public_ipv4` | Public IPv4 of app server. |
| `private_ipv4` | Private IPv4 of app server. |
| `tailscale_hostname` | Tailscale hostname of app server. |

