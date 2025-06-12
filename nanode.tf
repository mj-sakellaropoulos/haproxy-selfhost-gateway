resource "tailscale_tailnet_key" "ts_auth_key" {
  reusable      = false
  ephemeral     = false
  preauthorized = true
  expiry        = 3600
  description   = "Temporary key for terraform"
}

data "template_file" "cloudinit" {
  depends_on = [tailscale_tailnet_key.ts_auth_key]
  template   = file("${path.module}/haproxy.yaml.tmpl")
  vars = {
    ts_authkey          = tailscale_tailnet_key.ts_auth_key.key
    dataplane_user      = var.dataplane_user
    dataplane_password  = var.dataplane_password
    dataplane_version   = var.dataplane_version
    dataplane_arch      = var.dataplane_arch
    haproxy_linode_name = var.haproxy_linode_name
  }
}

resource "linode_instance" "haproxy-nanode-01" {
  depends_on      = [data.template_file.cloudinit]
  label           = var.haproxy_linode_name
  image           = "linode/ubuntu24.04"
  region          = var.region
  type            = var.type
  root_pass       = var.root_pass
  authorized_keys = var.ssh_keys
  private_ip      = false
  booted          = true

  metadata {
    user_data = base64encode(data.template_file.cloudinit.rendered)
  }

  tags = var.tags
}

