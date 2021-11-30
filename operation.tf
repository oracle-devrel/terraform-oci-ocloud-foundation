# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- service operation --- //
module "operation_section" {
  depends_on   = [ oci_identity_compartment.service ]
  source       = "./component/admin_section/"
  providers    = { oci = oci.home }
  section_name = "operation"
  config = {
    service_id    = local.service_id
    bundle_type   = module.compose.bundle_id
    tagspace      = [ ]
    freeform_tags = { 
      "source"    = var.code_source
    }
  }
  compartment  = {
    # Enable compartment delete on destroy. If true, compartment will be deleted when terraform destroy is executed
    enable_delete = true
    parent        = local.service_id
  }

  roles = {
    "${local.service_name}_administrator"  = [
      "ALLOW GROUP ${local.service_name}_administrator to read users in compartment ${local.service_name}",
      "ALLOW GROUP ${local.service_name}_administrator to read groups in compartment ${local.service_name}",
      "ALLOW GROUP ${local.service_name}_administrator to manage users in compartment ${local.service_name}",
      "ALLOW GROUP ${local.service_name}_administrator to manage groups in compartment ${local.service_name} where target.group.name = '${local.service_name}_administrator'",
      "ALLOW GROUP ${local.service_name}_administrator to manage groups in compartment ${local.service_name} where target.group.name = '${local.service_name}_secops'",
    ]
    "${local.service_name}_audit"   = [
      "ALLOW GROUP ${local.service_name}_audit to read all-resources in compartment ${local.service_name}",
    ]
    "${local.service_name}_secops" = [
      "ALLOW GROUP ${local.service_name}_secops to manage security-lists in compartment ${local.service_name}",
      "ALLOW GROUP ${local.service_name}_secops to manage internet-gateways in compartment ${local.service_name}",
      "ALLOW GROUP ${local.service_name}_secops to manage cpes in compartment ${local.service_name}",
      "ALLOW GROUP ${local.service_name}_secops to manage ipsec-connections in compartment ${local.service_name}",
      "ALLOW GROUP ${local.service_name}_secops to use virtual-network-family in compartment ${local.service_name}",
      "ALLOW GROUP ${local.service_name}_secops to manage load-balancers in compartment ${local.service_name}",
      "ALLOW GROUP ${local.service_name}_secops to read all-resources in compartment ${local.service_name}",
    ]
    "${local.service_name}_iam" = [
      "ALLOW GROUP ${local.service_name}_iam to read users in compartment ${local.service_name}",
      "ALLOW GROUP ${local.service_name}_iam to read groups in compartment ${local.service_name}",
      "ALLOW GROUP ${local.service_name}_iam to manage users in compartment ${local.service_name}",
      "ALLOW GROUP ${local.service_name}_iam to manage groups in compartment ${local.service_name} where all {target.group.name ! = '${local.service_name}_secops', target.group.name ! = '${local.service_name}_secops'}",
    ]
  }
}
// --- service operation --- //