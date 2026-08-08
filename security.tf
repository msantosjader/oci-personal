# ==========================================
# 1. SECURITY LISTS (Firewall em Nível de Subrede)
# ==========================================

# Load Balancer Security List: Permite tráfego HTTP/HTTPS de entrada da internet
resource "oci_core_security_list" "lb_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "lb-security-list"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      max = 80
      min = 80
    }
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      max = 443
      min = 443
    }
  }
}

# Security Lists Privadas (App, Data, Lab): Isoladas. Permitem apenas tráfego ICMP interno
resource "oci_core_security_list" "app_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "app-security-list"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "1" # Protocolo 1: ICMP (Ping)
    source   = "10.0.0.0/16"
  }
}

resource "oci_core_security_list" "data_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "data-security-list"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "1"
    source   = "10.0.0.0/16"
  }
}

resource "oci_core_security_list" "lab_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "lab-security-list"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    protocol = "1"
    source   = "10.0.0.0/16"
  }
}


# ==========================================
# 2. NETWORK SECURITY GROUPS (Firewall em Nível de Instância)
# ==========================================

# NSG - App: Permite tráfego web (HTTP/HTTPS) oriundo exclusivamente do Load Balancer
resource "oci_core_network_security_group" "app_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "app-nsg"
}

resource "oci_core_network_security_group_security_rule" "app_rule_80" {
  network_security_group_id = oci_core_network_security_group.app_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "10.0.1.0/24" # Subrede LB
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      max = 80
      min = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "app_rule_443" {
  network_security_group_id = oci_core_network_security_group.app_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "10.0.1.0/24" # Subrede LB
  source_type               = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      max = 443
      min = 443
    }
  }
}

# NSG - Data: Permite conexões nos serviços de banco de dados oriundas das subredes App e Lab
resource "oci_core_network_security_group" "data_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "data-nsg"
}

# Regras de Ingress - PostgreSQL (5432)
resource "oci_core_network_security_group_security_rule" "data_pg_from_app" {
  network_security_group_id = oci_core_network_security_group.data_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source_type               = "CIDR_BLOCK"
  source                    = "10.0.2.0/24"

  tcp_options {
    destination_port_range {
      max = 5432
      min = 5432
    }
  }
}

resource "oci_core_network_security_group_security_rule" "data_pg_from_lab" {
  network_security_group_id = oci_core_network_security_group.data_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source_type               = "CIDR_BLOCK"
  source                    = "10.0.4.0/24"

  tcp_options {
    destination_port_range {
      max = 5432
      min = 5432
    }
  }
}

# Regras de Ingress - Redis (6379)
resource "oci_core_network_security_group_security_rule" "data_redis_from_app" {
  network_security_group_id = oci_core_network_security_group.data_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source_type               = "CIDR_BLOCK"
  source                    = "10.0.2.0/24"

  tcp_options {
    destination_port_range {
      max = 6379
      min = 6379
    }
  }
}

resource "oci_core_network_security_group_security_rule" "data_redis_from_lab" {
  network_security_group_id = oci_core_network_security_group.data_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source_type               = "CIDR_BLOCK"
  source                    = "10.0.4.0/24"

  tcp_options {
    destination_port_range {
      max = 6379
      min = 6379
    }
  }
}

# Regras de Ingress - CouchDB (5984)
resource "oci_core_network_security_group_security_rule" "data_couch_from_app" {
  network_security_group_id = oci_core_network_security_group.data_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source_type               = "CIDR_BLOCK"
  source                    = "10.0.2.0/24"

  tcp_options {
    destination_port_range {
      max = 5984
      min = 5984
    }
  }
}

resource "oci_core_network_security_group_security_rule" "data_couch_from_lab" {
  network_security_group_id = oci_core_network_security_group.data_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source_type               = "CIDR_BLOCK"
  source                    = "10.0.4.0/24"

  tcp_options {
    destination_port_range {
      max = 5984
      min = 5984
    }
  }
}

# NSG - Lab: Isolamento estrito (Zero Trust). Sem regras de Ingress definidas na criação.
resource "oci_core_network_security_group" "lab_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "lab-nsg"
}
