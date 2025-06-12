############################################
# Linode Provider & Instance Configuration #
############################################

variable "linode_token" {
  description = "Linode API Token"
  type        = string
  sensitive   = true
}

variable "haproxy_linode_name" {
  type        = string
  default     = "haproxy-nanode-01"
  description = "HAProxy Linode instance name"
}

variable "region" {
  type        = string
  default     = "ca-central"
  description = "Linode region"
}

variable "type" {
  type        = string
  default     = "g6-nanode-1"
  description = "Linode instance type"
}

variable "root_pass" {
  type        = string
  sensitive   = true
  description = "Root password"
}

variable "ssh_keys" {
  type        = list(string)
  description = "List of SSH public keys"
}

variable "tags" {
  type        = list(string)
  default     = ["haproxy"]
}


########################################
# Tailscale & MagicDNS Configuration   #
########################################

variable "ts_apikey" {
  type        = string
  description = "API key for the tailnet"
  sensitive   = true
}

variable "magicdns_domain" {
  type        = string
  description = "Tailscale MagicDNS domain (yourtailnet.ts.net)"
}


##############################################
# HAProxy Data Plane API Installation Config #
##############################################

variable "dataplane_version" {
  type        = string
  description = "Version of HAProxy Dataplane API to install. ! 3.x versions are incompatible !"
  default     = "2.9.13"
}

variable "dataplane_arch" {
  type        = string
  description = "Architecture for the HAProxy Dataplane API (e.g., amd64, arm64)"
  default     = "amd64"
}


######################################
# HAProxy Data Plane API Credentials #
######################################

variable "dataplane_user" {
  type        = string
  description = "Username for HAProxy Dataplane API"
  default     = "admin"
}

variable "dataplane_password" {
  type        = string
  description = "Password for HAProxy Dataplane API"
  sensitive   = true
}
