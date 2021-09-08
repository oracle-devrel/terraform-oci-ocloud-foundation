# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "vcn" {
  description = "Virtual Cloud Network"
  value       = oci_core_vcn.ocloud
}

output "cidr_block" {
  value       = var.vcn.address_spaces.cidr_block
  description = "Echoes back the base_cidr_block input variable value, for convenience if passing the result of this module elsewhere as an object."
}

output "subnets" {
  value = local.subnet_map
  description = "A list of objects corresponding to each of the objects in the input variable 'networks', each extended with a new attribute 'cidr_block' giving the network's allocated address prefix."
}

output "internet_gateway" {
  description = "Internet Gateway"
  value       = oci_core_internet_gateway.ocloud
}

output "nat_gateway" {
  description = "NAT Gateway"
  value       = oci_core_nat_gateway.ocloud
}

output "service_gateway" {
  description = "Service Gateway"
  value       = oci_core_service_gateway.ocloud
}

output "security_group" {
  description = "Security Group"
  value       = oci_core_network_security_group.ocloud
}

output "drg" {
  description = "Dynamic Routing Gateway"
  value       = length(oci_core_drg.ocloud) > 0 ? oci_core_drg.ocloud[0] : null
}

output "osn" {
  description = "Oracle Service Network"
  value       = data.oci_core_services.all_services
}

output "anywhere"               { value = var.vcn.address_spaces.anywhere }
output "public_route_table_id"  { value = oci_core_route_table.public.id }
output "private_route_table_id" { value = oci_core_route_table.private.id }
output "osn_route_table_id"     { value = oci_core_route_table.osn.id }
