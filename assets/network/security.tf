# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

## Modify the default security list for the VCN
resource "oci_core_default_security_list" "default_security_list" {
  manage_default_resource_id = oci_core_vcn.segment.default_security_list_id
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    stateless        = false
    description      = "allow outgoing tcp traffic"
  }
  ingress_security_rules {
    protocol  = "1"
    stateless = false
    source    = var.config.network.gateways.drg.anywhere
    icmp_options {
      type = 3
      code = 4
    }
  }
  ingress_security_rules {
    protocol  = "1"
    stateless = false
    source    = var.config.network.cidr
    icmp_options {
      type = 3
      code = null
    }
  }
}

resource "oci_core_security_list" "segment" {
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  vcn_id         = oci_core_vcn.segment.id
  for_each       = {
    for profile in var.config.network.security_lists : profile.display_name => profile
    if  profile.stage <= var.config.service.stage
  }
  display_name   = each.value.display_name

  // allow all outbound traffic to other network segments
  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    stateless        = false
    description      = "allow outgoing tcp traffic"
  }
  // allow inbound icmp traffic
  ingress_security_rules {
    protocol    = 1
    source      = var.config.network.gateways.drg.anywhere
    stateless   = false
    description = "allow internal icmp traffic"
    icmp_options {
      type = 3
      code = 4
    }
  }
  ingress_security_rules {
    protocol  = "1"
    stateless = false
    source    = var.config.network.cidr
    icmp_options {
      type = 3
      code = null
    }
  }
  // allow defined inbound tcp traffic
  dynamic "ingress_security_rules" {
    for_each = [for application in each.value.ingress: {
      protocol    = application.protocol
      source      = application.source
      source_type = application.source_type
      stateless   = application.stateless
      description = application.description
      min_port    = application.min_port
      max_port    = application.max_port
    }]
    content {
      protocol    = ingress_security_rules.value.protocol
      source      = ingress_security_rules.value.source
      source_type = ingress_security_rules.value.source_type
      stateless   = ingress_security_rules.value.stateless
      description = ingress_security_rules.value.description
      tcp_options {
        min  = ingress_security_rules.value.min_port
        max  = ingress_security_rules.value.max_port
      }
    }
  }
}

## Create default security groups
resource "oci_core_network_security_group" "segment" {
  depends_on     = [oci_core_vcn.segment]
  compartment_id = data.oci_identity_compartments.network.compartments[0].id
  vcn_id         = oci_core_vcn.segment.id
  for_each       = var.config.network.security_groups
  display_name   = each.value.display_name
  defined_tags   = var.assets.resident.defined_tags
  freeform_tags  = var.assets.resident.freeform_tags
}