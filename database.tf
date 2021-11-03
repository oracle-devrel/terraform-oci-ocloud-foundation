# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- database admin --- //
module "database_section" {
  source = "./component/admin_section/"
  providers      = { oci = oci.home }
  depends_on = [
    oci_identity_compartment.init, 
    module.operation_section,
    module.network_section,
    module.application_section
  ]
  section_name    = "database"
  config ={
    tenancy_id    = var.tenancy_ocid
    source        = var.code_source
    service_name  = local.service_name
    tagspace      = [ ]
    freeform_tags = { 
      "framework" = "ocloud"
    }
  }
  compartment  = {
    enable_delete = true #Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed
    parent        = local.service_id
  }
  roles = {
    "${local.service_name}_dbops" = [
      "ALLOW GROUP ${local.service_name}_dbops manage database-family in compartment ${lower("${local.service_name}_database_compartment")}",
      "ALLOW GROUP ${local.service_name}_dbops read all-resources in compartment ${lower("${local.service_name}_database_compartment")}",
      "ALLOW GROUP ${local.service_name}_dbops manage subnets in compartment ${lower("${local.service_name}_database_compartment")}",
      # "Allow group ${local.service_name}_dbops to use bastion in compartment ${lower("${local.service_name}_application_compartment")}",
      # "Allow group ${local.service_name}_dbops to manage bastion-session in compartment ${lower("${local.service_name}_application_compartment")}",
      # "Allow group ${local.service_name}_dbops to manage virtual-network-family in compartment ${lower("${local.service_name}_application_compartment")}",
      # "Allow group ${local.service_name}_dbops to read instance-family in compartment ${lower("${local.service_name}_application_compartment")}",
      # "Allow group ${local.service_name}_dbops to read instance-agent-plugins in compartment ${lower("${local.service_name}_application_compartment")}",
      # "Allow group ${local.service_name}_dbops to inspect work-requests in tenancy"
    ]
  }
}
output "db_compartment_id"       { value = module.database_section.compartment_id }
output "db_compartment_name"     { value = module.database_section.compartment_name }
output "db_compartment_roles"    { value = module.database_section.roles }
// --- database admin --- //

/*/ --- database tier --- //
module "database_domain" {
  source           = "./component/network_domain/"
  providers        = { oci = oci.home }
  depends_on       = [ module.database_section, module.service_segment ]
  config  = {
    service_id     = local.service_id
    compartment_id = module.network_section.compartment_id
    vcn_id         = module.service_segment.vcn_id
    anywhere       = module.service_segment.anywhere
    defined_tags   = null
    freeform_tags  = { "framework" = "ocloud" }
  }
  subnet  = {
    # Select a domain name from subnet map in the service segment
    domain                      = "db"
    cidr_block                  = lookup(module.service_segment.subnets, "db", "This CIDR is not defined") 
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
      ["ssh",   module.service_segment.anywhere,    22,  22], 
      ["http",  module.service_segment.anywhere,    80,  80], 
      ["https", module.service_segment.anywhere,   443, 443],
      ["sql",   module.service_segment.anywhere, 1521, 1522]
    ]
  }
}
output "db_domain_subnet_id"        { value = module.database_domain.subnet_id }
output "db_domain_security_list_id" { value = module.database_domain.seclist_id }
output "db_domain_bastion_id"       { value = module.database_domain.bastion_id }
// --- database tier --- /*/