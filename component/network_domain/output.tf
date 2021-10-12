# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// Subnets
data "oci_core_subnets" "domain" {
  depends_on     = [time_sleep.wait]
  compartment_id = var.config.compartment_id
  vcn_id         = var.config.vcn_id
  filter {
    name   = "service_name"
    values = [ local.display_name ]
  }
}

output "subnet" {
  description = "Subnet"
  value       = length(data.oci_core_subnets.domain.subnets) > 0 ? data.oci_core_subnets.domain.subnets[0] : null
}

// Security Lists
data "oci_core_security_lists" "domain" {
  depends_on     = [time_sleep.wait]
  compartment_id = var.config.compartment_id
  filter {
    name   = "service_name"
    values = ["${local.display_name}_security_list"]
  }
}

output "seclist" {
  description = "Security List"
  value       = length(data.oci_core_security_lists.domain.security_lists) > 0 ? data.oci_core_security_lists.domain.security_lists[0] : null
}

// Bastion Service
data "oci_bastion_bastions" "domain" {
  depends_on     = [time_sleep.wait]
  compartment_id = var.config.compartment_id
  filter {
    name   = "name"
    values = [local.bastion_label]
  }
}

output "bastion" {
  description = "Bastion Service"
  value       = length(data.oci_bastion_bastions.domain.bastions) > 0 ? data.oci_bastion_bastions.domain.bastions[0] : null
}

// Define the wait state for the data requests
## This resource will destroy (potentially immediately) after null_resource.next
resource "null_resource" "previous" {}

resource "time_sleep" "wait" {
  depends_on      = [null_resource.previous]
  create_duration = "2m"
}