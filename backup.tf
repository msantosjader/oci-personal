# ==========================================
# BACKUP ALWAYS FREE DA VM DATA
# ==========================================

resource "oci_core_volume_backup_policy" "data_volume_backup" {
  compartment_id = var.compartment_id
  display_name   = "vm-data-always-free-daily"

  schedules {
    backup_type       = "INCREMENTAL"
    period            = "ONE_DAY"
    retention_seconds = 432000 # 5 dias; mantém no máximo cinco backups
    hour_of_day       = 3
    offset_seconds    = 0
    offset_type       = "STRUCTURED"
    time_zone         = "UTC"
  }
}

resource "oci_core_volume_backup_policy_assignment" "data_boot_volume_backup" {
  asset_id  = oci_core_instance.data_instance.boot_volume_id
  policy_id = oci_core_volume_backup_policy.data_volume_backup.id
}
