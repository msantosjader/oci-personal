# ==========================================
# 1. OUTPUTS DE REDE (VCN e Subredes)
# ==========================================

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

# ==========================================
# 2. OUTPUTS DE LOAD BALANCER
# ==========================================

output "lb_id" {
  description = "OCID do Network Load Balancer"
  value       = oci_network_load_balancer_network_load_balancer.public_lb.id
}

output "lb_public_ip" {
  description = "IP público do Load Balancer (apontar o DNS para ele)"
  value       = oci_core_public_ip.lb_public_ip.ip_address
}

# ==========================================
# 3. OUTPUTS DE COMPUTE (Instâncias e IPs)
# ==========================================

output "lab_instance_id" {
  description = "OCID da VM Lab"
  value       = oci_core_instance.lab_instance.id
}

output "app_instance_id" {
  description = "OCID da VM App"
  value       = oci_core_instance.app_instance.id
}

output "data_instance_id" {
  description = "OCID da VM Data"
  value       = oci_core_instance.data_instance.id
}

output "instances_private_ips" {
  description = "IPs privados das VMs na VCN"
  value = {
    lab  = oci_core_instance.lab_instance.private_ip
    app  = oci_core_instance.app_instance.private_ip
    data = oci_core_instance.data_instance.private_ip
  }
}