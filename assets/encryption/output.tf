# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "existing_wallets" {
  value = local.existing_wallets
}

output "existing_secrets" {
  value = local.existing_secrets
}

output "compartment_id" {
  description = "OCID for the security compartment"
  value = data.oci_identity_compartments.security.compartments[0].id
}

output "vault_id" {
  description = "Identifier for the key management service (KMS) vault"
  value       = length(oci_kms_vault.wallet) > 0 ? oci_kms_vault.wallet[0].id : null
}

output "vault_type" {
  description = "Type of key management service (KMS) vault"
  value       = var.schema.type
}

output "key_id" {
  description = "Identifier for the master key, created for the vault"
  value       = length(oci_kms_key.wallet) > 0 ? oci_kms_key.wallet[0].id : null
}

output "passwords" {
  value = {for password in var.config.encryption.passwords : password => random_password.wallet[index(var.config.encryption.passwords, password)].result}
  sensitive = true 
}

output "secret_ids" {
  description = "A list of secrets defined for the resident."
  value       = local.secret_map
}

output "secret_content" {
  value = {for secret in data.oci_secrets_secretbundle.wallet: secret.version_name => base64decode(secret.secret_bundle_content.0.content)}
}