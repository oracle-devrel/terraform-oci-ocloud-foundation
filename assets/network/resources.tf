# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


resource "oci_core_vcn" "segment" {
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  display_name   = var.config.network.display_name
  dns_label      = var.config.network.dns_label
  cidr_block     = var.config.network.cidr
  is_ipv6enabled = var.schema.ipv6
  defined_tags   = var.assets.resident.defined_tags
  freeform_tags  = var.assets.resident.freeform_tags
}

resource "oci_core_drg" "segment" {
  depends_on     = [oci_core_vcn.segment]
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  count          = local.create_gateways.drg ? 1 : 0
  display_name   = var.config.network.gateways.drg.name
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
  display_name   = "${var.config.network.display_name}_attachment"
  # Uncomment to define a static route table assignment, default is an auto-generated dynamic table
  # drg_route_table_id = oci_core_drg_route_table.segment_route.id

  network_details {
    id         = oci_core_vcn.segment.id
    type       = var.config.network.gateways.drg.type
    # Uncomment to define a transit route target, per default transits should be defined on the DRG itself
    # route_table_id = oci_core_route_table.route_table.id
  }
}

resource "oci_core_internet_gateway" "segment" {
  depends_on     = [oci_core_vcn.segment]
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  vcn_id         = oci_core_vcn.segment.id
  count          = local.create_gateways.internet ? 1 : 0
  display_name   = var.config.network.gateways.internet.name
  defined_tags   = var.assets.resident.defined_tags
  freeform_tags  = var.assets.resident.freeform_tags
}

resource "oci_core_nat_gateway" "segment" {
  depends_on     = [oci_core_vcn.segment]
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  vcn_id         = oci_core_vcn.segment.id
  count          = local.create_gateways.nat ? 1 : 0
  display_name   = var.config.network.gateways.nat.name
  block_traffic  = var.schema.nat == "DISABLE" ? true : false
  defined_tags   = var.assets.resident.defined_tags
  freeform_tags  = var.assets.resident.freeform_tags
}

resource "oci_core_service_gateway" "segment" {
  depends_on     = [oci_core_vcn.segment]
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  vcn_id         = oci_core_vcn.segment.id
  count          = local.create_gateways.service ? 1 : 0
  display_name   = var.config.network.gateways.service.name
  defined_tags   = var.assets.resident.defined_tags
  freeform_tags  = var.assets.resident.freeform_tags
  services {
    #Required
    service_id = local.osn_ids[var.config.network.gateways.service.scope]
  }
}

resource "oci_core_route_table" "segment" {
  depends_on     = [
    oci_core_vcn.segment,
    oci_core_drg.segment,
    oci_core_drg_attachment.segment
  ]
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  for_each       = {
    for table in var.config.network.route_tables : table.display_name => table
    if  table.stage <= var.config.service.stage
  }
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

resource "oci_core_default_route_table" "segment" {
  depends_on     = [
    oci_core_vcn.segment,
    oci_core_drg.segment,
    oci_core_drg_attachment.segment
  ]
  manage_default_resource_id = oci_core_vcn.segment.default_route_table_id
  route_rules {
    network_entity_id = local.create_gateways.internet ? oci_core_internet_gateway.segment[0].id : oci_core_drg.segment[0].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    description       = "Routes all traffic to the internet."
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
  for_each       = {
    for subnet in var.config.network.subnets : subnet.display_name => subnet
    if  subnet.stage <= var.config.service.stage
  }
  cidr_block     = each.value.cidr_block
  display_name   = each.value.display_name
  defined_tags   = var.assets.resident.defined_tags
  dns_label      = each.value.dns_label
  freeform_tags  = var.assets.resident.freeform_tags
  prohibit_internet_ingress = each.value.prohibit_internet_ingress
  route_table_id = local.route_table_ids[each.value.route_table] 
  security_list_ids = ["${local.security_list_ids[each.value.security_list]}"]
  vcn_id         = oci_core_vcn.segment.id
}