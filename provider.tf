# provider.tf

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0"
    }
  }
}

provider "oci" {
  region = var.region
}

# Consulta dinâmica das Zonas de Disponibilidade (ADs).
data "oci_identity_availability_domains" "test_ads" {
  compartment_id = var.compartment_id
}
