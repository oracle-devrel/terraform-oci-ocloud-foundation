# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_database_autonomous_database" "database" {
  depends_on = [
    data.oci_identity_compartments.database,
    data.oci_secrets_secretbundle.database
  ]
  compartment_id           = data.oci_identity_compartments.database.compartments[0].id
  count                    = local.adb_count
  cpu_core_count           = var.config.database.cores
  data_storage_size_in_tbs = var.config.database.storage
  db_name                  = var.config.database.name
  admin_password           = var.schema.password == "RANDOM" ? var.assets.encryption.passwords[var.config.database.password] : base64decode(data.oci_secrets_secretbundle.database.secret_bundle_content.0.content)
  db_version               = var.config.database.version
  display_name             = var.config.database.display_name
  db_workload              = var.config.database.type
  is_free_tier             = var.schema.class == "FREE_TIER" ? true : false
  license_model            = var.config.database.license
  defined_tags             = var.assets.resident.defined_tags
  freeform_tags            = var.assets.resident.freeform_tags
}