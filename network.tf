# network.tf

# VCN Principal
resource "oci_core_vcn" "main_vcn" {
  compartment_id = var.compartment_id
  cidr_block     = "10.0.0.0/16"
  display_name   = "personal-vcn"
  dns_label      = "personalvcn"
}

# Gateways
resource "oci_core_internet_gateway" "main_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "personal-igw"
  enabled        = true
}

resource "oci_core_nat_gateway" "main_nat" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "personal-nat"
}

# Tabelas de Roteamento
resource "oci_core_route_table" "public_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "public-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.main_igw.id
  }
}

resource "oci_core_route_table" "private_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "private-route-table"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.main_nat.id
  }
}

# Subredes
resource "oci_core_subnet" "lb_subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.main_vcn.id
  cidr_block                 = "10.0.1.0/24"
  display_name               = "lb-public-subnet"
  route_table_id             = oci_core_route_table.public_route_table.id
  security_list_ids          = [oci_core_security_list.lb_sl.id]
  dns_label                  = "lbsubnet"
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "app_subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.main_vcn.id
  cidr_block                 = "10.0.2.0/24"
  display_name               = "app-private-subnet"
  route_table_id             = oci_core_route_table.private_route_table.id
  security_list_ids          = [oci_core_security_list.app_sl.id]
  dns_label                  = "appsubnet"
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "data_subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.main_vcn.id
  cidr_block                 = "10.0.3.0/24"
  display_name               = "data-private-subnet"
  route_table_id             = oci_core_route_table.private_route_table.id
  security_list_ids          = [oci_core_security_list.data_sl.id]
  dns_label                  = "datasubnet"
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "lab_subnet" {
  compartment_id             = var.compartment_id
  vcn_id                     = oci_core_vcn.main_vcn.id
  cidr_block                 = "10.0.4.0/24"
  display_name               = "lab-private-subnet"
  route_table_id             = oci_core_route_table.private_route_table.id
  security_list_ids          = [oci_core_security_list.lab_sl.id]
  dns_label                  = "labsubnet"
  prohibit_public_ip_on_vnic = true
}
