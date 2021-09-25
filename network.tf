# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- admin section ---
module "net_section" {
  source = "./component/admin_section/"
  providers      = { oci = oci.home }
  depends_on = [ module.ops_section, ]
  config  = {
    tenancy_id    = var.tenancy_ocid
    source        = var.source_url
    mail          = var.admin_mail
    slack         = var.slack_channel
    display_name  = "${local.service_name}_network"
    dns_label     = "${local.service_label}"
    defined_tags  = null
    freeform_tags = {"framework"= "ocloud"}
  }
  compartment  = {
    enable_delete = false #Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed
    parent        = data.oci_identity_compartment.main.id
  }
  roles = {
    "${local.service_name}_netops"  = [
      "Allow group ${local.service_name}_netops to read all-resources in compartment ${data.oci_identity_compartment.main.name}:${local.service_name}_network_compartment",
      "Allow group ${local.service_name}_netops to manage virtual-network-family in compartment ${data.oci_identity_compartment.main.name}:${local.service_name}_network_compartment",
      "Allow group ${local.service_name}_netops to manage dns in compartment ${data.oci_identity_compartment.main.name}:${local.service_name}_network_compartment",
      "Allow group ${local.service_name}_netops to manage load-balancers in compartment ${data.oci_identity_compartment.main.name}:${local.service_name}_network_compartment",
      "Allow group ${local.service_name}_netops to manage alarms in compartment ${data.oci_identity_compartment.main.name}:${local.service_name}_network_compartment",
      "Allow group ${local.service_name}_netops to manage metrics in compartment ${data.oci_identity_compartment.main.name}:${local.service_name}_network_compartment",
      "Allow group ${local.service_name}_netops to manage orm-stacks in compartment ${data.oci_identity_compartment.main.name}:${local.service_name}_network_compartment",
      "Allow group ${local.service_name}_netops to manage orm-jobs in compartment ${data.oci_identity_compartment.main.name}:${local.service_name}_network_compartment",
      "Allow group ${local.service_name}_netops to manage orm-config-source-providers in compartment ${data.oci_identity_compartment.main.name}:${local.service_name}_network_compartment",
      "Allow Group ${local.service_name}_netops to read audit-events in compartment ${data.oci_identity_compartment.main.name}:${local.service_name}_network_compartment",
      "Allow Group ${local.service_name}_netops to read vss-family in compartment ${data.oci_identity_compartment.main.name}:${local.service_name}_network_compartment"
    ]
  }
}
// --- section output (optional) ---
# output "net_compartment"  { value = data.oci_identity_compartments.net }
output "net_compartment"    { value = module.net_section.compartment }
output "net_roles"          { value = module.net_section.roles }
output "net_topic"          { value = module.net_section.notifications }
output "net_subscription"   { value = module.net_section.subscriptions }

// --- network segment ---
module "segment_1" {
  source         = "./component/network_segment/"
  providers      = { oci = oci.home }
  depends_on = [ module.net_section ]
  config  = {
    compartment_id = module.net_section.compartment.id
    display_name   = "${local.service_name}_1"
    dns_label      = "${local.service_label}net1"
    defined_tags   = null
    freeform_tags  = {"framework"= "ocloud"}
  }
  vcn = {
    description                     = "virtual cloud network"
    address_spaces = {
      "cidr_block"                  = "10.0.0.0/24" 
      "anywhere"                    = "0.0.0.0/0"
      "interconnect"                = "192.168.0.0/16"
    }
    subnet_list = { 
      # A list with newbits for the cidrsubnet function, for subnet calculations visit http://jodies.de/ipcalc
      app                           = 1
      db                            = 2
      pres                          = 2
    }
    block_nat_traffic               = false
    service_gateway_cidr            = "all-${lower(local.home_region_key)}-services-in-oracle-services-network" #Alternative: "oci-${local.region_key}-objectstorage"
  }
  drg = {
    create_drg                      = true
    dns_label                       = "${local.service_label}drg1"
    description                     = "dynamic routing gateway"
  }
}

// --- network segment output ---
output "net_segment_1_vcn"              { value = module.segment_1.vcn }
output "net_segment_1_cidr_block"       { value = module.segment_1.cidr_block }
output "net_segment_1_subnets"          { value = module.segment_1.subnets }
output "net_segment_1_security_group"   { value = module.segment_1.security_group }
output "net_segment_1_anywhere"         { value = module.segment_1.anywhere }
output "net_segment_1_internet_gateway" { value = module.segment_1.internet_gateway }
output "net_segment_1_nat_gateway"      { value = module.segment_1.nat_gateway }
output "net_segment_1_service_gateway"  { value = module.segment_1.service_gateway }
output "net_segment_1_osn"              { value = module.segment_1.osn }
output "net_segment_1_drg"              { value = module.segment_1.drg }
output "net_segment_1_osn_route_id"     { value = module.segment_1.osn_route_table }
output "net_segment_1_private_route_id" { value = module.segment_1.private_route_table }
output "net_segment_1_public_route_id"  { value = module.segment_1.public_route_table }
output "net_segment_1_route_tables"     { value = tomap({ "segment_1_public_route_id" = module.segment_1.public_route_table.id, "segment_1_private_route_id" = module.segment_1.private_route_table.id, "segment_1_osn_route_id" = module.segment_1.osn_route_table.id })}

// --- network domain ---
module "pres_domain" {
  source           = "./component/network_domain/"
  providers        = { oci = oci.home }
  depends_on       = [module.net_section, module.segment_1]
  config  = {
    tenancy_id     = var.tenancy_ocid
    compartment_id = module.net_section.compartment.id
    vcn_id         = module.segment_1.vcn.id
    anywhere       = module.segment_1.anywhere
    display_name   = "${local.service_name}_presentation"
    dns_label      = "${local.service_label}pres"
    defined_tags   = null
    freeform_tags  = {"framework" = "ocloud"}
  }
  subnet  = {
    cidr_block                  = module.segment_1.subnets.pres
    prohibit_public_ip_on_vnic  = false
    dhcp_options_id             = null
    route_table_id              = module.segment_1.public_route_table.id
  }
  bastion  = {
    create            = false # Determine whether a bastion service will be deployed and attached
    client_allow_cidr = [module.segment_1.anywhere]
    max_session_ttl   = 1800
  }
  tcp_ports = {
    // [protocol, source_cidr, destination port min, max]
    ingress  = [
      ["ssh",   module.segment_1.anywhere,  22,  22], 
      ["http",  module.segment_1.anywhere,  80,  80], 
      ["https", module.segment_1.anywhere, 443, 443]
    ]
  }
}

// --- domain output (optional) ---
output "presentation_domain_subnet"        { value = module.pres_domain.subnet }
output "presentation_domain_security_list" { value = module.pres_domain.seclist }
output "presentation_domain_bastion"       { value = module.pres_domain.bastion }