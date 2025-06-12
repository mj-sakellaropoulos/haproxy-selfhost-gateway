output "haproxy_public_ip" {
  value = linode_instance.haproxy-nanode-01.ip_address
  sensitive = false
}

output "cloudinit_rendered" {
  value = data.template_file.cloudinit.rendered
  sensitive = true
}