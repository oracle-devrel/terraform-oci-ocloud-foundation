# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- network admin --- //
variable "network" {
  default     = "Network"
  type        = string
  description = "Identify the Section, use a unique name"
  validation {
    condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,14}$", var.network)) > 0
    error_message = "The service_name variable is required and must contain alphanumeric characters only, start with a letter, have at least consonants and contains up to 15 letters."
  }
}
module "network_section" {
  source = "./component/admin_section/"
  providers      = { oci = oci.home }
  depends_on     = [ module.operation_section ]
  config  = {
    tenancy_id    = var.tenancy_ocid
    source        = var.source_url
    display_name  = lower("${local.service_name}_${var.network}")
    freeform_tags = { 
      "framework" = "ocloud"
    }
  }
  compartment  = {
    # Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed
    enable_delete = true 
    parent        = local.service_id
  }
  roles = {
    "${local.service_name}_netops"  = [
      "Allow group ${local.service_name}_netops to read all-resources in compartment ${lower("${local.service_name}_${var.network}")}_compartment",
      "Allow group ${local.service_name}_netops to manage virtual-network-family in compartment ${lower("${local.service_name}_${var.network}")}_compartment",
      "Allow group ${local.service_name}_netops to manage dns in compartment ${lower("${local.service_name}_${var.network}")}_compartment",
      "Allow group ${local.service_name}_netops to manage load-balancers in compartment ${lower("${local.service_name}_${var.network}")}_compartment",
      "Allow group ${local.service_name}_netops to manage alarms in compartment ${lower("${local.service_name}_${var.network}")}_compartment",
      "Allow group ${local.service_name}_netops to manage metrics in compartment ${lower("${local.service_name}_${var.network}")}_compartment",
      "Allow group ${local.service_name}_netops to manage orm-stacks in compartment ${lower("${local.service_name}_${var.network}")}_compartment",
      "Allow group ${local.service_name}_netops to manage orm-jobs in compartment ${lower("${local.service_name}_${var.network}")}_compartment",
      "Allow group ${local.service_name}_netops to manage orm-config-source-providers in compartment ${lower("${local.service_name}_${var.network}")}_compartment",
      "Allow Group ${local.service_name}_netops to read audit-events in compartment ${lower("${local.service_name}_${var.network}")}_compartment",
      "Allow Group ${local.service_name}_netops to read vss-family in compartment ${lower("${local.service_name}_${var.network}")}_compartment"
    ]
  }
}
output "network_id"                        { value = module.network_section.compartment_id }
output "network_name"                      { value = module.network_section.compartment_name }
output "network_roles"                     { value = module.network_section.roles }
// --- network admin --- //

// --- service segment --- //
module "service_segment" {
  source     = "./component/network_segment/"
  providers  = { oci = oci.home }
  depends_on = [ module.network_section ]
  # Define unique number per segment
  segment    = 1 
  config     = {
    service_id     = local.service_id
    display_name   = lower("${local.service_name}_${var.network}")
    compartment_id = module.network_section.compartment_id
    source         = var.source_url
    freeform_tags  = { 
      "framework"  = "ocloud"
    }
  }
  network = {
    description          = "virtual cloud network"
    address_spaces = {
      "cidr_block"       = "10.0.0.0/24" 
      "anywhere"         = "0.0.0.0/0"
      "interconnect"     = "192.168.0.0/16"
    }
    subnet_list = { 
      # A list with newbits for the cidrsubnet function, for subnet calculations visit http://jodies.de/ipcalc
      app                = 1
      db                 = 2
      pres               = 2
    }
    create_drg           = true
    block_nat_traffic    = false
    # Alternative: "oci-${local.region_key}-objectstorage"
    service_gateway_cidr = "all-${lower(local.home_region_key)}-services-in-oracle-services-network" 
  }
}
output "service_segment_vcn_id"           { value = module.service_segment.vcn_id }
output "service_segment_cidr_block"       { value = module.service_segment.cidr_block }
output "service_segment_subnets"          { value = module.service_segment.subnets }
output "service_segment_security_group"   { value = module.service_segment.security_group }
output "service_segment_anywhere"         { value = module.service_segment.anywhere }
output "service_segment_drg_id"           { value = module.service_segment.drg_id }
output "service_segment_internet_id"      { value = module.service_segment.internet_id }
output "service_segment_nat_id"           { value = module.service_segment.nat_id }
output "service_segment_osn_id"           { value = module.service_segment.osn_id }
output "service_segment_osn"              { value = module.service_segment.osn }
output "service_segment_osn_route_id"     { value = module.service_segment.osn_route_table_id }
output "service_segment_private_route_id" { value = module.service_segment.private_route_table_id }
output "service_segment_public_route_id"  { value = module.service_segment.public_route_table_id }
output "service_segment_route_tables"     { value = tomap({ "service_segment_public_route_id" = module.service_segment.public_route_table_id, "service_segment_private_route_id" = module.service_segment.private_route_table_id, "service_segment_osn_route_id" = module.service_segment.osn_route_table_id })}
// --- service segment --- //

// --- presentation tier --- //
module "presentation_domain" {
  source           = "./component/network_domain/"
  providers        = { oci = oci.home }
  depends_on       = [ module.network_section, module.service_segment ]
  config  = {
    service_id     = local.service_id
    compartment_id = module.network_section.compartment_id
    vcn_id         = module.service_segment.vcn_id
    anywhere       = module.service_segment.anywhere
    defined_tags   = null
    freeform_tags  = { "framework" = "ocloud" }
  }
  subnet  = {
    # Select the predefined domain per index
    domain                      = element(keys(module.service_segment.subnets), 2)
    # Select the predefined domain per index
    cidr_block                  = element(values(module.service_segment.subnets), 2) 
    prohibit_public_ip_on_vnic  = false
    dhcp_options_id             = null
    route_table_id              = module.service_segment.public_route_table_id
  }
  bastion  = {
    create            = false # Determine whether a bastion service will be deployed and attached
    client_allow_cidr = [module.service_segment.anywhere]
    max_session_ttl   = 1800
  }
  tcp_ports = {
    // [protocol, source_cidr, destination port min, max]
    ingress  = [
      ["ssh",   module.service_segment.anywhere,  22,  22], 
      ["http",  module.service_segment.anywhere,  80,  80], 
      ["https", module.service_segment.anywhere, 443, 443]
    ]
  }
}
output "presentation_domain_subnet"        { value = module.presentation_domain.subnet }
output "presentation_domain_security_list" { value = module.presentation_domain.seclist }
output "presentation_domain_bastion"       { value = module.presentation_domain.bastion }
// --- presentation tier --- //