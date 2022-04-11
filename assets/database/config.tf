# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- terraform provider --- 
terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

data "oci_identity_compartments" "database" {
  compartment_id = var.config.tenancy.id
  access_level   = "ANY"
  compartment_id_in_subtree = true
  name           = try(var.config.database.compartment, var.config.service.name)
  state          = "ACTIVE"
}

data "oci_secrets_secretbundle" "database" {
  secret_id = var.assets.encryption.secret_ids["${var.config.database.display_name}_secret"]
}
data "oci_database_autonomous_databases" "database" {
  compartment_id = data.oci_identity_compartments.database.compartments[0].id
}

locals {
  adb_count = var.schema.create ? 1 : 0
}


// Define the wait state for the data requests
resource "null_resource" "previous" {}

// This resource will destroy (potentially immediately) after null_resource.next
resource "time_sleep" "wait" {
  depends_on = [null_resource.previous]
  create_duration = "2m"
}