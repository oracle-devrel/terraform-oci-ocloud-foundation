# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_tenancy"     "ocloud" { tenancy_id = var.config.tenancy_id } # Retrieve meta data for tenant
data "oci_identity_compartment" "domain" { id         = var.config.compartment_id }  # Retrieve meta data for the target compartment
data "oci_core_services"        "all_services" { }                                # Request a list of Oracle Service Network (osn) services
data "oci_core_vcn"             "domain" { vcn_id     = var.config.vcn_id }     # Retrieve meta data for the target vcn

# Request a list of Oracle Service Network (osn) services
/*
data "oci_core_services" "all_services" { }
data "oci_core_services" "ocloud" { }

# Bastion config data sources
data "oci_bastion_bastions" "ocloud" {
  compartment_id          = var.bastion.compartment_id
  bastion_id              = oci_bastion_bastion.ocloud.id
  bastion_lifecycle_state = "ACTIVE"
  name                    = "bstn${var.config.dns_label}"
}

data "oci_identity_availability_domain" "bastion_ad" {
  compartment_id = var.config.tenancy_id
  ad_number      = 1
}
*/