# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_identity_compartment" "section" {
  compartment_id = var.compartment.parent != null ? var.compartment.parent : var.config.tenancy_id
  name           = "${local.display_name}_compartment"
  description    = "compartment defined with ocloud framework ${var.config.source}"
  enable_delete  = var.compartment.enable_delete #Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed; If false, compartment will not be deleted on `terraform destroy` execution
  defined_tags   = null
  freeform_tags  = var.config.freeform_tags
}

resource "oci_identity_group" "section" {
  depends_on = [ oci_identity_compartment.section ]
  compartment_id = var.config.tenancy_id
  defined_tags   = null
  freeform_tags  = var.config.freeform_tags
  for_each       = var.roles
  name           = each.key
  description    = "group for the ${each.key} role ${var.config.source}"
}

resource "oci_identity_policy" "section" {
  depends_on     = [ oci_identity_group.section, oci_identity_compartment.section ]
  compartment_id = var.compartment.parent != null ? var.compartment.parent : var.config.tenancy_id
  for_each       = var.roles
  name           = each.key
  description    = "policies for the ${each.key} role ${var.config.source}"
  statements     = each.value
}
