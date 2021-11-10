# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_compartment" "service" { id = var.config.service_id }

data "oci_identity_compartments" "section" {
  depends_on     = [ oci_identity_compartment.section ]
  compartment_id = var.compartment.parent != null ? var.compartment.parent : data.oci_identity_compartment.service.compartment_id
  name           = "${local.display_name}_compartment"
  state          = "ACTIVE"
}

data "oci_identity_policies" "section" {
  depends_on = [ oci_identity_policy.section ]
  compartment_id = var.compartment.parent != null ? var.compartment.parent : data.oci_identity_compartment.service.compartment_id
  state          = "ACTIVE"
}

locals {
  display_name = lower("${data.oci_identity_compartment.service.name}_${var.section_name}")
}

// --- wait state ---
resource "null_resource" "previous" {}

resource "time_sleep" "wait" {
  depends_on = [null_resource.previous]
  create_duration = "2m"
}

// --- required terraform provider --- 
terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
    }
  }
}