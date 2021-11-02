# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- application admin --- //
module "application_section" {
  source         = "./component/admin_section/"
  providers      = { oci = oci.home }
  depends_on = [
    oci_identity_compartment.init, 
    module.operation_section,
    module.network_section
  ]
  section_name    = "application"
  config ={
    tenancy_id    = var.tenancy_ocid
    source        = var.source_url
    service_name  = local.service_name
    tagspace      = [ ]
    freeform_tags = { 
      "framework" = "ocloud"
    }
  }
  compartment  = {
    enable_delete = true # Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed
    parent        = local.service_id
  }
  roles = {
    "${local.service_name}_sysops"  = [
      "Allow group ${local.service_name}_sysops to read all-resources in compartment ${lower("${local.service_name}_application_compartment")}",
      "Allow group ${local.service_name}_sysops to use volume-family in compartment ${lower("${local.service_name}_application_compartment")}",
      "Allow group ${local.service_name}_sysops to use virtual-network-family in compartment ${lower("${local.service_name}_application_compartment")}",
      "Allow group ${local.service_name}_sysops to manage instances in compartment ${lower("${local.service_name}_application_compartment")}",
      "Allow group ${local.service_name}_sysops to manage instance-images in compartment ${lower("${local.service_name}_application_compartment")}",
      "Allow group ${local.service_name}_sysops to manage object-family in compartment ${lower("${local.service_name}_application_compartment")}"
    ]
  }
}
output "app_compartment_id"       { value = module.application_section.compartment_id }
output "app_compartment_name"     { value = module.application_section.compartment_name }
output "app_compartment_roles"    { value = module.application_section.roles }
// --- application admin --- //

// --- application tier --- //
module "application_domain" {
  source         = "./component/network_domain/"
  providers      = { oci = oci.home }
  depends_on     = [ module.application_section, module.service_segment ]
  config  = {
    service_id     = local.service_id
    compartment_id = module.network_section.compartment_id
    vcn_id         = module.service_segment.vcn_id
    anywhere       = module.service_segment.anywhere
    defined_tags   = null
    freeform_tags  = {"framework" = "ocloud"}
  }
  subnet  = {
    # Select a domain name from subnet map in the service segment
    domain                      = "app"
    cidr_block                  = lookup(module.service_segment.subnets, "app", "This CIDR is not defined") 
    prohibit_public_ip_on_vnic  = true
    dhcp_options_id             = null
    route_table_id              = module.service_segment.private_route_table_id
  }
  bastion  = {
    # Determine whether a bastion service will be deployed and attached
    create            = true
    client_allow_cidr = [module.service_segment.anywhere]
    max_session_ttl   = 1800
  }
  tcp_ports = {
    ingress  = [
      ["ssh",   module.service_segment.subnets.pres, 22,  22],
      ["http",  module.service_segment.anywhere,     80,  80], 
      ["https", module.service_segment.anywhere,    443, 443]
    ]
  }
}
output "app_domain_subnet_id"        { value = module.application_domain.subnet_id }
output "app_domain_security_list_id" { value = module.application_domain.seclist_id }
output "app_domain_bastion_id"       { value = module.application_domain.bastion_id }
// --- application tier --- //

// --- application host --- //
module "operator" {
  source         = "./component/application_host/"
  providers      = { oci = oci.home }
  depends_on     = [ module.application_section, module.service_segment, module.application_domain ]
  host_name      = "operator"
  config  = {
    service_id     = local.service_id
    compartment_id = module.application_section.compartment_id
    source         = var.source_url
    vcn_id         = module.service_segment.vcn_id
    bastion_id     = module.application_domain.bastion_id
    ad_number      = 1
    subnet_ids     = [ module.application_domain.subnet_id ]
    defined_tags   = null
    freeform_tags  = {"framework"  = "ocloud"}
  }
  host = {
    server = "small"
    nic    = "private"
    os     = "linux"
    lun    = "san"
  }
  ssh = {
    # Determine whether a ssh session via bastion service will be started
    enable          = false
    type            = "MANAGED_SSH" # Alternatively "PORT_FORWARDING"
    ttl_in_seconds  = 1800
    target_port     = 22
  }
}
output "app_instance_summary"      { value = module.operator.summary }
output "app_instance_details"      { value = module.operator.details }
output "app_instance_windows_user" { value = module.operator.username }
output "app_instance_ol8_version"  { value = module.operator.oracle-linux-8-latest-version }
output "app_instance_ol8_id"       { value = module.operator.oracle-linux-8-latest-id }
output "app_instance_ssh"          { value = module.operator.ssh }
// --- application host --- //