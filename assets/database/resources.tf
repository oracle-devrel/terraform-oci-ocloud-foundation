# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_database_autonomous_database" "database" {
  compartment_id           = data.oci_identity_compartments.database.compartments[0].id
  count                    = local.adb_count
  cpu_core_count           = var.database.cores
  data_storage_size_in_tbs = var.database.storage
  db_name                  = var.database.name
  admin_password           = var.assets.encryption.passwords[var.database.password] 
  db_version               = var.database.version
  display_name             = var.database.display_name
  db_workload              = var.database.type
  is_free_tier             = var.tenancy.class    == "FREE_TIER" ? "true" : "false"
  license_model            = var.database.license
  defined_tags             = var.assets.resident.defined_tags
  freeform_tags            = var.assets.resident.freeform_tags
}