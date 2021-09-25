# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- admin sections ---
module "main_section" {
  source         = "./component/admin_section/"
  providers      = { oci = oci.home }
  config = {
    tenancy_id    = var.tenancy_ocid
    source        = var.source_url
    mail          = var.admin_mail
    slack         = var.slack_channel
    display_name  = "${local.service_name}"
    dns_label     = "${local.service_label}"
    defined_tags  = null
    freeform_tags = {"framework"= "ocloud"}
  }
  compartment  = {
    enable_delete = false #Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed
    parent        = var.tenancy_ocid
  }
  roles = {
    "${local.service_name}_administrator"  = [
        "ALLOW GROUP ${local.service_name}_administrator to read users in compartment ${data.oci_identity_compartment.main.name}",
        "ALLOW GROUP ${local.service_name}_administrator to read groups in compartment ${data.oci_identity_compartment.main.name}",
        "ALLOW GROUP ${local.service_name}_administrator to manage users in compartment ${data.oci_identity_compartment.main.name}",
        "ALLOW GROUP ${local.service_name}_administrator to manage groups in compartment ${data.oci_identity_compartment.main.name} where target.group.name = '${local.service_name}_administrator'",
        "ALLOW GROUP ${local.service_name}_administrator to manage groups in compartment ${data.oci_identity_compartment.main.name} where target.group.name = '${local.service_name}_secops'",
    ]
    "${local.service_name}_audit"   = [
        "ALLOW GROUP ${local.service_name}_audit to read all-resources in compartment ${data.oci_identity_compartment.main.name}",
    ]
  }
}

module "ops_section" {
  source         = "./component/admin_section/"
  providers      = { oci = oci.home }
  depends_on = [ module.main_section, ]
  config = {
    tenancy_id    = var.tenancy_ocid
    source        = var.source_url
    mail          = var.admin_mail
    slack         = var.slack_channel
    display_name  = "${local.service_name}_operation"
    dns_label     = "${local.service_label}ops"
    defined_tags  = null
    freeform_tags = {"framework"= "ocloud"}
  }
  compartment  = {
    enable_delete = false #Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed
    parent        = data.oci_identity_compartment.main.id
  }
  roles = {
    "${local.service_name}_secops" = [
        "ALLOW GROUP ${local.service_name}_secops to manage security-lists in compartment ${data.oci_identity_compartment.main.name}",
        "ALLOW GROUP ${local.service_name}_secops to manage internet-gateways in compartment ${data.oci_identity_compartment.main.name}",
        "ALLOW GROUP ${local.service_name}_secops to manage cpes in compartment ${data.oci_identity_compartment.main.name}",
        "ALLOW GROUP ${local.service_name}_secops to manage ipsec-connections in compartment ${data.oci_identity_compartment.main.name}",
        "ALLOW GROUP ${local.service_name}_secops to use virtual-network-family in compartment ${data.oci_identity_compartment.main.name}",
        "ALLOW GROUP ${local.service_name}_secops to manage load-balancers in compartment ${data.oci_identity_compartment.main.name}",
        "ALLOW GROUP ${local.service_name}_secops to read all-resources in compartment ${data.oci_identity_compartment.main.name}",
    ]
    "${local.service_name}_iam" = [
        "ALLOW GROUP ${local.service_name}_iam to read users in compartment ${data.oci_identity_compartment.main.name}",
        "ALLOW GROUP ${local.service_name}_iam to read groups in compartment ${data.oci_identity_compartment.main.name}",
        "ALLOW GROUP ${local.service_name}_iam to manage users in compartment ${data.oci_identity_compartment.main.name}",
        "ALLOW GROUP ${local.service_name}_iam to manage groups in compartment ${data.oci_identity_compartment.main.name} where all {target.group.name ! = '${local.service_name}_secops', target.group.name ! = '${local.service_name}_secops'}",
    ]
  }
}

// --- sections output ---
output "main_compartment"   { value = module.main_section.compartment }
output "main_roles"         { value = module.main_section.roles }
output "main_topic"         { value = module.main_section.notifications }
output "main_subscription"  { value = module.main_section.subscriptions }
output "ops_compartment"    { value = module.ops_section.compartment }
output "ops_roles"          { value = module.ops_section.roles }
output "ops_topic"          { value = module.ops_section.notifications }
output "ops_subscription"   { value = module.ops_section.subscriptions }