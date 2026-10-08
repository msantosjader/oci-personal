# ==========================================
# 1. BUSCA AUTOMÁTICA DE IMAGEM (Ubuntu 24.04 ARM)
# ==========================================
data "oci_core_images" "ubuntu_arm" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# ==========================================
# 2. INSTÂNCIA DE LAB (2 OCPU / 12 GB RAM)
# ==========================================
resource "oci_core_instance" "lab_instance" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.test_ads.availability_domains[0].name
  display_name        = "vm-lab"
  shape               = "VM.Standard.A1.Flex"

  lifecycle {
    ignore_changes = [source_details]
  }

  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_arm.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.lab_subnet.id
    nsg_ids          = [oci_core_network_security_group.lab_nsg.id]
    assign_public_ip = false
  }

  metadata = {
    ssh_authorized_keys = file(pathexpand(var.ssh_public_key_path))
    user_data = base64encode(templatefile("${path.module}/scripts/cloud-init.yaml", {
      tailscale_auth_key  = var.tailscale_auth_key
      netdata_claim_token = var.netdata_claim_token
      netdata_claim_rooms = var.netdata_claim_rooms
    }))
  }
}

# ==========================================
# 3. INSTÂNCIA DE APP (1 OCPU / 6 GB RAM)
# ==========================================
resource "oci_core_instance" "app_instance" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.test_ads.availability_domains[0].name
  display_name        = "vm-app"
  shape               = "VM.Standard.A1.Flex"

  lifecycle {
    ignore_changes = [source_details]
  }

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_arm.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.app_subnet.id
    nsg_ids          = [oci_core_network_security_group.app_nsg.id]
    assign_public_ip = false
  }

  metadata = {
    ssh_authorized_keys = file(pathexpand(var.ssh_public_key_path))
    user_data = base64encode(templatefile("${path.module}/scripts/cloud-init.yaml", {
      tailscale_auth_key  = var.tailscale_auth_key
      netdata_claim_token = var.netdata_claim_token
      netdata_claim_rooms = var.netdata_claim_rooms
    }))
  }
}

# ==========================================
# 4. INSTÂNCIA DE DATA (1 OCPU / 6 GB RAM)
# ==========================================
resource "oci_core_instance" "data_instance" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.test_ads.availability_domains[0].name
  display_name        = "vm-data"
  shape               = "VM.Standard.A1.Flex"

  lifecycle {
    ignore_changes = [source_details]
  }

  shape_config {
    ocpus         = 1
    memory_in_gbs = 6
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_arm.images[0].id
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.data_subnet.id
    nsg_ids          = [oci_core_network_security_group.data_nsg.id]
    assign_public_ip = false
  }

  metadata = {
    ssh_authorized_keys = file(pathexpand(var.ssh_public_key_path))
    user_data = base64encode(templatefile("${path.module}/scripts/cloud-init.yaml", {
      tailscale_auth_key  = var.tailscale_auth_key
      netdata_claim_token = var.netdata_claim_token
      netdata_claim_rooms = var.netdata_claim_rooms
    }))
  }
}
