// Copyright (c) 2020 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
# readme.md created with https://terraform-docs.io/: terraform-docs markdown --sort=false ./ > ./readme.md

// --- Terraform Provider --- //
terraform {
    required_providers {
        oci = {
            source = "hashicorp/oci"
        }
    }
}
// --- Terraform Provider --- //

// --- Tenancy Configuration ---//
data "oci_identity_tenancy"      "resident" {tenancy_id = var.input.tenancy}
data "oci_identity_regions"      "tenancy" { }
data "oci_identity_availability_domains" "tenancy" {compartment_id = var.input.tenancy}
data "oci_objectstorage_namespace"       "tenancy" {compartment_id = var.input.tenancy}
# list data center (availability domain) names in home region 
data "template_file" "ad_names" { 
    count    = length(data.oci_identity_availability_domains.tenancy.availability_domains)
    template = lookup(data.oci_identity_availability_domains.tenancy.availability_domains[count.index], "name")
}
# retrieve parameter of Oracle Service Network (osn) services
data "oci_core_services" "all" {
    filter {
        name   = "name"
        values = ["All .* Services In Oracle Services Network"]
        regex  = true
    }
}

data "oci_core_services" "storage" {
    filter {
        name   = "name"
        values = ["OCI .* Object Storage"]
        regex  = true
    }
}

locals {
    # Discovering the home region name and region key.
    regions_map         = {for region in data.oci_identity_regions.tenancy.regions : region.key => region.name}
    regions_map_reverse = {for region in data.oci_identity_regions.tenancy.regions : region.name => region.key}
    # Deployment region
    region_key          = local.regions_map_reverse[var.input.region]
    region_name         = var.input.region
    # Home region key obtained from the tenancy data source
    home_region_key     = data.oci_identity_tenancy.resident.home_region_key
    # Region key obtained from the region name
    home_region_name    = local.regions_map[local.home_region_key]
    home_region_ads     = sort(data.template_file.ad_names.*.rendered)
    # Object Storage Namespace for the tenancy
    storage_namespace   = data.oci_objectstorage_namespace.tenancy.namespace
    osn_ids = {
        "all"     = lookup(data.oci_core_services.all.services[0], "id")
        "storage" = lookup(data.oci_core_services.storage.services[0], "id")
    }
    osn_cidrs = {
        "all"     = lookup(data.oci_core_services.all.services[0], "cidr_block")
        "storage" = lookup(data.oci_core_services.storage.services[0], "cidr_block")
    }
}
// --- Tenancy Configuration ---//
