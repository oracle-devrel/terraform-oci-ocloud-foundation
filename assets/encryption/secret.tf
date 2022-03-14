# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


resource "random_password" "wallet" {
  count       = length(var.encryption.passwords)
  length      = 16
  min_numeric = 1
  min_lower   = 1
  min_upper   = 1
  min_special = 1
}

resource "oci_vault_secret" "wallet" {
  depends_on     = [oci_kms_vault.wallet, oci_kms_key.wallet]
  for_each       = var.input.create == true ? var.encryption.secrets  : {}
  compartment_id = data.oci_identity_compartments.security.compartments[0].id
  secret_name    = "${oci_kms_vault.wallet[0].display_name}_${each.value.name}"
  vault_id       = oci_kms_vault.wallet[0].id
  defined_tags   = var.assets.resident.defined_tags
  freeform_tags  = var.assets.resident.freeform_tags
  description    = "Secret in the ${oci_kms_vault.wallet[0].display_name} wallet"
  key_id         = oci_kms_key.wallet[0].id
  secret_content {
    content_type = "BASE64"
    content      = base64encode(each.value.phrase)
    name         = each.value.name
    stage        = "CURRENT"
  }
}


/*
data "oci_vault_secret" "wallet" {
  depends_on = [oci_kms_key.wallet]
  secret_id  = oci_vault_secret.wallet.id
}

data "oci_secrets_secretbundle_versions" "wallet" {
  depends_on = [oci_kms_key.wallet]
  secret_id  = oci_vault_secret.wallet.id
}

// Get Secret content
data "oci_secrets_secretbundle" "wallet" {
  depends_on = [oci_kms_key.wallet]
  secret_id  = oci_vault_secret.wallet.id
  stage      = "CURRENT"
}

output "secret_id" {
  value = length(oci_vault_secret.wallet) > 0 ? oci_vault_secret.wallet.id : null
}
*/