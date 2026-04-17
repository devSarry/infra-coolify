locals {
  control_plane_name = "coolify-cp-${var.instance_name}"
}

resource "tls_private_key" "coolify_management" {
  algorithm = "ED25519"
}

resource "tailscale_tailnet_key" "control_plane" {
  reusable      = false
  ephemeral     = false
  preauthorized = true
  tags          = [var.tailscale_tag]
  description   = "${local.control_plane_name} bootstrap"
  expiry        = 3600
}

resource "tailscale_tailnet_key" "app_server" {
  for_each = var.app_servers

  reusable      = false
  ephemeral     = false
  preauthorized = true
  tags          = [var.tailscale_tag]
  description   = "coolify-${each.key}-${var.instance_name} bootstrap"
  expiry        = 3600
}

module "network" {
  source = "../modules/network"

  name            = "coolify-${var.instance_name}"
  ip_range        = "192.168.0.0/16"
  subnet_ip_range = "192.168.1.0/24"
  network_zone    = "eu-central"
}

module "control_plane" {
  source = "../modules/control-plane"

  name        = local.control_plane_name
  server_type = "cx23"
  location    = var.location
  image       = var.image

  network_id = module.network.network_id
  private_ip = "192.168.1.10"

  ssh_public_key_openssh  = tls_private_key.coolify_management.public_key_openssh
  ssh_private_key_openssh = tls_private_key.coolify_management.private_key_openssh

  tailscale_auth_key = tailscale_tailnet_key.control_plane.key
  tailscale_hostname = local.control_plane_name

  coolify_version  = "latest"
  data_volume_size = 20

  operator_ssh_public_keys = var.operator_ssh_public_keys
}

module "app_server" {
  source   = "../modules/app-server"
  for_each = var.app_servers

  name        = "coolify-${each.key}-${var.instance_name}"
  server_type = each.value.server_type
  location    = var.location
  image       = var.image

  network_id = module.network.network_id
  private_ip = each.value.private_ip

  authorized_ssh_public_keys = concat(
    [tls_private_key.coolify_management.public_key_openssh],
    var.operator_ssh_public_keys,
  )

  tailscale_auth_key = tailscale_tailnet_key.app_server[each.key].key
  tailscale_hostname = "coolify-${each.key}-${var.instance_name}"
}
