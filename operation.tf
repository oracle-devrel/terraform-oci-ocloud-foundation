# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "cloudops_section" {
  source         = "./module/admin_section/"
  providers      = { oci = oci.home }
  config ={
    tenancy_ocid   = var.tenancy_ocid
    defined_tags   = null
    freeform_tags  = {"framework"= "ocloud"}
  }
  compartment  = {
    create        = true
    parent        = var.tenancy_ocid
    name          = "${local.service_label}_operation_cmp"
    description   = "Operation compartment created by terraform"
  }
  group = {
    name          = "cloudops"
    description   = "Group responsible for managing all cloud resources"
  }
  policy = {
    name           = "cloudops"
    description    = "Policy allowing netops group to manage network resources"
    statements     = [
        "ALLOW GROUP cloudops to manage all-resources IN TENANCY"
    ]
  }
}
