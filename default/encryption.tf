// Copyright (c) 2020 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "encryption" {
  value = {for wallet in var.resolve.wallets : wallet.name => {
    compartment = contains(flatten(var.resolve.domains[*].name), "operation") ? "${local.service_name}_operation_compartment" : local.service_name
    stage     = wallet.stage
    vault     = "${local.service_name}_${wallet.name}_vault"
    key       = {
      name      = "${local.service_name}_${wallet.name}_key"
      algorithm = wallet.algorithm
      length    = wallet.length
    }
    signatures = {for signature in local.signatures : signature.name => {
      message   = signature.message
      type      = signature.type
      algorithm = signature.algorithm
    }if contains(wallet.signatures, signature.name)}
    secrets = {for secret in local.secrets : secret.name => {
      name   = "${local.service_name}_${secret.name}_secret"
      phrase = secret.phrase
    }if contains(wallet.secrets, secret.name)}
    passwords = [for secret in local.secrets : "${secret.name}_password"]
  }}
}