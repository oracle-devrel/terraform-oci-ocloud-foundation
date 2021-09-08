# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_identity_compartment" "ocloud" {
  count          = var.compartment.create ? 1 : 0
  compartment_id = var.compartment.parent != null ? var.compartment.parent : var.config.tenancy_ocid
  name           = var.compartment.name
  description    = var.compartment.description
  enable_delete  = false #Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed; If false, compartment will not be deleted on `terraform destroy` execution
  defined_tags   = var.config.defined_tags
  freeform_tags  = var.config.freeform_tags
}

/*
resource "oci_identity_tag_namespace" "ocloud" {
  #Required
  compartment_id = var.tenancy_ocid
  description    = var.tag_namespace_description
  name           = var.tag_namespace_name
}
*/
