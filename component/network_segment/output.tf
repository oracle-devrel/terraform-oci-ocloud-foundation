# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// VCN details
output "vcn_id" {
  description = "Virtual Cloud Network"
  value       = length(data.oci_core_vcns.segment.virtual_networks) > 0 ? data.oci_core_vcns.segment.virtual_networks[0].id : null
}

output "anywhere"   {
  value       = var.network.address_spaces.anywhere
  description = "Echoes back the anywhere setting for the vcn module"
}

output "cidr_block" {
  value       = length(data.oci_core_vcns.segment.virtual_networks) > 0 ? data.oci_core_vcns.segment.virtual_networks[0].cidr_blocks[0] : null  
  description = "Echoes back the base_cidr_block input variable value, for convenience if passing the result of this module elsewhere as an object."
}

output "subnets" {
  value        = local.subnet_map
  description = "A list of objects corresponding to each of the objects in the input variable 'networks', each extended with a new attribute 'cidr_block' giving the network's allocated address prefix."
}

// DRG
output "drg_id" {
  description = "Dynamic Routing Gateway"
  value       = length(data.oci_core_drgs.segment.drgs) > 0 ? data.oci_core_drgs.segment.drgs[0].id : null
}

// Security Groups
output "security_group" {
  description = "Security Group"
  value       = length(data.oci_core_network_security_groups.segment.network_security_groups) > 0 ? data.oci_core_network_security_groups.segment.network_security_groups[*] : null
}
// Internet Gateway
output "internet_id" {
  description = "Internet Gateway"
  value       = length(data.oci_core_internet_gateways.segment.gateways) > 0 ? data.oci_core_internet_gateways.segment.gateways[0].id : null
}

output "nat_id" {
  description = "NAT Gateway"
  value       = length(data.oci_core_nat_gateways.segment.nat_gateways) > 0 ? data.oci_core_nat_gateways.segment.nat_gateways[0].id : null
}

// Service Gateway
output "osn_id" {
  description = "Service Gateway"
  value       = length(data.oci_core_service_gateways.segment.service_gateways) > 0 ? data.oci_core_service_gateways.segment.service_gateways[0].id : null
}

output "osn" {
  description = "Oracle Service Network"
  value       = data.oci_core_services.all_services
}

## Oracle Service Network
output "osn_route_table_id" {
  description = "Route traffic to the Oracle Service Network"
  #value = oci_core_route_table.osn.id
  value       = length(data.oci_core_route_tables.osn.route_tables) > 0 ? data.oci_core_route_tables.osn.route_tables[0].id : null
}

// Route Tables
## Public
output "public_route_table_id" {
  description = "Route traffic to the anywhere address space"
  #value = oci_core_route_table.private.id
  value       = length(data.oci_core_route_tables.public.route_tables) > 0 ? data.oci_core_route_tables.public.route_tables[0].id : null
}

## Private
output "private_route_table_id"{
  description = "Route traffic inside the VCN"
  #value = oci_core_route_table.private.id
  value       = length(data.oci_core_route_tables.private.route_tables) > 0 ? data.oci_core_route_tables.private.route_tables[0].id : null
}