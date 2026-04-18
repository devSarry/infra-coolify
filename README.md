# infra-coolify

Terraform for a Coolify deployment on Hetzner, accessed via Tailscale, with Cloudflare managing DNS.

## Architecture

- **Control plane** — Hetzner server running Coolify. No public inbound ports. Reachable only via Tailscale.
- **App server(s)** — Hetzner servers where your apps actually run. Public 80/443 for app traffic. SSH only via Tailscale.
- **Private network** — `192.168.0.0/16`. Coolify uses this for control-plane-to-app-server orchestration.
- **Cloudflare DNS** — manages `apps.<your-domain>` and `*.apps.<your-domain>` for app hostnames and PR previews. DNS-only (not proxied) on the free plan.
- **Tailscale** — overlay network for operator access. Both servers join a tagged tailnet.

## One-time prerequisites

### 1. Tailscale ACL policy

Your tailnet policy needs to declare the tag(s) Terraform will use. The OAuth client can only mint keys for tags that already exist in the policy.

Open your tailnet policy at `https://login.tailscale.com/admin/acls` and add one `tagOwners` entry per deployment:

```jsonc
{
  "tagOwners": {
    "tag:coolify-prod":    ["autogroup:admin"],
    "tag:coolify-staging": ["autogroup:admin"]
  }
}
```

The tag format is `tag:coolify-<instance_name>`. If you deploy a workspace with `instance_name = "prod"`, you need `tag:coolify-prod` declared.

### 2. Tailscale OAuth client

At `https://login.tailscale.com/admin/settings/oauth`:

- Create a new OAuth client
- Scope: **Auth Keys** (read + write)
- Tags: add every `tag:coolify-*` you'll use (or the specific ones)
- Save the client ID and secret — you'll set them in TFC

### 3. Cloudflare API token

At `https://dash.cloudflare.com/profile/api-tokens`:

- Create a custom token
- Permissions: **Zone → DNS → Edit**
- Zone resources: include the specific zone you're managing (e.g., `example.com`)
- Save the token

### 4. Hetzner Cloud token

At `https://console.hetzner.cloud/` → your project → Security → API Tokens:

- Create a token with **Read & Write**
- Save it

### 5. Terraform Cloud

At `https://app.terraform.io`:

- Create an organization (or reuse one). Update `coolify-prod/config.tf`'s `cloud.organization` to match.
- Create the workspace `infra-coolify` (matches `coolify-prod/config.tf`).
- Set the workspace **Execution Mode** depending on how you want to run:
  - **Local** → run `terraform plan/apply` on your machine while keeping state in Terraform Cloud.
  - **Remote** (or **Agent**) → run plans/applies in Terraform Cloud.
- In each workspace, set these as **sensitive** workspace variables (env or terraform vars):
  - `hcloud_token`
  - `cloudflare_api_token`
  - `tailscale_oauth_client_id`
  - `tailscale_oauth_client_secret`
- Set non-sensitive vars either in the workspace UI or in a committed `*.auto.tfvars` file:
  - `instance_name`, `base_domain`, `cloudflare_zone_id`, `tailscale_tailnet`, etc.

## Deploying

Install Tailscale on your laptop and log in so MagicDNS names resolve:

```sh
# macOS
brew install --cask tailscale
# Linux
curl -fsSL https://tailscale.com/install.sh | sh
tailscale up
```

Then:

```sh
terraform init
terraform plan
terraform apply
```

Apply takes roughly 5–10 minutes end-to-end. The Hetzner servers come up in ~30 seconds; the rest is cloud-init (Tailscale install, Docker install, Coolify install).

## Post-apply: register app servers in Coolify

Terraform can't do the final step — Coolify needs to adopt each app server through its UI. This is a one-time, one-click-ish operation per app server.

1. **Open Coolify** over Tailscale:

   ```sh
   terraform output coolify_ui
   # → http://coolify-cp-prod:8000
   open http://coolify-cp-prod:8000
   ```

   (MagicDNS resolves `coolify-cp-prod` to the control plane's tailnet IP.)

2. **Complete the admin registration** screen the first time.

3. **Grab the management SSH private key:**

   ```sh
   terraform output -raw coolify_management_ssh_private_key
   ```

4. In Coolify UI: **Keys → Add new private key** → paste the key → name it `coolify-management`.

5. For each app server (`terraform output app_servers` shows them all):

   - **Servers → Add new server**
   - Name: `coolify-app-1-prod` (match the tailscale hostname)
   - IP: the **private IP** from `app_servers` output (e.g. `192.168.1.20`) — stays on the Hetzner private network
   - User: `root`
   - Port: `22`
   - Private key: select `coolify-management`
   - Click **Check connection** — should turn green
   - Save

  If Coolify says `Your password has expired. Password change required but no TTY available.`, the app server image still has root password expiry enabled. Existing servers can be fixed once over SSH:

  ```sh
  ssh root@<app-server-tailnet-ip>
  passwd -l root || true
  chage -d -1 root
  chage -I -1 -m 0 -M 99999 -E -1 root
  ```

  New servers created after this template change apply the fix automatically during cloud-init.

6. **Verify wildcard DNS** resolves to your app server's public IP:

   ```sh
   dig +short test.apps.example.com
   # → should match `terraform output -json app_servers | jq -r '."app-1".public_ipv4'`
   ```

7. **Set the instance base domain** in Coolify: Settings → `apps.example.com`. This is what Coolify uses when generating app URLs.

## Deploying apps with PR previews

In Coolify, when creating a resource from a GitHub/GitLab repo:

- **Domain** field: leave blank → Coolify auto-assigns under `apps.example.com`
- **Preview deployments** setting: enable it. Coolify will create `pr-<number>.apps.example.com` for each open pull request.

The wildcard DNS record makes this work without any per-PR Terraform runs.

## Scaling

**Add an app server:** append an entry to the `app_servers` map in your tfvars:

```hcl
app_servers = {
  "app-1" = { server_type = "cx22", private_ip = "192.168.1.20" }
  "app-2" = { server_type = "cx32", private_ip = "192.168.1.21" }  # new
}
```

Then `terraform apply`. After it finishes, go to Coolify UI and add the new server (same steps as above).

**Resize a server:** change `server_type` on an entry and apply. Hetzner resizes in place with a brief reboot.

## Spinning up a new independent deployment

1. Add `tag:coolify-<new-name>` to your tailnet ACL policy.
2. This stack currently targets one TFC workspace (`infra-coolify`). For an additional independent deployment, copy this stack (or update backend workspace name in `coolify-prod/config.tf`) and point it at a different workspace.
3. Set its workspace variables (new `instance_name`, same tokens).
4. `terraform apply`.

Nothing is shared with other deployments — separate network, servers, DNS, Tailscale tag, Coolify install.

## Destroying

```sh
terraform destroy
```

Everything goes: servers, volume (and all Coolify data on it), firewall, network, DNS records, Tailscale devices (deregister via the tailscale admin UI afterwards — auth keys don't auto-clean devices).

**Before destroying a deployment you care about:** enable Coolify's S3 backups to Hetzner Object Storage from the UI (Settings → Backup). Without that, `destroy` wipes your projects, apps, and deployment history.

## Break-glass access

If Tailscale is down or your account is locked out, use **Hetzner Cloud Console** (web terminal via the Hetzner dashboard). It works regardless of firewall rules. From there you can:

- Check cloud-init logs: `less /var/log/coolify-bootstrap.log`
- Verify Tailscale state: `tailscale status`
- Manually SSH out: not possible publicly since SSH is firewalled — use the console

If you set `operator_ssh_public_keys`, those keys are in `/root/.ssh/authorized_keys` and work over Tailscale. They don't help if Tailscale itself is down — use the Hetzner Cloud Console then.

## Files

```
coolify-prod/
  config.tf                  providers + Terraform Cloud backend
  variables.tf               root inputs with validation
  main.tf                    module wiring + Tailscale keys + TLS keypair
  outputs.tf                 useful values after apply
  terraform.tfvars.example
  modules/
    network/                 hcloud_network + subnet (192.168.0.0/16)
    control-plane/           server + data volume + firewall + cloud-init
    app-server/              server + firewall + cloud-init
    cloudflare-zone/         apex + wildcard A records
```

## Notes

- Cloudflare is **DNS-only**, not a proxy. Free plan wildcard proxying isn't supported, and DNS-01 lets Traefik (inside Coolify) issue Let's Encrypt certs automatically.
- The control plane's data volume is formatted once and persists across server replacements — but a full `terraform destroy` removes it.
- Coolify's management SSH private key is generated by Terraform (`tls_private_key`) and stored in TFC state (encrypted at rest). It's the same key across the control plane and every app server's `authorized_keys`, which is why you can add new app servers without ever touching existing ones.
- Hetzner network `192.168.0.0/16` is chosen deliberately to avoid conflicts with Coolify's `10.x` Docker networks and Docker's default `172.17+` bridges.
