# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- compartment ---
output "compartment" {
  description = "compartment details"
  // This allows the compartment details to be retrieved from the resource.
  value       = length(data.oci_identity_compartments.section.compartments) > 0 ? data.oci_identity_compartments.section.compartments[0] : null
}

data "oci_identity_compartments" "section" {
  depends_on     = [time_sleep.wait]
  compartment_id = var.compartment.parent
  filter {
    name   = "name"
    values = [ "${var.config.display_name}_compartment" ]
  }
}

// --- roles ---
output "roles" {
  description = "administrator roles"
  // This allows the policy details to be retrieved from the resource
  value       = length(data.oci_identity_policies.section.policies) > 0 ? data.oci_identity_policies.section.policies[0] : null
}

data "oci_identity_policies" "section" {
  depends_on     = [time_sleep.wait]
  compartment_id = var.config.tenancy_id
  filter {
    name   = "name"
    values = keys(var.roles)
  }
}

// --- tags ---
output "namespaces" {
  description = "tag namespaces"
  // This allows the policy details to be retrieved from the resource
  value       = length(data.oci_identity_tag_namespaces.section.tag_namespaces) > 0 ? data.oci_identity_tag_namespaces.section.tag_namespaces[0] : null
}

data "oci_identity_tag_namespaces" "section" {
  depends_on     = [time_sleep.wait]
  compartment_id = var.config.tenancy_id
  state          = "ACTIVE"
}

output "tags" {
  description = "tags"
  // This allows the policy details to be retrieved from the resource
  value       = length(data.oci_identity_tags.section.tags) > 0 ? data.oci_identity_tags.section.tags[0] : null
}

data "oci_identity_tags" "section" {
  depends_on       = [time_sleep.wait]
  tag_namespace_id = oci_identity_tag_namespace.section.id
  state    = "ACTIVE"
}

// --- notification service ---
output "notifications" {
  description = "notification topics"
  // This allows the policy details to be retrieved from the resource
  value       = length(data.oci_ons_notification_topics.section.notification_topics) > 0 ? data.oci_ons_notification_topics.section.notification_topics[0] : null
}

data "oci_ons_notification_topics" "section" {
    compartment_id = oci_identity_compartment.section.id
    id             = oci_ons_notification_topic.section.id
    name           = oci_ons_notification_topic.section.name
    state          = "ACTIVE"
}

output "subscriptions" {
  description = "notification endpoints"
  // This allows the policy details to be retrieved from the resource
  value       = length(data.oci_ons_subscriptions.section.subscriptions) > 0 ? data.oci_ons_subscriptions.section.subscriptions[0] : null
}

data "oci_ons_subscriptions" "section" {
  compartment_id = oci_identity_compartment.section.id
  topic_id       = oci_ons_subscription.email.topic_id
}

// --- This resource will destroy (potentially immediately) after deployment ---
resource "null_resource" "previous" {}

resource "time_sleep" "wait" {
  depends_on = [null_resource.previous]
  create_duration = "2m"
}