# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "subnet" {
  description = "The managed subnets, indexed by display_name"
  value       = oci_core_subnet.ocloud
}

output "bastion" {
  description = "the bastion service for a subnet"
  value       = oci_bastion_bastion.ocloud
}
