# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- service compartment --- //
resource "oci_identity_compartment" "resident" {
    compartment_id = var.input.parent_id
    name           = var.resident.name
    description    = "compartment that encapsulates all resources for a service"
    enable_delete  = var.input.enable_delete
    freeform_tags  = local.freeform_tags
}

resource "oci_identity_compartment" "domains" {
    depends_on     = [ oci_identity_compartment.resident ]
    compartment_id = oci_identity_compartment.resident.id
    for_each       = {
        for compartment, stage in var.resident.compartments : compartment => stage
        if stage <= var.resident.stage
    }
    name           = each.key
    description    = "${each.key} management domain for ${var.resident.name}"
    enable_delete  = var.input.enable_delete 
    defined_tags   = local.defined_tags
    freeform_tags  = local.freeform_tags
}
// --- service compartment --- //

// --- define tags --- //
resource "oci_identity_tag_namespace" "resident" {
    depends_on     = [ oci_identity_compartment.resident ]
    compartment_id = oci_identity_compartment.resident.id
    freeform_tags  = local.freeform_tags
    for_each = {
        for namespace, stage in var.resident.tag_namespaces : namespace => stage
        if stage <= var.resident.stage
    }
    name        = each.key
    description = "${each.key} tag collection for service ${var.resident.name}"
}

resource "oci_identity_tag" "resident" {
    depends_on       = [ oci_identity_tag_namespace.resident ]
    for_each         = {
        for tag in var.resident.tags : tag.name => tag
        if tag.stage <= var.resident.stage
    }
    name             = each.key
    tag_namespace_id = oci_identity_tag_namespace.resident[each.value.namespace].id
    is_cost_tracking = each.value.cost_tracking
    description      = "defined tag for ${var.resident.name}"
    is_retired       = false
    freeform_tags  = local.freeform_tags
}


resource "oci_identity_tag_default" "resident" {
    depends_on        = [ oci_identity_tag.resident ]
    compartment_id    = oci_identity_compartment.resident.id
    for_each         = {
        for tag in var.resident.tags : tag.name => tag
        if tag.stage <= var.resident.stage
    }
    tag_definition_id = oci_identity_tag.resident[each.key].id
    value             = each.value.default
}
// --- define tags --- //

// --- notification service --- //
resource "oci_ons_notification_topic" "resident" {
    depends_on     = [
        oci_identity_compartment.resident,
        oci_identity_tag_namespace.resident,
        oci_identity_tag.resident,
        oci_identity_tag_default.resident
    ]
    compartment_id = oci_identity_compartment.resident.id
    for_each       = var.resident.notifications
    name           = each.value.topic
    description    = "informs the admin about the deployment of ${var.resident.name}"
    defined_tags   = local.defined_tags
    freeform_tags  = local.freeform_tags
}

resource "oci_ons_subscription" "resident" {
    depends_on     = [
        oci_identity_compartment.resident, 
        oci_ons_notification_topic.resident, 
        oci_identity_tag_namespace.resident, 
        oci_identity_tag.resident, 
        oci_identity_tag_default.resident
    ]
    compartment_id = oci_identity_compartment.resident.id
    defined_tags   = local.defined_tags
    freeform_tags  = local.freeform_tags
    for_each       = oci_ons_notification_topic.resident
    topic_id       = each.value.id
    endpoint       = var.resident.notifications[each.value.name].endpoint
    protocol       = var.resident.notifications[each.value.name].protocol
}
// --- notification service --- //

// --- group definitions --- //
resource "oci_identity_group" "resident" {
    depends_on     = [
        oci_identity_compartment.resident, 
        oci_identity_tag.resident, 
        oci_identity_tag_namespace.resident, 
        oci_identity_tag.resident, 
        oci_identity_tag_default.resident,
        oci_ons_notification_topic.resident,
        oci_ons_subscription.resident
    ]
    compartment_id = var.tenancy.id
    for_each       = var.resident.groups
    name           = each.value
    description    = "group for the ${each.key} role"
    defined_tags   = local.defined_tags
    freeform_tags  = local.freeform_tags
}
// --- group definitions --- //

resource "oci_identity_policy" "domains" {
    depends_on     = [ oci_identity_compartment.domains ]
    compartment_id = oci_identity_compartment.resident.id
    for_each       = var.resident.policies
    name           = each.value.name
    description    = "policies for the ${each.key} role"
    statements     = each.value.rules
    defined_tags   = local.defined_tags
    freeform_tags  = local.freeform_tags
}