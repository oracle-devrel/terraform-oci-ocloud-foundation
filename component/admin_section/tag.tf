# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_identity_tag_namespace" "section" {
    compartment_id = var.config.tenancy_id
    description    = "identity namespace defined with framework ${var.config.source}"
    name           = "${var.config.display_name}_identity_namespace"
}

resource "oci_identity_tag" "section" {
    description      = "identity tag defined with framework ${var.config.source}"
    name             = "${var.config.display_name}_identity_tag"
    tag_namespace_id = oci_identity_tag_namespace.section.id
}