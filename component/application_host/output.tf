# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

// --- meta data ---
output "details" {
  description = "ocid of created instances"
  value       = oci_core_instance.host.*
}

output "summary" {
  description = "Private and Public IPs for each instance."
  value       = local.instances_details
}

output "oracle-linux-8-latest-version" { value = data.oci_core_images.oraclelinux-8.images.0.display_name }
output "oracle-linux-8-latest-id"      { value = data.oci_core_images.oraclelinux-8.images.0.id }

// --- user details ---
output "username" {
  description = "Usernames to login to Windows instance"
  value       = data.oci_core_instance_credentials.host.*.username
}

output "password" {
  description = "Passwords to login to Windows instance"
  sensitive   = true
  value       = data.oci_core_instance_credentials.host.*.password
}

// --- admin access ---
output "ssh"                           { value = length(data.oci_bastion_sessions.ssh.sessions) > 0 ? data.oci_bastion_sessions.ssh.sessions[0].id : null }
#output "ssh_command"                   { value = "ssh -i  -o ProxyCommand="ssh -i  -W %h:%p -p 22 "${data.oci_bastion_bastion.host.bastion_id}@host.bastion.us-ashburn-1.oci.oraclecloud.com" -p 22 "opc@10.0.0.119"}