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

data "oci_identity_compartment" "resident" {id = var.assets.resident.id}
data "oci_identity_compartments" "security" {
  compartment_id = var.config.tenancy.id
  access_level   = "ANY"
  compartment_id_in_subtree = true
  name           = try(var.config.encryption.compartment, var.config.service.name)
  state          = "ACTIVE"
}

data "oci_kms_vaults" "wallet" {
  depends_on          = [
    data.oci_identity_compartments.security
  ]
  compartment_id = data.oci_identity_compartments.security.compartments[0].id
}

data "oci_vault_secrets" "wallet" {
  depends_on     = [
    oci_kms_vault.wallet
  ]
  count          = local.wallet_count
  compartment_id = data.oci_identity_compartments.security.compartments[0].id
  state          = "ACTIVE"
  vault_id       = oci_kms_vault.wallet[count.index].id
}

data "oci_kms_key_versions" "wallet" {
  depends_on          = [
    oci_kms_key.wallet
  ]
  count               = local.wallet_count
  key_id              = oci_kms_key.wallet[count.index].id
  management_endpoint = oci_kms_vault.wallet[count.index].management_endpoint
}

data "oci_secrets_secretbundle" "wallet" {
  depends_on = [
    oci_vault_secret.wallet
  ]
  for_each = local.secret_map
  secret_id = local.secret_map[each.key]
}

locals {
  wallet_count = var.schema.create ? 1 : 0
  secret_map   = {for secret in oci_vault_secret.wallet : secret.secret_name => secret.id}
  existing_wallets = length(data.oci_kms_vaults.wallet.vaults) > 0 ? zipmap(data.oci_kms_vaults.wallet.vaults[*].display_name, data.oci_kms_vaults.wallet.vaults[*].id) : null
  existing_secrets = length(data.oci_vault_secrets.wallet) > 0 ? zipmap(flatten(data.oci_vault_secrets.wallet[*].secrets[*].secret_name), flatten(data.oci_vault_secrets.wallet[*].secrets[*].id)) : null
}

// Define the wait state for the data requests
resource "null_resource" "previous" {}

// This resource will destroy (potentially immediately) after null_resource.next
resource "time_sleep" "wait" {
  depends_on = [null_resource.previous]
  create_duration = "2m"
}