// Copyright (c) 2020 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// Global settings and naming conventions
// In order to apply these settings run the following command 'terraform plan -var tenancy_ocid=$OCI_TENANCY -var compartment_ocid="..." -out config.tfplan'
// and than 'terraform apply "config.tfplan" -auto-approve'

// --- OCI service provider ---
provider "oci" {
  alias                = "home"
  region               = local.regions_map[local.home_region_key]
}

// --- ORM configuration ---
variable "tenancy_ocid"     { }
variable "compartment_ocid" { }
variable "region"           { }

// --- tenancy configuration ---
data "oci_identity_regions"              "tenancy" { } # Retrieve a list OCI regions
data "oci_objectstorage_namespace"       "tenancy" { compartment_id = var.tenancy_ocid } # Retrieve object storage namespace
data "oci_identity_availability_domains" "tenancy" { compartment_id = var.tenancy_ocid } # Get a list of Availability Domains
data "oci_identity_compartments"         "tenancy" { compartment_id = var.tenancy_ocid } # List root compartments

// --- data sources for main compartment ---
data "oci_identity_tenancy"              "init"    { tenancy_id     = var.tenancy_ocid }       # Retrieve meta data for tenancy
data "template_file" "ad_names" {                                           
  # List AD names in home region 
  count    = length(data.oci_identity_availability_domains.tenancy.availability_domains)
  template = lookup(data.oci_identity_availability_domains.tenancy.availability_domains[count.index], "name")
}

data "oci_identity_compartments" "init" {
  depends_on     = [ oci_identity_compartment.init ]
  compartment_id = var.tenancy_ocid
  name           = local.service_name
  state          = "ACTIVE"
}

data "oci_identity_tag_namespaces" "init" {
  depends_on = [ oci_identity_compartment.init ]
  # This allows the namespace details to be retrieved
  compartment_id          = var.tenancy_ocid
  include_subcompartments = false
  state                   = "ACTIVE"
  filter {
    name  = "name"
    values = [ "${local.service_name}_tag_namespace" ]
  }
}

data "oci_identity_policies" "init" {
    compartment_id = oci_identity_compartment.init.id
    state          = "ACTIVE"
}

// --- input functions ---
locals {
  # Discovering the home region name and region key.
  regions_map         = {for rgn in data.oci_identity_regions.tenancy.regions : rgn.key => rgn.name} # All regions indexed by region key.
  regions_map_reverse = {for rgn in data.oci_identity_regions.tenancy.regions : rgn.name => rgn.key} # All regions indexed by region name.
  home_region_key     = data.oci_identity_tenancy.init.home_region_key                              # Home region key obtained from the tenancy data source
  home_region         = local.regions_map[local.home_region_key]                                     # Region key obtained from the region name
  # Service identifier
  service_name        = lower("${var.organization}_${var.project}_${var.environment}")
  service_id          = length(data.oci_identity_compartments.init.compartments) > 0 ? data.oci_identity_compartments.init.compartments[0].id : oci_identity_compartment.init.id
}

// --- configuration data ---
module "bundle" {
  source     = "./input/"
  providers  = { oci = oci.home }
  bundle     = var.bundle
}

// --- global outputs ----
output "config_account"             { value = data.oci_identity_tenancy.init }
output "config_storage_namespace"   { value = data.oci_objectstorage_namespace.tenancy.namespace }
# List of ADs in the selected region
output "config_location_ad_names"   { value = sort(data.template_file.ad_names.*.rendered) }
# Resource scope for the landing zone
output "config_bundle_id"           { value = module.bundle.bundle_id }

// Define the wait state for the data requests. This resource will destroy (potentially immediately) after null_resource.next
resource "null_resource" "previous" {}

resource "time_sleep" "wait" {
  depends_on      = [null_resource.previous]
  create_duration = "4m"
}