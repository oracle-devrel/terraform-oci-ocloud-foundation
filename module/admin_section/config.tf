# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_core_services" "all_services" { }
data "oci_identity_compartments" "ocloud" {
  count          = var.compartment.create ? 0 : 1
  compartment_id = var.compartment.parent

  filter {
    name   = "name"
    values = [var.compartment.name]
  }
}