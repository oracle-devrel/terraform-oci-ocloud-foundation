# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_ons_notification_topic" "section" {
    depends_on     = [ oci_identity_tag_namespace.section, oci_identity_tag.section ]
    compartment_id = oci_identity_compartment.section.id
    name           = "${var.config.display_name}_compartment"
    defined_tags   = { "${oci_identity_tag_namespace.section.name}.${oci_identity_tag.section.name}" = "value" }
    description    = "notification topic defined with framework ${var.config.source}"
    freeform_tags  = var.config.freeform_tags
}

resource "oci_ons_subscription" "email" {
    compartment_id = oci_identity_compartment.section.id
    endpoint       = var.config.mail
    protocol       = "EMAIL"
    topic_id       = oci_ons_notification_topic.section.id
    defined_tags   = { "${oci_identity_tag_namespace.section.name}.${oci_identity_tag.section.name}" = "value" }
    freeform_tags  = var.config.freeform_tags
}

resource "oci_ons_subscription" "slack" {
    compartment_id = oci_identity_compartment.section.id
    endpoint       = var.config.slack
    protocol       = "SLACK"
    topic_id       = oci_ons_notification_topic.section.id
    defined_tags   = { "${oci_identity_tag_namespace.section.name}.${oci_identity_tag.section.name}" = "value" }
    freeform_tags  = var.config.freeform_tags
}
