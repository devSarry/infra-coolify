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
    role     = "coolify-control-plane"
    instance = var.name
  }
}

resource "hcloud_volume" "data" {
  name     = "${var.name}-data"
  size     = var.data_volume_size
  location = var.location
  format   = "ext4"

  labels = {
    role     = "coolify-data"
    instance = var.name
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
    hostname                 = var.name
    tailscale_auth_key       = var.tailscale_auth_key
    tailscale_hostname       = var.tailscale_hostname
    coolify_version          = var.coolify_version
    ssh_private_key_openssh  = var.ssh_private_key_openssh
    ssh_public_key_openssh   = trimspace(var.ssh_public_key_openssh)
    data_volume_id           = hcloud_volume.data.id
    operator_ssh_public_keys = var.operator_ssh_public_keys
  })

  labels = {
    role     = "coolify-control-plane"
    instance = var.name
  }

  lifecycle {
    ignore_changes = [user_data]
  }

  depends_on = [hcloud_volume.data]
}

resource "hcloud_volume_attachment" "data" {
  volume_id = hcloud_volume.data.id
  server_id = hcloud_server.this.id
  automount = false
}
