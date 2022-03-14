# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_kms_vault" "wallet" {
  compartment_id = data.oci_identity_compartments.security.compartments[0].id
  count          = local.wallet_count
  display_name   = var.encryption.vault
  vault_type     = var.input.type
  defined_tags   = var.assets.resident.defined_tags
  freeform_tags  = var.assets.resident.freeform_tags
}

resource "oci_kms_key" "wallet" {
  depends_on = [oci_kms_vault.wallet]
  compartment_id = data.oci_identity_compartments.security.compartments[0].id
  count          = local.wallet_count
  display_name   = var.encryption.key.name
  key_shape {
    algorithm = var.encryption.key.algorithm
    length    = var.encryption.key.length
  }
  management_endpoint = oci_kms_vault.wallet[0].management_endpoint
  defined_tags        = var.assets.resident.defined_tags
  freeform_tags       = var.assets.resident.freeform_tags
  protection_mode     = var.input.type == "DEFAULT" ? "SOFTWARE" : "HSM"
}