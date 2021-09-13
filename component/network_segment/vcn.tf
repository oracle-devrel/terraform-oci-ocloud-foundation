# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_vcn" "segment" {
  compartment_id = data.oci_identity_compartment.segment.id
  dns_label      = var.config.dns_label
  cidr_block     = var.vcn.address_spaces.cidr_block
  display_name   = "${var.config.display_name}_vcn"
}

resource "oci_core_network_security_group" "segment" {
  depends_on     = [oci_core_vcn.segment]
  compartment_id = data.oci_identity_compartment.segment.id
  vcn_id         = oci_core_vcn.segment.id
  defined_tags   = var.config.defined_tags
  freeform_tags  = var.config.freeform_tags
  display_name   = "${var.config.display_name}_security_group"
}

## This Terraform configuration modifies the default security list for the VCN
resource "oci_core_default_security_list" "default_security_list" {
  manage_default_resource_id = oci_core_vcn.segment.default_security_list_id
  ingress_security_rules {
    protocol  = "1"
    stateless = false
    source    = var.vcn.address_spaces.cidr_block
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