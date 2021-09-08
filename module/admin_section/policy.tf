# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_identity_policy" "ocloud" {
  depends_on = [
    oci_identity_group.ocloud
  ]
  name           = var.policy.name
  description    = var.policy.description
  compartment_id = var.config.tenancy_ocid
  statements     = var.policy.statements
}
