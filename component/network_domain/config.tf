# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
 
data "oci_core_services" "all_services" { } # Request a list of Oracle Service Network (osn) services

data "oci_identity_compartments" "domain" {
  compartment_id = var.config.service_id
  state          = "ACTIVE"
  filter {
    name   = "id"
    values = [ var.config.compartment_id ]
  } 
}

data "oci_core_vcn" "domain" {
    vcn_id = var.config.vcn_id
}

data "oci_core_subnets" "domain" {
  depends_on     = [ oci_core_subnet.domain ]
  compartment_id = var.config.compartment_id
  vcn_id         = var.config.vcn_id
  filter {
    name   = "service_name"
    values = [ local.display_name ]
  }
}

data "oci_bastion_bastions" "domain" {
  depends_on     = [ oci_bastion_bastion.domain ]
  compartment_id = var.config.compartment_id
  filter {
    name   = "name"
    values = [local.bastion_label]
  }
}

data "oci_core_security_lists" "domain" {
  depends_on     = [ oci_core_security_list.domain ]
  compartment_id = var.config.compartment_id
  filter {
    name   = "service_name"
    values = ["${local.display_name}_security_list"]
  }
}

locals {
  # naming conventions
  display_name  = "${lower("${split("_", data.oci_identity_compartments.domain.compartments[0].name)[0]}_${split("_", data.oci_identity_compartments.domain.compartments[0].name)[1]}_${var.subnet.domain}")}"
  dns_label     = "${format("%s%s%s", lower(substr(split("_", data.oci_identity_compartments.domain.compartments[0].name)[0], 0, 3)), lower(substr(split("_", data.oci_identity_compartments.domain.compartments[0].name)[1], 0, 5)), var.subnet.domain)}"
  bastion_label = "${format("%s%s%s", lower(substr(split("_", data.oci_identity_compartments.domain.compartments[0].name)[0], 0, 3)), lower(substr(split("_", data.oci_identity_compartments.domain.compartments[0].name)[1], 0, 5)), "bstn")}"
}

# Request a list of Oracle Service Network (osn) services
/*
data "oci_core_services" "all_services" { }
data "oci_core_services" "ocloud" { }

# Bastion config data sources
data "oci_bastion_bastions" "ocloud" {
  compartment_id          = var.bastion.compartment_id
  bastion_id              = oci_bastion_bastion.ocloud.id
  bastion_lifecycle_state = "ACTIVE"
  name                    = "bstn${local.service_name}"
}

data "oci_identity_availability_domain" "bastion_ad" {
  compartment_id = var.config.tenancy_id
  ad_number      = 1
}
*/

// Define the wait state for the data requests
## This resource will destroy (potentially immediately) after null_resource.next
resource "null_resource" "previous" {}

resource "time_sleep" "wait" {
  depends_on      = [null_resource.previous]
  create_duration = "2m"
}