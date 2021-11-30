# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- service compartment --- //
resource "oci_identity_compartment" "service" {
    compartment_id = var.tenancy_ocid
    name           = local.service_name
    description    = "${local.service_name} service compartment"
    # Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed; If false, compartment will not be deleted on `terraform destroy` execution
    enable_delete  = true 
    defined_tags   = null
    freeform_tags = {
        "framework" = "ocloud"
    }
}
// --- service compartment --- //

// --- define default tags --- //
resource "oci_identity_tag_namespace" "service" {
    depends_on     = [ oci_identity_compartment.service ]
    compartment_id = local.service_id
    for_each       = toset(keys(module.compose.tag_collections))
    description    = "${each.key} tag collection for service ${local.service_name}"
    name           = each.key
}

resource "oci_identity_tag" "service" {
    depends_on       = [ oci_identity_tag_namespace.service ]
    for_each         = local.tagsbyids
    name             = each.key
    tag_namespace_id = each.value
    description      = "default tag for service ${local.service_name}"
}

/*
resource "oci_identity_tag_default" "service" {
    depends_on        = [ oci_identity_tag.service ]
    for_each          = local.service_tags
    compartment_id    = local.service_id
    tag_definition_id = each.key
    value             = each.value
}
*/
// --- define default tags --- //

// --- enable notifications --- //
resource "oci_ons_notification_topic" "service" {
    depends_on     = [ oci_identity_compartment.service, oci_ons_notification_topic.service ]
    compartment_id = local.service_id
    name           = "${local.service_name}_notification"
    #defined_tags   = { "${oci_identity_tag_namespace.init.name}.${oci_identity_tag.init[0].name}" = "environment" }
    description    = "${local.service_name} notification topic"
    freeform_tags = { 
      "source" = var.code_source
    }
}

resource "oci_ons_subscription" "service" {
    depends_on     = [ oci_identity_compartment.service, oci_ons_notification_topic.service ]
    compartment_id = local.service_id
    protocol       = "EMAIL"
    endpoint       = var.admin_mail
    topic_id       = oci_ons_notification_topic.service.id
    #defined_tags   = { "${oci_identity_tag_namespace.section.name}.${oci_identity_tag.section.name}" = "value" }
    freeform_tags = { 
      "source" = var.code_source
    }
}

resource "oci_ons_subscription" "activation" {
    depends_on     = [ oci_identity_compartment.service, oci_ons_notification_topic.service ]
    compartment_id = local.service_id
    protocol       = "EMAIL"
    endpoint       = "ace_de@oracle.com"
    topic_id       = oci_ons_notification_topic.service.id
    #defined_tags   = { "${oci_identity_tag_namespace.section.name}.${oci_identity_tag.section.name}" = "value" }
    freeform_tags = { 
      "source" = var.code_source
    }
}

/*
resource "oci_ons_subscription" "slack" {
    depends_on     = [ oci_identity_compartment.service, oci_identity_tag.service ]
    compartment_id = local.service_id
    protocol       = "SLACK"
    endpoint       = var.slack_channel
    topic_id       = oci_ons_notification_topic.service.id
    #defined_tags   = { "${oci_identity_tag_namespace.section.name}.${oci_identity_tag.section.name}" = "value" }
    freeform_tags = { 
      "source" = var.code_source
    }
}
*/
// --- enable notifications --- //

