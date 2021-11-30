# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- network admin --- //
module "network_section" {
  source       = "./component/admin_section/"
  providers    = { oci = oci.home }
  depends_on   = [ oci_identity_compartment.service, module.operation_section ]
  section_name = "network"
  config = {
    service_id    = local.service_id
    bundle_type   = module.compose.bundle_id
    tagspace      = [ ]
    freeform_tags = { 
      "source"    = var.code_source
    }
  }
  compartment  = {
    # Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed
    enable_delete = true 
    parent        = local.service_id
  }
  roles = {
    "${local.service_name}_netops"  = [
      "Allow group ${local.service_name}_netops to read all-resources in compartment ${lower("${local.service_name}_network_compartment")}",
      "Allow group ${local.service_name}_netops to manage virtual-network-family in compartment ${lower("${local.service_name}_network_compartment")}",
      "Allow group ${local.service_name}_netops to manage dns in compartment ${lower("${local.service_name}_network_compartment")}",
      "Allow group ${local.service_name}_netops to manage load-balancers in compartment ${lower("${local.service_name}_network_compartment")}",
      "Allow group ${local.service_name}_netops to manage alarms in compartment ${lower("${local.service_name}_network_compartment")}",
      "Allow group ${local.service_name}_netops to manage metrics in compartment ${lower("${local.service_name}_network_compartment")}",
      "Allow group ${local.service_name}_netops to manage orm-stacks in compartment ${lower("${local.service_name}_network_compartment")}",
      "Allow group ${local.service_name}_netops to manage orm-jobs in compartment ${lower("${local.service_name}_network_compartment")}",
      "Allow group ${local.service_name}_netops to manage orm-config-source-providers in compartment ${lower("${local.service_name}_network_compartment")}",
      "Allow Group ${local.service_name}_netops to read audit-events in compartment ${lower("${local.service_name}_network_compartment")}",
      "Allow Group ${local.service_name}_netops to read vss-family in compartment ${lower("${local.service_name}_network_compartment")}"
    ]
  }
}
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
    compartment_id = module.network_section.compartment_id
    bundle_type    = module.compose.bundle_id
    freeform_tags  = { 
      code_source  = var.code_source
    }
  }
  network = {
    address_spaces       = module.compose.address_spaces
    subnet_list          = module.compose.subnets
    create_drg           = true
    block_nat_traffic    = false
    # Alternative: "oci-${module.compose.location_key}-objectstorage"
    service_gateway_cidr = "all-${module.compose.location_key}-services-in-oracle-services-network" 
  }
}
// --- service segment --- //

// --- presentation tier --- //
module "presentation_domain" {
  source           = "./component/network_domain/"
  providers        = { oci = oci.home }
  depends_on       = [ module.network_section, module.service_segment ]
  config  = {
    service_id     = local.service_id
    vcn_id         = module.service_segment.vcn_id
    anywhere       = module.service_segment.anywhere
    bundle_type    = module.compose.bundle_id
    defined_tags   = null
    freeform_tags  = { 
      "source"     = var.code_source
    }
  }
  subnet  = {
    # Select a domain name from subnet map in the service segment
    domain                      = "pres"
    cidr_block                  = lookup(module.service_segment.subnets, "pres", "This CIDR is not defined") 
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
// --- presentation tier --- //