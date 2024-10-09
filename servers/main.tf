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

# Create Volume
resource "hcloud_volume" "coolify_volume" {
  name      = "coolify-volume"
  size      = 20
  format    = "ext4"
  automount = true
  server_id = hcloud_server.coolify_server.id

  labels = {
    environment = "production"
    used_by = "coolify-controller"
  }
}

resource "hcloud_server" "coolify_server" {
  name        = "coolify-server"
  image       = "ubuntu-24.04"
  server_type = "cx22"  # 2 CPU, 4GB RAM
  location    = "hel1"
  ssh_keys    = var.ssh_keys

  user_data = <<-EOF
    #cloud-config
    package_update: true
    package_upgrade: true
    runcmd:
      - curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
  EOF


  labels = {
    environment = "production"
    type        = "coolify-controller"
  }
}

resource "hcloud_server" "coolify_app_server" {
  name        = "coolify-apps"
  server_type = "cx22"
  image       = "ubuntu-24.04"
  location    = "hel1" 
  ssh_keys    = var.ssh_keys

  labels = {
    environment = "production"
    type        = "coolify-app-server"
  }
}
