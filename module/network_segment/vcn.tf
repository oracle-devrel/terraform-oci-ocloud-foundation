# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_vcn" "ocloud" {
  compartment_id = var.config.compartment_id
  dns_label      = var.config.dns_label
  cidr_block     = var.vcn.address_spaces.cidr_block
  display_name   = var.config.display_name
}

resource "oci_core_network_security_group" "ocloud" {
  compartment_id = var.config.compartment_id
  vcn_id         = oci_core_vcn.ocloud.id
  defined_tags   = var.config.defined_tags
  freeform_tags  = var.config.freeform_tags
  display_name   = "${var.config.display_name}_Security_Group"
}

resource "oci_core_internet_gateway" "ocloud" {
  compartment_id = var.config.compartment_id
  vcn_id         = oci_core_vcn.ocloud.id
  display_name   = "${var.config.display_name}_Internet_Gateway"
}

resource "oci_core_nat_gateway" "ocloud" {
    compartment_id = var.config.compartment_id
    display_name   = "${var.config.display_name}_NAT_Gateway"
    vcn_id         = oci_core_vcn.ocloud.id
    block_traffic  = var.vcn.block_nat_traffic
}

resource "oci_core_service_gateway" "ocloud" {
    compartment_id = var.config.compartment_id
    display_name   = "${var.config.display_name}_Service_Gateway"
    vcn_id         = oci_core_vcn.ocloud.id
    services {
      service_id   = local.osn_cidrs[var.vcn.service_gateway_cidr]
    }
}

resource "oci_core_route_table" "public" {
  compartment_id = var.config.compartment_id
  vcn_id         = oci_core_vcn.ocloud.id
  defined_tags   = var.config.defined_tags
  freeform_tags  = var.config.freeform_tags
  display_name   = "${var.config.display_name}_Public_Route_Table"

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
  vcn_id         = oci_core_vcn.ocloud.id
  defined_tags   = var.config.defined_tags
  freeform_tags  = var.config.freeform_tags
  display_name   = "${var.config.display_name}_Private_Route_Table"

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
  vcn_id         = oci_core_vcn.ocloud.id
  defined_tags   = var.config.defined_tags
  freeform_tags  = var.config.freeform_tags
  display_name   = "${var.config.display_name}_Oracle_Service_Route_Table"

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

## This Terraform configuration modifies the default security list for the VCN
resource "oci_core_default_security_list" "default_security_list" {
  manage_default_resource_id = oci_core_vcn.ocloud.default_security_list_id
  ingress_security_rules {
    protocol  = "1"
    stateless = false
    source    = oci_core_vcn.ocloud.cidr_block
    icmp_options {
      type = 3
      code = 4
    }
  }
  ingress_security_rules {
    protocol  = "1"
    stateless = false
    source    = var.vcn.address_spaces.anywhere
    icmp_options {
      type = 3
      code = null
    }
  }
}
