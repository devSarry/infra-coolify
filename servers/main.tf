terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "~> 1.45"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

resource "hcloud_server" "coolify_server" {
  name        = "coolify-server"
  image       = "ubuntu-22.04"
  server_type = "cx21"  # 2 CPU, 4GB RAM
  location    = "hel1-dc2"
  ssh_keys    = var.ssh_keys

  user_data = <<-EOF
    #cloud-config
    package_update: true
    package_upgrade: true
    runcmd:
      - curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
  EOF

  lifecycle {
    ignore_changes = [ ssh_keys ]
  }
}