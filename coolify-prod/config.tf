terraform {
  required_version = ">= 1.9"

  cloud {
    organization = "devsarry"

    workspaces {
      name = "infra-coolify"
    }
  }


  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.60"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }

    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.17"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "hcloud" {
}

provider "cloudflare" {
}

provider "tailscale" {
  oauth_client_id     = var.tailscale_oauth_client_id
  oauth_client_secret = var.tailscale_oauth_client_secret
  tailnet             = var.tailscale_tailnet
  scopes              = ["auth_keys"]
}
