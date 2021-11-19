# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
  
output "compartment_id" {
  description = "compartment details"
  // This allows the compartment details to be retrieved from the resource.
  value       = length(data.oci_identity_compartments.section.compartments) > 0 ? data.oci_identity_compartments.section.compartments[0].id : null
}

output "compartment_name" {
  description = "compartment details"
  // This allows the compartment details to be retrieved from the resource.
  value       = length(data.oci_identity_compartments.section.compartments) > 0 ? data.oci_identity_compartments.section.compartments[0].name : null
}

output "roles" {
  description = "administrator roles"
  // This allows the policy details to be retrieved from the resource
  value       = length(data.oci_identity_policies.section.policies) > 0 ? data.oci_identity_policies.section.policies[*].name : null
}