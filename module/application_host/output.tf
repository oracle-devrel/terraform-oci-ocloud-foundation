# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

output "instances_summary" {
  description = "Private and Public IPs for each instance."
  value       = local.instances_details
}

output "instance_id" {
  description = "ocid of created instances. "
  value       = oci_core_instance.ocloud.*.id
}

output "private_ip" {
  description = "Private IPs of created instances. "
  value       = oci_core_instance.ocloud.*.private_ip
}

output "public_ip" {
  description = "Public IPs of created instances. "
  value       = oci_core_instance.ocloud.*.public_ip
}

output "instance_username" {
  description = "Usernames to login to Windows instance. "
  value       = data.oci_core_instance_credentials.ocloud.*.username
}

output "instance_password" {
  description = "Passwords to login to Windows instance. "
  sensitive   = true
  value       = data.oci_core_instance_credentials.ocloud.*.password
}

output "oracle-linux-8-latest-name" {
  value = data.oci_core_images.oraclelinux-8.images.0.display_name
}

output "oracle-linux-8-latest-id" {
  value = data.oci_core_images.oraclelinux-8.images.0.id
}
