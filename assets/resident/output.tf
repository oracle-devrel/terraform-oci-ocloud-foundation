# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.


output "id" {
  description = "The Oracle Cloud Identifier (OCID) for the service compartment. It allows to retrieve the compartment details using data blocks."
  value       = oci_identity_compartment.resident.id
}

output "parent_id" {
  description = "The OCID of the parent compartment for the service."
  value       = oci_identity_compartment.resident.compartment_id
}

output "compartment_ids" {
  description = "A list of OCID for the child compartments, representing the different administration domain."
  value       = { for compartment in oci_identity_compartment.domains : compartment.name => compartment.id }
}

output "namespace_ids" {
  description = "A list of tag_namespaces created for the service compartment in the tenancy. This allows to define separate tags for every service. Namespace names have to be unique."
  value       = { for namespace in oci_identity_tag_namespace.resident : namespace.name => namespace.id }
}

output "tag_ids" {
  description = "A list of tags, created in the tag namespaces."
  value       = { for tag in oci_identity_tag.resident : tag.name => tag.id }
}

output "group_ids" {
  description = "A list of groups, created for the service in the tenancy or root compartment. This allows to define separate policies for every service. Group names have to be unique."
  value       = { for group in oci_identity_group.resident : group.name => group.id }
}

output "notifications" {
  description = "A list of notifcation topics, defined for a resident."
  value       = { for topic in oci_ons_notification_topic.resident : topic.name => topic.id }
}

output "policy_ids" {
  description = "A list of policy controls, defined for the different admistrator roles. Policy names correspond with the groups defined on tenancy level."
  value       = { for policy in oci_identity_policy.domains : policy.name => policy.id }
}

output "freeform_tags" {
  description = "A list of predefined freeform tags, referenced in the provisioning process."
  value = local.freeform_tags
}

output "defined_tags" {
  description = "A list of actionable tags, utilized for operation, budget- and compliance control."
  value = local.defined_tags
}