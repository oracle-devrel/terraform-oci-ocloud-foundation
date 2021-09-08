# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "compartment" {
  description = "compartment details"
  // This allows the compartment details to be retrieved from the resource.
  value = length(data.oci_identity_compartments.section.compartments) > 0 ? data.oci_identity_compartments.section.compartments[0] : null
}

output "roles" {
  description = "administrator roles"
  // This allows the policy details to be retrieved from the resource
  value = length(data.oci_identity_policies.section.policies) > 0 ? data.oci_identity_policies.section.policies[0] : null
}

data "oci_identity_compartments" "section" {
  depends_on = [time_sleep.wait]
  compartment_id = var.config.tenancy_id
  filter {
    name   = "name"
    values = [var.compartment.name]
  }
}

data "oci_identity_policies" "section" {
  depends_on = [time_sleep.wait]
  compartment_id = var.config.tenancy_id
  filter {
    name   = "name"
    values = keys(var.roles)
  }
}

# This resource will destroy (potentially immediately) after deployment
resource "null_resource" "previous" {}

resource "time_sleep" "wait" {
  depends_on = [null_resource.previous]
  create_duration = "2m"
}