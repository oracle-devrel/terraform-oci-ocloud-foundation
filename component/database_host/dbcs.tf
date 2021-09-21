# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_database_db_system" "dbaas_db_system" {
  availability_domain = length(var.availability_domains) > 0 ? var.availability_domains : data.oci_identity_availability_domains.ADs.availability_domains[0].name
  compartment_id      = local.db_compartment_id
  database_edition    = local.db_system_database_edition

  db_home {
    database {
      admin_password = var.db_system_db_home_database_admin_password
      db_name        = var.db_system_db_home_database_db_name
      character_set  = var.db_system_db_home_database_character_set
      ncharacter_set = var.db_system_db_home_database_ncharacter_set
      db_workload    = var.db_system_db_home_database_db_workload
      pdb_name       = var.db_system_db_home_database_pdb_name
      tde_wallet_password = var.db_system_db_home_database_tde_wallet_password

      db_backup_config {
        auto_backup_enabled = local.db_system_db_home_database_db_backup_config_auto_backup_enabled
        auto_backup_window = var.db_system_db_home_database_db_backup_config_auto_backup_window
        recovery_window_in_days = var.db_system_db_home_database_db_backup_config_recovery_window_in_days
      }

      #freeform_tags = {
      #  "Department" = "Finance"
      #}
    }

    db_version   = var.db_system_db_home_db_version
    display_name = var.db_system_db_home_display_name
  }
  shape           = local.db_system_shape
  subnet_id       = local.db_subnet_id
  ssh_public_keys = [var.db_system_ssh_public_keys]
  display_name    = var.db_system_display_name
  hostname                = var.db_system_hostname
  data_storage_size_in_gb = local.db_system_data_storage_size_in_gb
  license_model           = var.db_system_license_model
  node_count              = local.db_system_node_count
  cluster_name            = local.db_system_cluster_name
  nsg_ids                 = [local.db_nsg_id]
  db_system_options {
    storage_management = local.db_system_db_system_options_storage_management
  }
  # admin password changes do not impact the state of stack
  lifecycle {
    ignore_changes = [db_home[0].database[0].admin_password]
  }

  #To use defined_tags, set the values below to an existing tag namespace, refer to the identity example on how to create tag namespaces
  #defined_tags = map("example-tag-namespace-all.example-tag", "originalValue")

  #freeform_tags = {
  #  "Department" = "Finance"
  #}
}

output "connection_strings" {
  description = "Database Connection Strings"
  value = oci_database_db_system.dbaas_db_system.db_home[0].database[0].connection_strings[0].all_connection_strings
}

# In order to print all pdb connection strings find the pdb we just created  
data "oci_database_pluggable_databases" "dbaas_db_system_pdbs" {
    compartment_id = local.db_compartment_id
    pdb_name = var.db_system_db_home_database_pdb_name
    state = "AVAILABLE"
}

output "pdb_connection_strings" {
  description = "Pluggable Database Connection Strings"
  #value = data.oci_database_pluggable_databases.dbaas_db_system_pdbs.*.connection_strings[0].all_connection_strings
  #value = data.oci_database_pluggable_databases.dbaas_db_system_pdbs
  value = try(data.oci_database_pluggable_databases.dbaas_db_system_pdbs.pluggable_databases[0].connection_strings[0].all_connection_strings,"")
} 
