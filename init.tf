# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- service compartment --- //
resource "oci_identity_compartment" "init" {
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
resource "oci_identity_tag_namespace" "budget" {
    depends_on     = [ oci_identity_compartment.init ]
    compartment_id = var.tenancy_ocid
    description    = "cost tracking tags for service ${local.service_name}"
    name           = "${local.service_name}_budget_tags"
}

resource "oci_identity_tag_namespace" "operation" {
    depends_on     = [ oci_identity_compartment.init ]
    compartment_id = var.tenancy_ocid
    description    = "tags that help to automate service ${local.service_name}"
    name           = "${local.service_name}_operation_tags"
}

resource "oci_identity_tag_namespace" "governance" {
    depends_on     = [ oci_identity_compartment.init ]
    compartment_id = var.tenancy_ocid
    description    = "governance tags for service ${local.service_name}"
    name           = "${local.service_name}_governance_tags"
}

resource "oci_identity_tag" "created_by" {
    depends_on       = [ oci_identity_compartment.init ]
    tag_namespace_id = oci_identity_tag_namespace.budget.id
    description      = "${local.service_name} identity tag"
    name             = "created_by"
}

/*
resource "oci_identity_tag_default" "created_by" {
    compartment_id    = local.service_id
    tag_definition_id = oci_identity_tag.created_by.id
    value             = "${iam.principal.name}"
    is_required       = false
}
*/
resource "oci_identity_tag" "created_on" {
    depends_on       = [ oci_identity_compartment.init ]
    tag_namespace_id = oci_identity_tag_namespace.budget.id
    description      = "${local.service_name} identity tag"
    name             = "created_on"
}
/*
resource "oci_identity_tag_default" "created_on" {
    compartment_id    = local.service_id
    tag_definition_id = oci_identity_tag.created_on.id
    value             = "${oci.datetime}"
    is_required       = false
}
*/
// --- define default tags --- //

// --- enable notifications --- //
resource "oci_ons_notification_topic" "service" {
    depends_on     = [ oci_identity_compartment.init, oci_ons_notification_topic.service ]
    compartment_id = local.service_id
    name           = "${local.service_name}_notification"
    #defined_tags   = { "${oci_identity_tag_namespace.init.name}.${oci_identity_tag.init[0].name}" = "environment" }
    description    = "${local.service_name} notification topic"
    freeform_tags = { 
      "source" = var.code_source
    }
}

resource "oci_ons_subscription" "service" {
    depends_on     = [ oci_identity_compartment.init, oci_ons_notification_topic.service ]
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
    depends_on     = [ oci_identity_compartment.init, oci_ons_notification_topic.service ]
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
    depends_on     = [ oci_identity_compartment.init, oci_identity_tag.service ]
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

