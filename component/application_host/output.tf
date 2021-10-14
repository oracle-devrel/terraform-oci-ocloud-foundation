# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

// --- meta data ---
output "details" {
  description = "ocid of created instances"
  value       = oci_core_instance.instance.*
}

data "oci_core_instances" "host" {
  depends_on = [time_sleep.wait]
  compartment_id = var.config.compartment_id
  filter {
    name   = "service_name"
    values = ["${local.service_name}_operator_host"]
  }
}

output "summary" {
  description = "Private and Public IPs for each instance."
  value       = local.instances_details
}

output "oracle-linux-8-latest-version" { value = data.oci_core_images.oraclelinux-8.images.0.service_name }
output "oracle-linux-8-latest-id"      { value = data.oci_core_images.oraclelinux-8.images.0.id }

// --- user details ---
output "username" {
  description = "Usernames to login to Windows instance"
  value       = data.oci_core_instance_credentials.instance.*.username
}

output "password" {
  description = "Passwords to login to Windows instance"
  sensitive   = true
  value       = data.oci_core_instance_credentials.instance.*.password
}

// --- admin access ---
output "ssh"                           { value = length(data.oci_bastion_sessions.ssh.sessions) > 0 ? data.oci_bastion_sessions.ssh.sessions[0].id : null }
#output "ssh_command"                   { value = "ssh -i  -o ProxyCommand="ssh -i  -W %h:%p -p 22 "${data.oci_bastion_bastion.host.bastion_id}@host.bastion.us-ashburn-1.oci.oraclecloud.com" -p 22 "opc@10.0.0.119"}

data "oci_bastion_sessions" "ssh" {
  depends_on              = [time_sleep.wait]
  bastion_id              = data.oci_bastion_bastions.host.bastions[0].id
  session_lifecycle_state = "ACTIVE"
  filter {
    name    = "service_name"
    values  = ["${local.service_name}_ssh"]
  }
}

// Define the wait state for the data requests. This resource will destroy (potentially immediately) after null_resource.next
resource "null_resource" "previous" {}

resource "time_sleep" "wait" {
  depends_on      = [null_resource.previous]
  create_duration = "6m"
}