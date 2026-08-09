# lb.tf

# IP público reservado para o Network Load Balancer
resource "oci_core_public_ip" "lb_public_ip" {
  compartment_id = var.compartment_id
  lifetime       = "RESERVED"
  display_name   = "personal-lb-ip"

  lifecycle {
    ignore_changes = [private_ip_id]
  }
}

# Network Load Balancer (L3/L4 pass-through real, sem NAT, Always Free)
# Diferente do "Load Balancer" clássico, o NLB não tem shape/bandwidth para configurar.
resource "oci_network_load_balancer_network_load_balancer" "public_lb" {
  compartment_id = var.compartment_id
  display_name   = "personal-nlb"
  subnet_id      = oci_core_subnet.lb_subnet.id
  is_private     = false

  reserved_ips {
    id = oci_core_public_ip.lb_public_ip.id
  }
}

# Backend Set HTTP -> vm-app (Caddy :80)
# O NLB faz SNAT (source = IP do NLB) e o IP real do cliente vai no
# cabeçalho PROXY protocol (is_ppv2enabled no listener). Assim o NSG da
# vm-app pode ficar restrito à subrede do LB.
# is_preserve_source = false: obrigatório com backend por ip_address (o
# default da API é true, que só funciona com backend por target_id).
resource "oci_network_load_balancer_backend_set" "http_backendset" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.public_lb.id
  name                     = "http-caddy"
  policy                   = "FIVE_TUPLE"
  is_preserve_source       = false

  health_checker {
    protocol = "TCP"
    port     = 80
  }
}

# Backend Set HTTPS -> vm-app (Caddy :443)
resource "oci_network_load_balancer_backend_set" "https_backendset" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.public_lb.id
  name                     = "https-caddy"
  policy                   = "FIVE_TUPLE"
  is_preserve_source       = false

  health_checker {
    protocol = "TCP"
    port     = 443
  }
}

# Listeners TCP pass-through (quem trata o TLS é o Caddy na vm-app).
# is_ppv2enabled: envia o IP real do cliente via PROXY protocol v2.
resource "oci_network_load_balancer_listener" "tcp_80" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.public_lb.id
  name                     = "tcp-80"
  default_backend_set_name = oci_network_load_balancer_backend_set.http_backendset.name
  port                     = 80
  protocol                 = "TCP"
  is_ppv2enabled           = true
}

resource "oci_network_load_balancer_listener" "tcp_443" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.public_lb.id
  name                     = "tcp-443"
  default_backend_set_name = oci_network_load_balancer_backend_set.https_backendset.name
  port                     = 443
  protocol                 = "TCP"
  is_ppv2enabled           = true
}

# Backends -> IP privado da vm-app (roteamento local da VCN)
resource "oci_network_load_balancer_backend" "app_http" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.public_lb.id
  backend_set_name         = oci_network_load_balancer_backend_set.http_backendset.name
  ip_address               = oci_core_instance.app_instance.private_ip
  port                     = 80
  weight                   = 1
}

resource "oci_network_load_balancer_backend" "app_https" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.public_lb.id
  backend_set_name         = oci_network_load_balancer_backend_set.https_backendset.name
  ip_address               = oci_core_instance.app_instance.private_ip
  port                     = 443
  weight                   = 1
}
