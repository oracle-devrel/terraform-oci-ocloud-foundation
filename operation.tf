# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- service operation --- //
variable "operation" {
  default     = "Operation"
  type        = string
  description = "Identify the Section, use a unique name"
  validation {
    condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,14}$", var.operation)) > 0
    error_message = "The service_name variable is required and must contain alphanumeric characters only, start with a letter, have at least consonants and contains up to 15 letters."
  }
}
module "operation_section" {
  depends_on = [ oci_identity_compartment.init ]
  source         = "./component/admin_section/"
  providers      = { oci = oci.home }
  config = {
    tenancy_id    = var.tenancy_ocid
    source        = var.source_url
    display_name  = lower("${local.service_name}_${var.operation}")
    freeform_tags = { 
      "framework" = "ocloud"
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
output "ops_compartment_id"    { value = module.operation_section.compartment_id }
output "ops_compartment_name"  { value = module.operation_section.compartment_name }
output "ops_compartment_roles" { value = module.operation_section.roles }
// --- service operation --- //