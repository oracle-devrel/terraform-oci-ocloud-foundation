# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_vcn" "segment" {
  compartment_id = var.config.compartment_id
  display_name   = local.display_name
  dns_label      = local.dns_label
  cidr_block     = var.network.address_spaces.cidr_block
  is_ipv6enabled = false
  defined_tags   = null
  freeform_tags  = var.config.freeform_tags
}

resource "oci_core_network_security_group" "segment" {
  depends_on     = [ oci_core_vcn.segment ]
  compartment_id = var.config.compartment_id
  display_name   = "${local.display_name}_sec_grp"
  vcn_id         = oci_core_vcn.segment.id
  defined_tags   = null
  freeform_tags  = var.config.freeform_tags
}

## This Terraform configuration modifies the default security list for the VCN
resource "oci_core_default_security_list" "default_security_list" {
  manage_default_resource_id = oci_core_vcn.segment.default_security_list_id
  ingress_security_rules {
    protocol  = "1"
    stateless = false
    source    = var.network.address_spaces.cidr_block
    icmp_options {
      type = 3
      code = 4
    }
  }
  ingress_security_rules {
    protocol  = "1"
    stateless = false
    source    = var.network.address_spaces.anywhere
    icmp_options {
      type = 3
      code = null
    }
  }
}

resource "oci_core_internet_gateway" "segment" {
  compartment_id = var.config.compartment_id
  vcn_id         = oci_core_vcn.segment.id
  display_name   = "${local.display_name}_ig"
}

resource "oci_core_nat_gateway" "segment" {
  compartment_id = var.config.compartment_id
  display_name   = "${local.display_name}_ng"
  vcn_id         = oci_core_vcn.segment.id
  block_traffic  = var.network.block_nat_traffic
}

resource "oci_core_service_gateway" "segment" {
  compartment_id = var.config.compartment_id
  display_name   = "${local.display_name}_sg"
  vcn_id         = oci_core_vcn.segment.id
  services {
    service_id   = local.osn_cidrs[var.network.service_gateway_cidr]
  }
}

resource "oci_core_drg" "segment" {
  count          = var.network.create_drg == true ? 1 : 0
  compartment_id = var.config.compartment_id
  display_name   = "${local.display_name}_drg"
  defined_tags   = null
  freeform_tags  = var.config.freeform_tags
}

resource "oci_core_drg_attachment" "segment" {
  drg_id         = oci_core_drg.segment[0].id
  display_name   = "${local.display_name}_drg_attached"
  freeform_tags  = var.config.freeform_tags
  defined_tags   = null
  # Uncomment to define a static route table assignment, default is an auto-generated dynamic table
  # drg_route_table_id = oci_core_drg_route_table.segment_route.id

  network_details {
      id         = oci_core_vcn.segment.id
      type       = "VCN"
      # Uncomment to define a transit route target, per default transits should be defined on the DRG itself
      # route_table_id = oci_core_route_table.route_table.id
  }
}

resource "oci_core_route_table" "public" {
  compartment_id = var.config.compartment_id
  vcn_id         = oci_core_vcn.segment.id
  defined_tags   = null
  freeform_tags  = var.config.freeform_tags
  display_name   = "${local.display_name}_pub_rt"

  dynamic "route_rules" {
    for_each = [for rule in local.public_rule_set: {
      network_entity_id = rule.network_entity_id
      destination       = rule.destination
      destination_type  = rule.destination_type
      description       = rule.description
    }]
    content {
      network_entity_id = route_rules.value.network_entity_id
      destination       = route_rules.value.destination
      destination_type  = route_rules.value.destination_type
      description       = route_rules.value.description
    }
  }
}

resource "oci_core_route_table" "private" {
  compartment_id = var.config.compartment_id
  vcn_id         = oci_core_vcn.segment.id
  defined_tags   = null
  freeform_tags  = var.config.freeform_tags
  display_name   = "${local.display_name}_priv_rt"

  dynamic "route_rules" {
    for_each = [for rule in local.private_rule_set: {
      network_entity_id = rule.network_entity_id
      destination       = rule.destination
      destination_type  = rule.destination_type
      description       = rule.description
    }]
    content {
      network_entity_id = route_rules.value.network_entity_id
      destination       = route_rules.value.destination
      destination_type  = route_rules.value.destination_type
      description       = route_rules.value.description
    }
  }
}

resource "oci_core_route_table" "osn" {
  compartment_id = var.config.compartment_id
  #compartment_id = data.oci_identity_compartment.segment.id
  vcn_id         = oci_core_vcn.segment.id
  defined_tags   = null
  freeform_tags  = var.config.freeform_tags
  display_name   = "${local.display_name}_osn_rt"

  dynamic "route_rules" {
    for_each = [for rule in local.osn_rule_set: {
      network_entity_id = rule.network_entity_id
      destination       = rule.destination
      destination_type  = rule.destination_type
      description       = rule.description
    }]
    content {
      network_entity_id = route_rules.value.network_entity_id
      destination       = route_rules.value.destination
      destination_type  = route_rules.value.destination_type
      description       = route_rules.value.description
    }
  }
}

# Uncomment to define route tables manually, two tables will be auto-generated, one for DC interconnect (e.g. IPSec) and one for VCN
/*
resource "oci_core_route_table" "cpe" {
  compartment_id = var.config.compartment_id
  vcn_id         = oci_core_vcn.segment.id
  defined_tags   = null
  freeform_tags  = var.config.freeform_tags
  service_name   = "${local.display_name}_route_table"

  dynamic "route_rules" {
    for_each = [for rule in local.cpe_rule_set: {
      network_entity_id = rule.network_entity_id
      destination       = rule.destination
      destination_type  = rule.destination_type
      description       = rule.description
    }]
    content {
      network_entity_id = route_rules.value.network_entity_id
      destination       = route_rules.value.destination
      destination_type  = route_rules.value.destination_type
      description       = route_rules.value.description
    }
  }
}
*/