# outputs.tf

output "vcn_id" {
  description = "OCID da VCN Principal"
  value       = oci_core_vcn.main_vcn.id
}

output "lb_subnet_id" {
  description = "OCID da Subrede do Load Balancer (Pública)"
  value       = oci_core_subnet.lb_subnet.id
}

output "app_subnet_id" {
  description = "OCID da Subrede de App (Privada)"
  value       = oci_core_subnet.app_subnet.id
}

output "data_subnet_id" {
  description = "OCID da Subrede de Data (Privada)"
  value       = oci_core_subnet.data_subnet.id
}

output "lab_subnet_id" {
  description = "OCID da Subrede de Lab (Privada)"
  value       = oci_core_subnet.lab_subnet.id
}
