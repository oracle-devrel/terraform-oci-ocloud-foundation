# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "database_ids" {
  description = "A list of automous databases created by the database module"
  value       = { for adb in data.oci_database_autonomous_databases.database.autonomous_databases : adb.display_name => adb.id }
}

output "service_console_url" {
  value = oci_database_autonomous_database.database[0].service_console_url
}

output "connection_strings" {
  value = oci_database_autonomous_database.database[0].connection_strings[0].all_connection_strings
}

output "connection_urls" {
  value = oci_database_autonomous_database.database[0].connection_urls[0]
}

output "password" {
  value = var.assets.encryption.passwords[var.database.password]
}