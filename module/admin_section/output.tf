# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "compartment_id" {
  description = "Compartment ocid"
  // This allows the compartment ID to be retrieved from the resource if it exists, and if not to use the data source.
  value = oci_identity_compartment.ocloud[0].id
}

output "parent_compartment_id" {
  description = "Parent Compartment ocid"
  // This allows the compartment ID to be retrieved from the resource if it exists, and if not to use the data source.
  value = var.compartment.parent
}

output "compartment_name" {
  description = "Compartment name"
  value = oci_identity_compartment.ocloud[0].name
}

output "compartment_description" {
  description = "Compartment description"
  value = oci_identity_compartment.ocloud[0].description
}

output "group_id" {
  value = oci_identity_group.ocloud.id
}

output "group_name" {
  value = var.group.name
}

output "policies" {
  description = "The policies, are indexed by name."
  value = oci_identity_policy.ocloud.statements
}
