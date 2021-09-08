# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_drg" "ocloud" {
  depends_on = [
    oci_core_vcn.ocloud
  ]
  count          = var.drg.create_drg == true ? 1 : 0
  compartment_id = var.config.compartment_id
  display_name   = var.config.display_name
  defined_tags   = var.config.defined_tags
  freeform_tags  = var.config.freeform_tags
}
 
resource "oci_core_drg_attachment" "ocloud" {
  drg_id         = oci_core_drg.ocloud[0].id
  display_name   = "${var.config.display_name}_Attachment"
  freeform_tags  = var.config.freeform_tags
  defined_tags   = var.config.defined_tags
  # Uncomment to define a static route table assignment, default is an auto-generated dynamic table
  # drg_route_table_id = oci_core_drg_route_table.test_drg_route_table.id

  network_details {
      id              = oci_core_vcn.ocloud.id
      type            = "VCN"
      # Uncomment to define a transit route target, per default transits should be defined on the DRG itself
      # route_table_id = oci_core_route_table.test_route_table.id
  }
}

# Uncomment to define route tables manually, two tables will be auto-generated, one for DC interconnect (e.g. IPSec) and one for VCN
/*
resource "oci_core_route_table" "cpe" {
  compartment_id = var.config.compartment_id
  vcn_id         = oci_core_vcn.ocloud.id
  defined_tags   = var.config.defined_tags
  freeform_tags  = var.config.freeform_tags
  display_name   = "RT_${var.drg.display_name}_CPE"

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
