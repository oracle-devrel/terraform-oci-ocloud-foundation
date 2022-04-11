# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- terraform provider --- 
terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}
data "oci_core_services" "all" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}
data "oci_core_services" "storage" {
  filter {
    name   = "name"
    values = ["OCI .* Object Storage"]
    regex  = true
  }
}
data "oci_identity_compartments" "network" {
  compartment_id = var.config.tenancy.id
  access_level   = "ANY"
  compartment_id_in_subtree = true
  name           = try(var.config.network.compartment, var.config.service.name)
  state          = "ACTIVE"
}
data "oci_core_drgs" "segment" {
  depends_on = [oci_core_drg.segment]
  count          = var.config.network.gateways.drg.create == true ? 1 : 0
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
}
data "oci_core_internet_gateways" "segment" {
  depends_on = [oci_core_internet_gateway.segment]
  count          = var.schema.internet == "ENABLE" ? 1 : 0
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  display_name   = var.config.network.gateways.internet.name
  state          = "AVAILABLE"
  vcn_id         = oci_core_vcn.segment.id
}
data "oci_core_nat_gateways" "segment" {
  depends_on = [oci_core_nat_gateway.segment]
  count          = var.schema.nat == "ENABLE" ? 1 : 0
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  display_name   = var.config.network.gateways.nat.name
  state          = "AVAILABLE"
  vcn_id         = oci_core_vcn.segment.id
}
data "oci_core_service_gateways" "segment" {
  depends_on = [oci_core_service_gateway.segment]
  count          = var.schema.osn != "DISABLE" ? 1 : 0
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  state          = "AVAILABLE"
  vcn_id         = oci_core_vcn.segment.id
}
data "oci_core_route_tables" "default" {
  depends_on     = [oci_core_vcn.segment]
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  state          = "AVAILABLE"
  vcn_id         = oci_core_vcn.segment.id
  filter {
    name   = "display_name"
    values = ["Default Route Table for .*"]
    regex  = true
  }
}

locals {
  create_gateways = {
    "drg"      = var.config.network.gateways.drg.create
    "internet" = var.schema.internet == "ENABLE" ? true : false
    "nat"      = var.schema.nat == "ENABLE" ? true : false
    "service"  = var.schema.osn != "DISABLE" ? true : false
  }
  gateway_ids = zipmap(
    local.gateway_list,
    compact([
      length(data.oci_core_drgs.segment) > 0 ? data.oci_core_drgs.segment[0].drgs[0].id : null,
      length(data.oci_core_internet_gateways.segment) > 0 ? data.oci_core_internet_gateways.segment[0].gateways[0].id : null,
      length(data.oci_core_nat_gateways.segment) > 0 ? data.oci_core_nat_gateways.segment[0].nat_gateways[0].id : null,
      length(data.oci_core_service_gateways.segment) > 0 ? data.oci_core_service_gateways.segment[0].service_gateways[0].id : null
    ])
  )
  gateway_list = compact([
    local.create_gateways.drg ? var.config.network.gateways.drg.name : null,
    local.create_gateways.internet ? var.config.network.gateways.internet.name : null,
    local.create_gateways.nat ? var.config.network.gateways.nat.name : null,
    local.create_gateways.service ? var.config.network.gateways.service.name : null
  ])
  osn_ids = {
    "osn"     = lookup(data.oci_core_services.all.services[0], "id")
    "storage" = lookup(data.oci_core_services.storage.services[0], "id")
  }
  route_table_ids   = merge(
    {for table in oci_core_route_table.segment : table.display_name => table.id}, 
    {"${var.config.network.display_name}_default_table" = data.oci_core_route_tables.default.route_tables[0].id}
  )
  security_list_ids = {for list in oci_core_security_list.segment : list.display_name => list.id}
}

// Define the wait state for the data requests
resource "null_resource" "previous" {}

// This resource will destroy (potentially immediately) after null_resource.next
resource "time_sleep" "wait" {
  depends_on = [null_resource.previous]
  create_duration = "2m"
}