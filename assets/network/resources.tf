# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


resource "oci_core_vcn" "segment" {
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  display_name   = var.network.display_name
  dns_label      = var.network.dns_label
  cidr_block     = var.network.cidr
  is_ipv6enabled = var.input.ipv6
  defined_tags   = var.assets.resident.defined_tags
  freeform_tags  = var.assets.resident.freeform_tags
}

resource "oci_core_drg" "segment" {
  depends_on     = [oci_core_vcn.segment]
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  count          = local.create_gateways.drg ? 1 : 0
  display_name   = var.network.gateways.drg.name
  defined_tags   = var.assets.resident.defined_tags
  freeform_tags  = var.assets.resident.freeform_tags
}

resource "oci_core_drg_attachment" "segment" {
  depends_on     = [
    oci_core_vcn.segment,
    oci_core_drg.segment
  ]
  count          = local.create_gateways.drg ? 1 : 0
  drg_id         = oci_core_drg.segment[0].id
  display_name   = "${var.network.display_name}_attachment"
  # Uncomment to define a static route table assignment, default is an auto-generated dynamic table
  # drg_route_table_id = oci_core_drg_route_table.segment_route.id

  network_details {
    id         = oci_core_vcn.segment.id
    type       = var.network.gateways.drg.type
    # Uncomment to define a transit route target, per default transits should be defined on the DRG itself
    # route_table_id = oci_core_route_table.route_table.id
  }
}

resource "oci_core_internet_gateway" "segment" {
  depends_on     = [oci_core_vcn.segment]
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  vcn_id         = oci_core_vcn.segment.id
  count          = local.create_gateways.internet ? 1 : 0
  display_name   = var.network.gateways.internet.name
  defined_tags   = var.assets.resident.defined_tags
  freeform_tags  = var.assets.resident.freeform_tags
}

resource "oci_core_nat_gateway" "segment" {
  depends_on     = [oci_core_vcn.segment]
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  vcn_id         = oci_core_vcn.segment.id
  count          = local.create_gateways.nat ? 1 : 0
  display_name   = var.network.gateways.nat.name
  block_traffic  = var.input.nat == "DISABLE" ? true : false
  defined_tags   = var.assets.resident.defined_tags
  freeform_tags  = var.assets.resident.freeform_tags
}

resource "oci_core_service_gateway" "segment" {
  depends_on     = [oci_core_vcn.segment]
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  vcn_id         = oci_core_vcn.segment.id
  count          = local.create_gateways.osn ? 1 : 0
  display_name   = var.network.gateways.osn.name
  defined_tags   = var.assets.resident.defined_tags
  freeform_tags  = var.assets.resident.freeform_tags
  services {
    #Required
    service_id = local.osn_ids[var.network.gateways.osn.services]
  }
}

resource "oci_core_route_table" "segment" {
  depends_on     = [
    oci_core_vcn.segment,
    oci_core_drg.segment,
    oci_core_drg_attachment.segment
  ]
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  for_each       = local.route_tables
  display_name   = each.value.display_name
  vcn_id         = oci_core_vcn.segment.id
  defined_tags   = var.assets.resident.defined_tags
  freeform_tags  = var.assets.resident.freeform_tags

  dynamic "route_rules" {
    for_each = [for rule in each.value.route_rules: {
    network_entity   = rule.network_entity
    destination      = rule.destination
    destination_type = rule.destination_type
    description      = rule.description
    }]
    content {
    network_entity_id = local.gateway_ids[route_rules.value.network_entity]
    destination       = route_rules.value.destination
    destination_type  = route_rules.value.destination_type
    description       = route_rules.value.description
    }
  }
}

resource "oci_core_subnet" "segment" {
  depends_on                 = [
    oci_core_default_security_list.default_security_list,
    oci_core_drg_attachment.segment,
    oci_core_internet_gateway.segment,
    oci_core_service_gateway.segment,
    oci_core_nat_gateway.segment
  ]
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  vcn_id         = oci_core_vcn.segment.id
  for_each       = var.network.subnets
  cidr_block     = each.value.cidr_block
  display_name   = each.value.display_name
  dns_label      = each.value.dns_label
  defined_tags   = var.assets.resident.defined_tags
  freeform_tags  = var.assets.resident.freeform_tags
  route_table_id = local.route_table_ids[each.value.route_table] 
  security_list_ids = ["${local.security_list_ids[each.value.security_list]}"]
}