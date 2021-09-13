# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// VCN details
output "vcn" {
  description = "Virtual Cloud Network"
  value       = length(data.oci_core_vcns.segment.virtual_networks) > 0 ? data.oci_core_vcns.segment.virtual_networks[0] : null
}

data "oci_core_vcns" "segment" {
    depends_on     = [time_sleep.wait]
    compartment_id = var.config.compartment_id
    #compartment_id = data.oci_identity_compartment.segment.id
    display_name   = "${var.config.display_name}_vcn"
    state          = "AVAILABLE"
}

output "anywhere"   {
  value       = var.vcn.address_spaces.anywhere
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

// Security Groups
output "security_group" {
  description = "Security Group"
  value       = length(data.oci_core_network_security_groups.segment.network_security_groups) > 0 ? data.oci_core_network_security_groups.segment.network_security_groups[*] : null
}
/*
data "oci_core_network_security_groups" "segment" {
    compartment_id = var.config.compartment_id
    filter {
        name   = "display_name"
        values = ["${var.config.display_name}_security_group"]
    }
}
*/
data "oci_core_network_security_groups" "segment" {
    compartment_id = var.config.compartment_id
    display_name   = "${var.config.display_name}_security_group"
    state          = "AVAILABLE"
    vcn_id         = oci_core_vcn.segment.id
}

// Internet Gateway
output "internet_gateway" {
  description = "Internet Gateway"
  value       = length(data.oci_core_internet_gateways.segment.gateways) > 0 ? data.oci_core_internet_gateways.segment.gateways[0] : null
}
/*
data "oci_core_internet_gateways" "segment" {
    depends_on = [time_sleep.wait]
    compartment_id = data.oci_identity_compartment.segment.id
    filter {
        name   = "display_name"
        values = ["${var.config.display_name}_internet_gateway"]
    }
}
*/

data "oci_core_internet_gateways" "segment" {
  depends_on     = [time_sleep.wait]
  compartment_id = var.config.compartment_id
  display_name   = "${var.config.display_name}_internet_gateway"
  state          = "AVAILABLE"
  vcn_id         = oci_core_vcn.segment.id
}

//NAT Gateway
data "oci_core_nat_gateways" "segment" {
  depends_on = [time_sleep.wait]
  compartment_id = var.config.compartment_id
  #compartment_id = data.oci_identity_compartment.segment.id
  filter {
      name   = "display_name"
      values = ["${var.config.display_name}_nat_gateway"]
  }
}

output "nat_gateway" {
  description = "NAT Gateway"
  value       = length(data.oci_core_nat_gateways.segment.nat_gateways) > 0 ? data.oci_core_nat_gateways.segment.nat_gateways[0] : null
}

// Service Gateway
data "oci_core_service_gateways" "segment" {
  depends_on = [time_sleep.wait]
  compartment_id = var.config.compartment_id
  #compartment_id = data.oci_identity_compartment.segment.id
  filter {
      name   = "display_name"
      values = ["${var.config.display_name}_service_gateway"]
  }
}

output "service_gateway" {
  description = "Service Gateway"
  value       = length(data.oci_core_service_gateways.segment.service_gateways) > 0 ? data.oci_core_service_gateways.segment.service_gateways[0] : null
}

output "osn" {
  description = "Oracle Service Network"
  value       = data.oci_core_services.all_services
}

// DRG
data "oci_core_drgs" "segment" {
  depends_on = [time_sleep.wait]
  compartment_id = var.config.compartment_id
  #compartment_id = data.oci_identity_compartment.segment.id
  filter {
      name   = "display_name"
      values = ["${var.config.display_name}_drg"]
  }
}

output "drg" {
  description = "Dynamic Routing Gateway"
  value       = length(data.oci_core_drgs.segment.drgs) > 0 ? data.oci_core_drgs.segment.drgs[0] : null
}

// Route Tables
## Public
output "public_route_table" {
  description = "Route traffic to the anywhere address space"
  value = oci_core_route_table.private
  #value       = data.oci_core_route_tables.public.route_tables[0]
}

/*
data "oci_core_route_tables" "public" {
  depends_on     = [time_sleep.wait]
  compartment_id = var.config.compartment_id
  display_name   = "${var.config.display_name}_public_route_table"
  state          = "AVAILABLE"
  vcn_id         = oci_core_vcn.segment.id
}
*/

## Private
output "private_route_table"{
  description = "Route traffic inside the VCN"
  value = oci_core_route_table.private
  #value       = data.oci_core_route_tables.private.route_tables[0]
}

/*
data "oci_core_route_tables" "private" {
  depends_on     = [time_sleep.wait]
  compartment_id = var.config.compartment_id
  display_name   = "${var.config.display_name}_private_route_table"
  state          = "AVAILABLE"
  vcn_id         = oci_core_vcn.segment.id
}
*/

## Oracle Service Network
output "osn_route_table" {
  description = "Route traffic to the Oracle Service Network"
  value = oci_core_route_table.osn
  #value       = data.oci_core_route_tables.osn.route_tables[0]
}

/*
data "oci_core_route_tables" "osn" {
  depends_on     = [time_sleep.wait]
  compartment_id = var.config.compartment_id
  display_name   = "${var.config.display_name}_osn_route_table"
  state          = "AVAILABLE"
  vcn_id         = oci_core_vcn.segment.id
}
*/

// Define the wait state for the data requests
# This resource will destroy (potentially immediately) after null_resource.next
resource "null_resource" "previous" {}

resource "time_sleep" "wait" {
  depends_on = [null_resource.previous]
  create_duration = "5m"
}