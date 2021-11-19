# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# The bundle argument allows to define provisioning tiers with "count = module.input.bundle_id >= 2 ? 1 : 0" 

// --- input ---
variable "bundle" {
    type = string
    description = "deployment bundle parameter"
    default = "free_tier"
}

// --- config ---
variable "bundle_types" {
  type = map(number)
  default = {
    free_tier = 1
    payg      = 2
    standard  = 3
    premium   = 4
  }
}

// --- output ---
output "bundles"     { value = flatten(keys(var.bundle_types)) }
output "bundle_id"   { value = var.bundle_types[var.bundle] }