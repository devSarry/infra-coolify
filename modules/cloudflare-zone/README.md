# cloudflare-zone module

Manages Cloudflare DNS records for a Coolify deployment domain.

This module looks up an existing Cloudflare zone and creates A records for the root domain, root wildcard, configured subdomains, and wildcard records under each subdomain. It is designed to support both normal app hostnames and Coolify preview deployments.

## Inputs

| Name | Type | Default | Description |
| --- | --- | --- | --- |
| `domain` | `string` | n/a | The root domain (for example, `example.com`). |
| `origin_ipv4` | `string` | n/a | The IPv4 address of the origin server. |
| `subdomains` | `list(string)` | `[]` | List of subdomains to create A records and wildcards for. |
| `proxied` | `bool` | `true` | Enable Cloudflare proxy (orange cloud) for records. |
| `ttl` | `number` | `1` | DNS TTL in seconds (`1` means automatic). |

## Outputs

| Name | Description |
| --- | --- |
| `zone_id` | Cloudflare zone ID. |
| `zone_name` | Cloudflare zone name. |
| `root_record_id` | ID of the root A record. |
| `subdomain_records` | Map of subdomain A record IDs. |
| `subdomain_wildcard_records` | Map of subdomain wildcard A record IDs. |

