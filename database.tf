# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- admin section ---
module "db_section" {
  source = "./component/admin_section/"
  providers      = { oci = oci.home }
  depends_on = [
    module.ops_section,
    module.net_section
  ]
  config  = {
    tenancy_id    = var.tenancy_ocid
    base          = var.base_url
    defined_tags  = null
    freeform_tags = {"framework"= "ocloud"}
  }
  compartment  = {
    enable_delete = false #Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed
    parent        = module.main_section.compartment.id
    name          = "${local.service_name}_database_compartment"
  }
  roles = {
    "${local.service_name}_dbops"  = [
      "ALLOW GROUP ${local.service_name}_dbops manage database-family IN TENANCY",
      "ALLOW GROUP ${local.service_name}_dbops read all-resources IN TENANCY"
    ]
  }
}

// --- section output (optional) ---
output "db_compartment" { value = module.db_section.compartment }
output "db_roles"       { value = module.db_section.roles }

// --- network domain ---
module "db_domain" {
  source         = "./component/network_domain/"
  providers      = { oci = oci.home }
  depends_on = [
    module.db_section,
    module.segment_1
  ]
  config  = {
    tenancy_id     = var.tenancy_ocid
    compartment_id = module.db_section.compartment.id
    vcn_id         = module.segment_1.vcn.id
    anywhere       = module.segment_1.anywhere
    display_name   = "${local.service_name}_db_client"
    dns_label      = "${local.service_label}db"
    defined_tags   = null
    freeform_tags  = {"framework" = "ocloud"}
  }
  subnet  = {
    cidr_block                  = cidrsubnet(module.segment_1.subnets.db,1,0)
    prohibit_public_ip_on_vnic  = false
    dhcp_options_id             = null
    route_table_id              = module.segment_1.osn_route_table.id
  }
  bastion  = {
    create            = false # Determine whether a bastion service will be deployed and attached
    client_allow_cidr = [ module.segment_1.anywhere ]
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

// --- db domain output ---
output "db_domain_subnet"        { value = module.db_domain.subnet }
output "db_domain_security_list" { value = module.db_domain.seclist }
output "db_domain_bastion"       { value = module.db_domain.bastion }