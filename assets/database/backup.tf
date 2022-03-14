# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

/*
resource "oci_database_autonomous_database_backup" "database" {
  #Required
  autonomous_database_id = oci_database_autonomous_database.autonomous_database.id
  display_name           = var.autonomous_database_backup_display_name
}

resource "oci_database_autonomous_database" "database_from_backup" {
  #Required
  admin_password           = random_string.autonomous_database_admin_password.result
  compartment_id           = var.compartment_ocid
  cpu_core_count           = "1"
  data_storage_size_in_tbs = "1"
  db_name                  = "adbdb2"
  clone_type                    = "FULL"
  source                        = "BACKUP_FROM_ID"
  autonomous_database_backup_id = oci_database_autonomous_database_backup.autonomous_database_backup.id
}
*/