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