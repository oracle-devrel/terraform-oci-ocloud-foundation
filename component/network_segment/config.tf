# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_core_services" "all_services" { } # Request a list of Oracle Service Network (osn) services

data "oci_identity_compartments" "segment" {
  compartment_id = var.config.service_id
  state          = "ACTIVE"
  filter {
    name   = "id"
    values = [ var.config.compartment_id ]
  } 
}

data "oci_core_vcns" "segment" {
  depends_on = [ oci_core_vcn.segment ]
  compartment_id = var.config.compartment_id
  display_name   = local.display_name
  state          = "AVAILABLE"
}

data "oci_core_network_security_groups" "segment" {
  depends_on = [ oci_core_network_security_group.segment ]
  compartment_id = var.config.compartment_id
  display_name   = "${local.display_name}_sec_grp"
  state          = "AVAILABLE"
  vcn_id         = oci_core_vcn.segment.id
}

data "oci_core_internet_gateways" "segment" {
  depends_on = [ oci_core_internet_gateway.segment ]
  compartment_id = var.config.compartment_id
  display_name   = "${local.display_name}_ig"
  state          = "AVAILABLE"
  vcn_id         = oci_core_vcn.segment.id
}

//NAT Gateway
data "oci_core_nat_gateways" "segment" {
  depends_on = [ oci_core_nat_gateway.segment ]
  compartment_id = var.config.compartment_id
  display_name   = "${local.display_name}_ng"
  state          = "AVAILABLE"
  vcn_id         = oci_core_vcn.segment.id
}

data "oci_core_service_gateways" "segment" {
  depends_on = [ oci_core_service_gateway.segment ]
  compartment_id = var.config.compartment_id
  state          = "AVAILABLE"
  vcn_id         = oci_core_vcn.segment.id
}

data "oci_core_drgs" "segment" {
  depends_on = [ oci_core_drg.segment ]
  compartment_id = var.config.compartment_id
  filter {
      name   = "display_name"
      values = [ "${local.display_name}_drg" ]
  }
}

data "oci_core_route_tables" "public" {
  depends_on = [ oci_core_route_table.public ]
  compartment_id = var.config.compartment_id
  display_name   = "${local.display_name}_pub_rt"
  state          = "AVAILABLE"
  vcn_id         = oci_core_vcn.segment.id
}

data "oci_core_route_tables" "private" {
  depends_on = [ oci_core_route_table.private ]
  compartment_id = var.config.compartment_id
  display_name   = "${local.display_name}_priv_rt"
  state          = "AVAILABLE"
  vcn_id         = oci_core_vcn.segment.id
}

data "oci_core_route_tables" "osn" {
  depends_on = [ oci_core_route_table.osn ]
  compartment_id = var.config.compartment_id
  display_name   = "${local.display_name}_osn_rt"
  state          = "AVAILABLE"
  vcn_id         = oci_core_vcn.segment.id
}

locals {
    # naming conventions
    display_name  = "${var.config.display_name}_${var.segment}"
    dns_label     = format("%s%s%s", lower(substr(split("_", var.config.display_name)[0], 0, 3)), lower(substr(split("_", var.config.display_name)[1], 0, 5)), tostring(var.segment))


    # Retrieve CIDR for all Oracle Services
    osn_cidrs        = {for svc in data.oci_core_services.all_services.services : svc.cidr_block => svc.id} # Create a map of cidr for osn 

    # Create a map from network names to allocated address prefixes in CIDR notation
    subnet_ranges    = cidrsubnets(var.network.address_spaces.cidr_block, values(var.network.subnet_list)...)
    subnet_names     = keys(var.network.subnet_list)
    subnet_map       = zipmap(local.subnet_names, local.subnet_ranges)

    # Define route sets as input for the network segment
    public_rule_set  = [local.anywhere_route]
    private_rule_set = [local.nat_route, local.osn_route]
    osn_rule_set     = [local.osn_route]
    # Route traffic to the onprem data center 
    cpe_rule_set     = [local.interconnect]

    # Create route rules objects as input for the route tables
    nat_route = {
        network_entity_id = data.oci_core_nat_gateways.segment.nat_gateways[0].id
        description       = "Route traffic via NAT to the public internet"
        destination       = var.network.address_spaces.anywhere
        destination_type  = "CIDR_BLOCK"
    }
    anywhere_route = {
        network_entity_id = data.oci_core_internet_gateways.segment.gateways[0].id
        description       = "Route traffic to the public internet"
        destination       = var.network.address_spaces.anywhere
        destination_type  = "CIDR_BLOCK"
    }
    objectstorage_route  = {
        network_entity_id = data.oci_core_service_gateways.segment.service_gateways[0].id
        description       = "Route traffic to the Object Store"
        destination       = data.oci_core_services.all_services.services[0].cidr_block
        destination_type  = "SERVICE_CIDR_BLOCK"
    }
    osn_route = {
        network_entity_id = data.oci_core_service_gateways.segment.service_gateways[0].id
        description       = "Route traffic to private Oracle Services"
        destination       = data.oci_core_services.all_services.services[1].cidr_block
        destination_type  = "SERVICE_CIDR_BLOCK"
    }
    interconnect = {
        network_entity_id = data.oci_core_drgs.segment.drgs[0].id
        description       = "Route traffic to the onprem data center"
        destination       = var.network.address_spaces.interconnect
        destination_type  = "CIDR_BLOCK"
    }
}

// Define the wait state for the data requests
// This resource will destroy (potentially immediately) after null_resource.next
resource "null_resource" "previous" {}

resource "time_sleep" "wait" {
  depends_on = [null_resource.previous]
  create_duration = "2m"
}