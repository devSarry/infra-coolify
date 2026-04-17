terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

resource "hcloud_firewall" "this" {
  name = "${var.name}-fw"

  labels = {
    role     = "coolify-app-server"
    instance = var.name
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_server" "this" {
  name        = var.name
  server_type = var.server_type
  location    = var.location
  image       = var.image

  firewall_ids = [hcloud_firewall.this.id]

  network {
    network_id = var.network_id
    ip         = var.private_ip
  }

  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    hostname                   = var.name
    tailscale_auth_key         = var.tailscale_auth_key
    tailscale_hostname         = var.tailscale_hostname
    authorized_ssh_public_keys = [for k in var.authorized_ssh_public_keys : trimspace(k)]
  })

  labels = {
    role     = "coolify-app-server"
    instance = var.name
  }

  lifecycle {
    ignore_changes = [user_data]
  }
}
