terraform {
  required_providers {
    haproxy = {
      source  = "SepehrImanian/haproxy"
      version = "0.0.7"
    }

    linode = {
      source  = "linode/linode"
      version = "2.41.0"
    }

    tailscale = {
      source = "tailscale/tailscale"
      version = "0.20.0"
    }
  }
}

provider "tailscale" {
  api_key = var.ts_apikey
  tailnet = var.magicdns_domain
}

provider "linode" {
  token = var.linode_token
}

provider "haproxy" {
  url      = "http://${var.haproxy_linode_name}.${var.magicdns_domain}:5555"
  username = var.dataplane_user
  password = var.dataplane_password
}

# Wait for TS

data "tailscale_device" "haproxy_device" {
  name     = "${var.haproxy_linode_name}.${var.magicdns_domain}"
  wait_for = "10m"
  depends_on = [ linode_instance.haproxy-nanode-01 ]
}

# Wait for Dataplane

resource "null_resource" "wait_for_dataplane" {
  depends_on = [ linode_instance.haproxy-nanode-01 ]

  provisioner "local-exec" {
    command = <<EOT
      for i in $(seq 1 30); do
        echo "Attempt $i: Checking dataplane..."
        status=$(curl -s -o /dev/null -w "%%{http_code}" -u "${var.dataplane_user}:${var.dataplane_password}" http://${var.haproxy_linode_name}.${var.magicdns_domain}:5555/v2/services/haproxy/configuration/version)
        if [ "$status" -eq 200 ]; then
          echo "Dataplane is ready."
          exit 0
        fi
        sleep 3
      done
      echo "Dataplane API did not become ready in time"
      exit 1
    EOT
    interpreter = ["bash", "-c"]
  }
}
