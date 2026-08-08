# variables.tf

variable "region" {
  description = "Região da OCI onde os recursos serão criados"
  type        = string
  default     = "sa-saopaulo-1"
}

variable "compartment_id" {
  description = "OCID do Compartimento (Tenancy) na OCI"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Caminho da chave pública SSH para acesso às máquinas"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "tailscale_auth_key" {
  description = "Token de autenticação do Tailscale"
  type        = string
  sensitive   = true
}

variable "netdata_claim_token" {
  description = "Token para conectar ao Netdata Cloud"
  type        = string
  sensitive   = true
}

variable "netdata_claim_rooms" {
  description = "ID da Sala (Room) do Netdata Cloud"
  type        = string
}
