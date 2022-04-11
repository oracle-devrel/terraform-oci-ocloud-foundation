// Copyright (c) 2020 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "encryption" {
  value = {for wallet in local.wallets : wallet.name => {
    compartment = contains(flatten(var.resident.domains[*].name), "operation") ? "${local.service_name}_operation_compartment" : local.service_name
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
    secrets = {for secret in local.secrets : secret.resource => {
      name   = "${local.service_name}_${secret.resource}_secret"
      phrase = secret.phrase
    }if var.solution.encrypt == true}
    passwords = [
      for secret in local.secrets : "${local.service_name}_${secret.resource}_password"
      if var.solution.encrypt == false
    ]
  }}
}