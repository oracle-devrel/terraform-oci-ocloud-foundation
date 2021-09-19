# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- admin sections ---
module "main_section" {
  source         = "./component/admin_section/"
  providers      = { oci = oci.home }
  config = {
    tenancy_id    = var.tenancy_ocid
    base          = var.base_url
    defined_tags  = null
    freeform_tags = {"framework"= "ocloud"}
  }
  compartment  = {
    enable_delete = false #Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed
    parent        = var.tenancy_ocid
    name          = "${local.service_name}_compartment"
  }
  roles = {
    "${local.service_name}_administrator"  = [
        "ALLOW GROUP ${local.service_name}_administrator to read users IN TENANCY",
        "ALLOW GROUP ${local.service_name}_administrator to read groups IN TENANCY",
        "ALLOW GROUP ${local.service_name}_administrator to manage users IN TENANCY",
        "ALLOW GROUP ${local.service_name}_administrator to manage groups IN TENANCY where target.group.name = '${local.service_name}_administrator'",
        "ALLOW GROUP ${local.service_name}_administrator to manage groups IN TENANCY where target.group.name = '${local.service_name}_secops'",
    ]
    "${local.service_name}_audit"   = [
        "ALLOW GROUP ${local.service_name}_audit to read all-resources IN TENANCY",
    ]
  }
}

module "ops_section" {
  source         = "./component/admin_section/"
  providers      = { oci = oci.home }
  depends_on = [ module.main_section, ]
  config = {
    tenancy_id    = var.tenancy_ocid
    base          = var.base_url
    defined_tags  = null
    freeform_tags = {"framework"= "ocloud"}
  }
  compartment  = {
    enable_delete = false #Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed
    parent        = data.oci_identity_compartment.main.id
    name          = "${local.service_name}_operation_compartment"
  }
  roles = {
    "${local.service_name}_secops" = [
        "ALLOW GROUP ${local.service_name}_secops to manage security-lists IN TENANCY",
        "ALLOW GROUP ${local.service_name}_secops to manage internet-gateways IN TENANCY",
        "ALLOW GROUP ${local.service_name}_secops to manage cpes IN TENANCY",
        "ALLOW GROUP ${local.service_name}_secops to manage ipsec-connections IN TENANCY",
        "ALLOW GROUP ${local.service_name}_secops to use virtual-network-family IN TENANCY",
        "ALLOW GROUP ${local.service_name}_secops to manage load-balancers IN TENANCY",
        "ALLOW GROUP ${local.service_name}_secops to read all-resources IN TENANCY",
    ]
    "${local.service_name}_iam" = [
        "ALLOW GROUP ${local.service_name}_iam to read users IN TENANCY",
        "ALLOW GROUP ${local.service_name}_iam to read groups IN TENANCY",
        "ALLOW GROUP ${local.service_name}_iam to manage users IN TENANCY",
        "ALLOW GROUP ${local.service_name}_iam to manage groups IN TENANCY where all {target.group.name ! = '${local.service_name}_secops', target.group.name ! = '${local.service_name}_secops'}",
    ]
  }
}

// --- sections output ---
output "main_compartment" { value = module.main_section.compartment }
output "main_roles"       { value = module.main_section.roles }
output "ops_compartment"  { value = module.ops_section.compartment }
output "ops_roles"        { value = module.ops_section.roles }