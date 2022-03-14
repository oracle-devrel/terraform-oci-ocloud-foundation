# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- Resident ---//
output "compartment_id" {
  description = "OCID for the network compartment"
  value = data.oci_identity_compartments.network.compartments[0].id
}
// --- Resident ---//

// --- Network Topology ---//
output "vcn_id" {
  description = "Identifier for the Virtual Cloud Network (VCN)"
  value       = length(oci_core_vcn.segment) > 0 ? oci_core_vcn.segment.id : null
}

output "gateway_ids" {
  description = "A list of gateways for the Virtual Cloud Network (VCN)"
  value = local.gateway_ids
}

output "subnet_ids" {
  description = "A list of subnets for the Virtual Cloud Network (VCN)"
  value       = {for network in oci_core_subnet.segment : network.display_name => network.id}
}
// --- Network Topology ---//

// --- Routing ---//
output "route_table_ids" {
  description = "A list of route_tables for the Virtual Cloud Network (VCN)"
  value       = local.route_table_ids
}
// --- Routing ---//

// --- Security ---//
output "security_list_ids" {
  description = "All security lists defined for the Virtual Cloud Network (VCN)"
  value       = local.security_list_ids
}

output "security_group_ids" {
  description = "Security Group"
  value       = {for group in oci_core_network_security_group.segment : group.display_name => group.id}
}
// --- Security ---//