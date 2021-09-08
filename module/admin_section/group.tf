# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_identity_group" "ocloud" {
  depends_on = [
    oci_identity_compartment.ocloud
  ]
  name           = var.group.name
  description    = var.group.description
  compartment_id = var.config.tenancy_ocid
  defined_tags   = var.config.defined_tags
  freeform_tags  = var.config.freeform_tags
}
