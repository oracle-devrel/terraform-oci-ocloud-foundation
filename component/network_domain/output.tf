# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "subnet" {
  description = "Subnet"
  value       = length(data.oci_core_subnets.domain.subnets) > 0 ? data.oci_core_subnets.domain.subnets[0] : null
}

output "seclist" {
  description = "Security List"
  value       = length(data.oci_core_security_lists.domain.security_lists) > 0 ? data.oci_core_security_lists.domain.security_lists[0] : null
}

output "bastion" {
  description = "Bastion Service"
  value       = length(data.oci_bastion_bastions.domain.bastions) > 0 ? data.oci_bastion_bastions.domain.bastions[0] : null
}