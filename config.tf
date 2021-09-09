# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// Global settings and naming conventions
// In order to apply these settings run the following command 'terraform plan -var tenancy_ocid=$OCI_TENANCY -var compartment_ocid="..." -out config.tfplan'
// and than 'terraform apply "config.tfplan" -auto-approve'

## --- OCI service provider ---
provider "oci" {
  alias                = "home"
  region               = local.regions_map[local.home_region_key]
}

## --- ORM configuration ---
variable "region" { }
variable "tenancy_ocid" { }
variable "compartment_ocid" { }

## --- settings ---
variable "base_url" {
  type        = string
  description = "URL for the git repository"
  default     = "https://gitlab.com/tboettjer/ocloud-base"
}

## --- data sources ---
data "oci_identity_regions"              "global"  { }                                        # Retrieve a list OCI regions
data "oci_identity_tenancy"              "ocloud"  { tenancy_id     = var.tenancy_ocid }      # Retrieve meta data for tenant
data "oci_identity_availability_domains" "ads"     { compartment_id = var.tenancy_ocid }      # Get a list of Availability Domains
data "oci_identity_compartments"         "root"    { compartment_id = var.tenancy_ocid }      # List root compartments
data "oci_objectstorage_namespace"       "ns"      { compartment_id = var.tenancy_ocid }      # Retrieve object storage namespace
data "template_file" "ad_names"                    {                                          # List AD names in home region 
  count    = length(data.oci_identity_availability_domains.ads.availability_domains)
  template = lookup(data.oci_identity_availability_domains.ads.availability_domains[count.index], "name")
}

## --- input functions ---
# Define the home region identifier
locals {
  # Discovering the home region name and region key.
  regions_map         = {for rgn in data.oci_identity_regions.global.regions : rgn.key => rgn.name} # All regions indexed by region key.
  regions_map_reverse = {for rgn in data.oci_identity_regions.global.regions : rgn.name => rgn.key} # All regions indexed by region name.
  home_region_key     = data.oci_identity_tenancy.ocloud.home_region_key                            # Home region key obtained from the tenancy data source
  home_region         = local.regions_map[local.home_region_key]                                # Region key obtained from the region name

  # Service label
  service_label = format("%s%s", lower(substr(var.organization, 0, 3)), lower(substr(var.project, 0, 5)))
  service_name  = lower("${var.organization}_${var.project}")
}

## --- global outputs ----
output "config_account"   { value = data.oci_identity_tenancy.ocloud }
output "config_namespace" { value = data.oci_objectstorage_namespace.ns.namespace }
output "config_ad_names"  { value = sort(data.template_file.ad_names.*.rendered) } # List of ADs in the selected region
# output "config_tenancy"             { value = var.tenancy_ocid }
# output "config_console_compartment" { value = var.compartment_ocid}
# output "config_console_region"      { value = var.region }
# output "config_root_compartment"    { value = data.oci_identity_compartments.root.compartment_id }
# output "config_home_region"         { value = local.home_region }
# output "config_home_region_key"     { value = local.home_region_key }
# output "config_region_map"          { value = local.regions_map }
# output "config_region_map_reverse"  { value = local.regions_map_reverse }
# output "config_service_label"       { value = local.service_label }
# output "config_service_name"        { value = local.service_name }
