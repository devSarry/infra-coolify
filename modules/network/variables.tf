variable "name" {
  description = "Base name for network resources."
  type        = string
}

variable "ip_range" {
  description = "CIDR of whole private network."
  type        = string
}

variable "subnet_ip_range" {
  description = "CIDR of subnet servers attach to."
  type        = string
}

variable "network_zone" {
  description = "Hetzner network zone."
  type        = string
}
