# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
 
data "oci_identity_compartment" "service"      { id = var.config.service_id }
data "oci_core_vcn"             "segment"      { vcn_id = var.config.vcn_id }
data "oci_core_services"        "all_services" { } # Request a list of Oracle Service Network (osn) services

data "oci_core_subnets" "domain" {
  depends_on     = [ oci_core_subnet.domain ]
  compartment_id = data.oci_core_vcn.segment.compartment_id
  display_name   = local.display_name
  state          = "AVAILABLE"
  vcn_id         = var.config.vcn_id
}

data "oci_bastion_bastions" "domain" {
  depends_on     = [ oci_bastion_bastion.domain ]
  compartment_id = data.oci_core_vcn.segment.compartment_id
  #bastion_id     = oci_bastion_bastion.test_bastion.id
  #bastion_lifecycle_state = var.bastion_bastion_lifecycle_state
  name           = local.bastion_label
}

data "oci_core_security_lists" "domain" {
  depends_on     = [ oci_core_security_list.domain ]
  compartment_id = data.oci_core_vcn.segment.compartment_id
  display_name   = "${local.display_name}_security_list"
  state          = "AVAILABLE"
  vcn_id         = var.config.vcn_id
}

locals {
  # naming conventions
  display_name  = "${data.oci_identity_compartment.service.name}_${var.subnet.domain}"
  dns_label     = "${format("%s%s%s", lower(substr(split("_", data.oci_identity_compartment.service.name)[0], 0, 3)), lower(substr(split("_", data.oci_identity_compartment.service.name)[1], 0, 5)), var.subnet.domain)}"
  bastion_label = "${local.dns_label}bstn"
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