// Copyright (c) 2020 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// Global settings and naming conventions
// In order to apply these settings run the following command 'terraform plan -var tenancy_ocid=$OCI_TENANCY -var compartment_ocid="..." -out config.tfplan'
// and than 'terraform apply "config.tfplan" -auto-approve'

// --- OCI service provider ---
provider "oci" {
  alias  = "home"
  region = local.regions_map[data.oci_identity_tenancy.init.home_region_key]
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

data "oci_identity_compartments" "service" {
  depends_on     = [ oci_identity_compartment.service ]
  compartment_id = var.tenancy_ocid
  name           = local.service_name
  state          = "ACTIVE"
}

data "oci_identity_tag_namespaces" "service" {
  depends_on = [ oci_identity_compartment.service ]
  # This allows the namespace details to be retrieved
  compartment_id          = var.tenancy_ocid
  include_subcompartments = true
  state                   = "ACTIVE"
  filter {
    name = "compartment_id"
    values = [ local.service_id ]
  }
}

data "oci_identity_tags" "service" {
  for_each         = oci_identity_tag_namespace.service
  tag_namespace_id = oci_identity_tag_namespace.service[each.key].id
  state            = "ACTIVE"
}

data "oci_identity_policies" "service" {
    compartment_id = oci_identity_compartment.service.id
    state          = "ACTIVE"
}

// --- input functions ---
locals {
  # Service name
  service_name    = lower("${var.organization}_${var.project}_${var.environment}")
  # Service identifier
  service_id      = length(data.oci_identity_compartments.service.compartments) > 0 ? data.oci_identity_compartments.service.compartments[0].id : oci_identity_compartment.service.id
  # Default tags for service
  service_tags    = { for tag in oci_identity_tag.service : oci_identity_tag.service[tag.name].id => module.compose.default_value[tag.name] }
  #tag_collection  = { for namespace in keys(module.compose.tag_collections) : namespace => oci_identity_tag_namespace.service[namespace].id }
  tagsbyids       = merge([ for collection, tags in module.compose.tag_collections : { for tag in tags : tag => oci_identity_tag_namespace.service[collection].id } ]...)
  # Discover the region name by region key
  regions_map     = { for region in data.oci_identity_regions.tenancy.regions : region.key => region.name }
  # Discover the region key by region name
  regions_reverse = { for region in data.oci_identity_regions.tenancy.regions : region.name => region.key }
}

// --- configuration data ---
module "compose" {
  source     = "./compose/"
  service_id = local.service_id
  providers  = { oci = oci.home }
}

// Define the wait state for the data requests. This resource will destroy (potentially immediately) after null_resource.next
resource "null_resource" "previous" {}

resource "time_sleep" "wait" {
  depends_on      = [null_resource.previous]
  create_duration = "4m"
}