# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "service_id"                     { }
# Retrieve a list OCI regions 
data "oci_identity_regions" "tenancy"     { } 
data "oci_identity_compartment" "service" { id = var.service_id }
# Retrieve meta data for tenancy
data "oci_identity_tenancy" "service"     { tenancy_id = data.oci_identity_compartment.service.compartment_id }

locals {
  # Discovering the home region name and region key.
  regions_map         = {for location in data.oci_identity_regions.tenancy.regions : location.key => location.name}
  regions_map_reverse = {for location in data.oci_identity_regions.tenancy.regions : location.name => location.key}
  # Home region key obtained from the tenancy data source
  home_region_key     = data.oci_identity_tenancy.service.home_region_key
  # Region key obtained from the region name
  home_region_name         = local.regions_map[local.home_region_key]
}

output "location_key"  { value = lower(local.home_region_key) }
output "location_name" { value = local.home_region_name }