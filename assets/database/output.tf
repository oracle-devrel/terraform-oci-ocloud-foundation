# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "database_ids" {
  description = "A list of automous databases created by the database module"
  value       = length(oci_database_autonomous_database.database) > 0 ? {for adb in data.oci_database_autonomous_databases.database.autonomous_databases : adb.display_name => adb.id} : null
}

output "service_console_url" {
  value = length(oci_database_autonomous_database.database) > 0 ? oci_database_autonomous_database.database[0].service_console_url : null
}

output "connection_strings" {
  value = length(oci_database_autonomous_database.database) > 0 ? oci_database_autonomous_database.database[0].connection_strings[0].all_connection_strings : null
}

output "connection_urls" {
  value = length(oci_database_autonomous_database.database) > 0 ? oci_database_autonomous_database.database[0].connection_urls[0] : null
}

output "password" {
  value = length(oci_database_autonomous_database.database) > 0 ? try(
    var.assets.encryption.passwords[var.config.database.password], 
    base64decode(data.oci_secrets_secretbundle.database.secret_bundle_content.0.content)
  ) : null
}