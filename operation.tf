# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- admin section ---
module "ops_section" {
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
    name          = "${local.service_label}_operation_compartment"
  }
  roles = {
    cloudops  = [
        "ALLOW GROUP cloudops to read users IN TENANCY",
        "ALLOW GROUP cloudops to read groups IN TENANCY",
        "ALLOW GROUP cloudops to manage users IN TENANCY",
        "ALLOW GROUP cloudops to manage groups IN TENANCY where target.group.name = 'Administrators'",
        "ALLOW GROUP cloudops to manage groups IN TENANCY where target.group.name = 'secops'",
    ]
    secops = [
        "ALLOW GROUP secops to manage security-lists IN TENANCY",
        "ALLOW GROUP secops to manage internet-gateways IN TENANCY",
        "ALLOW GROUP secops to manage cpes IN TENANCY",
        "ALLOW GROUP secops to manage ipsec-connections IN TENANCY",
        "ALLOW GROUP secops to use virtual-network-family IN TENANCY",
        "ALLOW GROUP secops to manage load-balancers IN TENANCY",
        "ALLOW GROUP secops to read all-resources IN TENANCY",
    ]
    iam   = [
        "ALLOW GROUP iam to read users IN TENANCY",
        "ALLOW GROUP iam to read groups IN TENANCY",
        "ALLOW GROUP iam to manage users IN TENANCY",
        "ALLOW GROUP iam to manage groups IN TENANCY where all {target.group.name ! = 'Administrators', target.group.name ! = 'secops'}",
    ]
    audit   = [
        "ALLOW GROUP README to read all-resources IN TENANCY",
    ]
  }
}

output "ops_compartment" { value = module.ops_section.compartment }
output "ops_roles"       { value = module.ops_section.roles }