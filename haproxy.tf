# Example HAProxy config via Terraform provider

resource "haproxy_global" "global" {
  depends_on = [ null_resource.wait_for_dataplane ]
  user          = "haproxy"
  group         = "haproxy"
  chroot        = "/var/lib/haproxy"
  daemon        = true
  master_worker = true
  maxconn       = 2000
  pidfile       = "/var/run/haproxy.pid"
  ulimit_n      = 2000
  crt_base      = "/etc/ssl/certs"
  ca_base       = "/etc/ssl/private"
  stats_maxconn = 100
  stats_timeout = 60
}

resource "haproxy_defaults" "haproxy_defaults" {
  depends_on = [ null_resource.wait_for_dataplane ]
  name                    = "haproxy_defaults"
  mode                    = "http"
  backlog                 = 10000
  httplog                 = true
  httpslog                = true
  tcplog                  = false
  retries                 = 3
  check_timeout           = 5000
  client_timeout          = 5000
  connect_timeout         = 5000
  http_keep_alive_timeout = 5000
  http_request_timeout    = 5000
  queue_timeout           = 5000
  server_timeout          = 5000
  server_fin_timeout      = 5000
  maxconn                 = 2000
}

resource "haproxy_backend" "backend_web" {
  depends_on = [ null_resource.wait_for_dataplane ]

  name                 = "backend_web"
  mode                 = "http"
  http_connection_mode = "http-keep-alive"
  server_timeout       = 5000
  check_timeout        = 5000
  connect_timeout      = 5000
  queue_timeout        = 5000
  tarpit_timeout       = 5000
  tunnel_timeout       = 5000
  check_cache          = true

  balance {
    algorithm = "roundrobin"
  }

  httpchk_params {
    uri     = "/"
    version = "HTTP/1.1"
    method  = "GET"
  }

  forwardfor {
    enabled = true
  }
}


resource "haproxy_server" "srv1" {
  name        = "srv1"
  port        = 8080
  address     = "100.121.173.17"
  parent_name = haproxy_backend.backend_web.name
  parent_type = "backend"
  send_proxy  = false
  check       = false
  inter       = 3
  rise        = 3
  fall        = 2

  depends_on = [haproxy_backend.backend_web]
}

resource "haproxy_frontend" "frontend_http" {
  name                        = "frontend_http"
  backend                     = haproxy_backend.backend_web.name
  http_connection_mode        = "http-keep-alive"
  accept_invalid_http_request = true
  maxconn                     = 200
  mode                        = "http"
  backlog                     = 1000
  http_keep_alive_timeout     = 5000
  http_request_timeout        = 5000
  http_use_proxy_header       = true
  httplog                     = true
  httpslog                    = false
  tcplog                      = false

  compression {
    algorithms = ["gzip", "identity"]
    offload    = true
    types      = ["text/html", "text/plain", "text/css", "application/javascript"]
  }

  forwardfor {
    enabled = true
    header  = "X-Forwarded-For"
    ifnone  = true
  }

  depends_on = [haproxy_backend.backend_web]
}

resource "haproxy_bind" "bind_test" {
  name        = "bind_test"
  port        = 80
  address     = "0.0.0.0"
  parent_name = "frontend_http"
  parent_type = "frontend"
  maxconn     = 3000
  depends_on  = [haproxy_frontend.frontend_http]
}