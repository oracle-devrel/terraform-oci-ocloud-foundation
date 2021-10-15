# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_compartments" "section" {
  depends_on = [ oci_identity_compartment.section ]
  compartment_id = var.compartment.parent != null ? var.compartment.parent : var.config.tenancy_id
  state = "ACTIVE"
  filter {
    name   =  "name"
    values = [ "${var.config.display_name}_compartment" ]
  }
}

data "oci_identity_policies" "section" {
  depends_on = [ oci_identity_policy.section ]
  compartment_id = var.compartment.parent != null ? var.compartment.parent : var.config.tenancy_id
  state          = "ACTIVE"
}

// --- wait state ---
resource "null_resource" "previous" {}

resource "time_sleep" "wait" {
  depends_on = [null_resource.previous]
  create_duration = "2m"
}
