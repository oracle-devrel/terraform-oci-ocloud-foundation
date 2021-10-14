# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- database admin --- //
variable "database" {
  default       = "Database"
  type          = string
  description   = "Identify the Section, use a unique name"
  validation {
    condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,14}$", var.database)) > 0
    error_message = "The service_name variable is required and must contain alphanumeric characters only, start with a letter, have at least consonants and contains up to 15 letters."
  }
}
module "database_section" {
  source = "./component/admin_section/"
  providers      = { oci = oci.home }
  depends_on = [
    oci_identity_compartment.init, 
    module.operation_section,
    module.network_section
  ]
  config  = {
    tenancy_id    = var.tenancy_ocid
    source        = var.source_url
    display_name  = lower("${local.service_name}_${var.database}")
    freeform_tags = { 
      "framework" = "ocloud"
    }
  }
  compartment  = {
    enable_delete = true #Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed
    parent        = local.service_id
  }
  roles = {
    "${local.service_name}_dbops"  = [
      "ALLOW GROUP ${local.service_name}_dbops manage database-family in compartment ${lower("${local.service_name}_${var.database}")}_compartment",
      "ALLOW GROUP ${local.service_name}_dbops read all-resources in compartment ${lower("${local.service_name}_${var.database}")}_compartment",
      "ALLOW GROUP ${local.service_name}_dbops manage subnets in compartment ${lower("${local.service_name}_${var.database}")}_compartment"
    ]
  }
}
output "db_domain_subnet"        { value = module.database_domain.subnet }
output "db_domain_security_list" { value = module.database_domain.seclist }
output "db_domain_bastion"       { value = module.database_domain.bastion }
// --- database admin --- //

// --- database tier --- //
module "database_domain" {
  source           = "./component/network_domain/"
  providers        = { oci = oci.home }
  depends_on       = [ module.database_section, module.service_segment ]
  config  = {
    service_id     = local.service_id
    compartment_id = module.database_section.compartment_id
    vcn_id         = module.service_segment.vcn_id
    anywhere       = module.service_segment.anywhere
    defined_tags   = null
    freeform_tags  = { "framework" = "ocloud" }
  }
  subnet  = {
    # Select the predefined name per index
    domain                      = element(keys(module.service_segment.subnets), 1)
    # Select the predefined range per index
    cidr_block                  = element(values(module.service_segment.subnets), 1)
    prohibit_public_ip_on_vnic  = true
    dhcp_options_id             = null
    route_table_id              = module.service_segment.osn_route_table_id
  }
  bastion  = {
    create            = false # Determine whether a bastion service will be deployed and attached
    client_allow_cidr = [ module.service_segment.anywhere ]
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
output "db_compartment_id"       { value = module.database_section.compartment_id }
output "db_compartment_name"     { value = module.database_section.compartment_name }
output "db_compartment_roles"    { value = module.database_section.roles }
// --- database tier --- //