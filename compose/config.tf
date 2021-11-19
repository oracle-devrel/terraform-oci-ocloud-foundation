# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
    }
  }
}

// --- input ---
variable "bundle" {
    type = string
    description = "deployment bundle parameter"
    default = "free_tier"
}

// --- config ---
# The bundle argument allows to define provisioning tiers with "count = module.compose.bundle_id >= 2 ? 1 : 0" 
variable "bundles" {
  type = map(number)
  default = {
    free_tier = 1
    payg      = 2
    standard  = 3
    premium   = 4
  }
}

// --- output ---
output "bundles"     { value = flatten(keys(var.bundles)) }
output "bundle_id"   { value = var.bundles[var.bundle] }