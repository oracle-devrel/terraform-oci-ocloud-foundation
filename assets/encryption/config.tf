# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- terraform provider --- 
terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
    }
  }
}

data "oci_identity_compartments" "security" {
  compartment_id = var.tenancy.id
  access_level   = "ANY"
  compartment_id_in_subtree = true
  name           = try(var.encryption.compartment, var.resident.name)
  state          = "ACTIVE"
}

data "oci_vault_secrets" "wallet" {
  depends_on     = [oci_kms_vault.wallet]
  count          = local.wallet_count
  compartment_id = data.oci_identity_compartments.security.compartments[0].id
  state          = "ACTIVE"
  vault_id       = oci_kms_vault.wallet[count.index].id
}

data "oci_kms_key_versions" "wallet" {
  depends_on          = [oci_kms_key.wallet]
  count               = local.wallet_count
  key_id              = oci_kms_key.wallet[count.index].id
  management_endpoint = oci_kms_vault.wallet[count.index].management_endpoint
}

locals {
  wallet_count = var.input.create ? 1 : 0
}

// Define the wait state for the data requests
resource "null_resource" "previous" {}

// This resource will destroy (potentially immediately) after null_resource.next
resource "time_sleep" "wait" {
  depends_on = [null_resource.previous]
  create_duration = "2m"
}