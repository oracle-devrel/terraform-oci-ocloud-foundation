# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# Request a list of Oracle Service Network (osn) services
data "oci_core_services" "all_services" { }

# Bastion config data sources
data "oci_bastion_bastions" "ocloud" {
  compartment_id          = var.bastion.compartment_id
  bastion_id              = oci_bastion_bastion.ocloud.id
  bastion_lifecycle_state = "ACTIVE"
  name                    = "bstn${var.config.dns_label}"
}

data "oci_core_services" "ocloud" {
}

data "oci_identity_availability_domain" "bastion_ad" {
  compartment_id = var.config.tenancy_id
  ad_number      = 1
}

locals {
    ## Create a map from network names to allocated address prefixes in CIDR notation
    subnet_ranges    = cidrsubnets(var.subnet.cidr_block, values(var.subnet.subnet_list)...)
    subnet_names     = keys(var.subnet.subnet_list)
    subnet_map       = zipmap(local.subnet_names, local.subnet_ranges)
}