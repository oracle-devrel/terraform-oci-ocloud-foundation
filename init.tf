# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- service compartment --- //
resource "oci_identity_compartment" "init" {
    compartment_id = var.tenancy_ocid
    name           = local.service_name
    description    = "compartment defined with ocloud framework ${var.code_source}"
    # Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed; If false, compartment will not be deleted on `terraform destroy` execution
    enable_delete  = true 
    defined_tags   = null
    freeform_tags = {
        "framework" = "ocloud"
    }
}
// --- service compartment --- //

// --- enable tagging --- //
resource "oci_identity_tag_namespace" "init" {
    depends_on     = [ oci_identity_compartment.init ]
    compartment_id = var.tenancy_ocid
    description    = "identity namespace defined for ${local.service_name}"
    name           = "${local.service_name}_tag_namespace"
}

resource "oci_identity_tag" "environment" {
    depends_on       = [ oci_identity_compartment.init ]
    tag_namespace_id = oci_identity_tag_namespace.init.id
    description      = "identity tag defined with framework ${var.code_source}"
    name             = "environment"
}

resource "oci_identity_tag_default" "environment" {
    compartment_id    = local.service_id
    tag_definition_id = oci_identity_tag.environment.id
    value             = var.environment
    is_required       = false
}
// --- enable tagging --- //

// --- enable notifications --- //
resource "oci_ons_notification_topic" "init" {
    depends_on     = [ oci_identity_compartment.init, oci_identity_tag.environment ]
    compartment_id = local.service_id
    name           = "${local.service_name}_notification"
    #defined_tags   = { "${oci_identity_tag_namespace.init.name}.${oci_identity_tag.init[0].name}" = "environment" }
    description    = "notification topic defined with framework ${var.code_source}"
    freeform_tags = {
        "framework" = "ocloud"
    }
}

resource "oci_ons_subscription" "email" {
    depends_on     = [ oci_identity_compartment.init, oci_identity_tag.environment ]
    compartment_id = local.service_id
    protocol       = "EMAIL"
    endpoint       = var.admin_mail
    topic_id       = oci_ons_notification_topic.init.id
    #defined_tags   = { "${oci_identity_tag_namespace.section.name}.${oci_identity_tag.section.name}" = "value" }
    freeform_tags = {
        "framework" = "ocloud"
    }
}

/*
resource "oci_ons_subscription" "slack" {
    depends_on     = [ oci_identity_compartment.init, oci_identity_tag.environment ]
    compartment_id = local.service_id
    protocol       = "SLACK"
    endpoint       = var.slack_channel
    topic_id       = oci_ons_notification_topic.init.id
    #defined_tags   = { "${oci_identity_tag_namespace.section.name}.${oci_identity_tag.section.name}" = "value" }
    freeform_tags = {
        "framework" = "ocloud"
    }
}
*/

// --- enable notifications --- //