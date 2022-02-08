# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.
# readme.md created with https://terraform-docs.io/: terraform-docs markdown --sort=false ./ > ./readme.md

// --- Terraform provider --- //
terraform {
    required_providers {
        oci = {
            source = "hashicorp/oci"
        }
    }
}
provider "oci" { 
    alias = "init"
}
provider "oci" {
    alias  = "home"
    region = module.configuration.tenancy.region.key
}
// --- Terraform provider --- //

// --- service configuration --- //
variable "tenancy_ocid" { }

module "configuration" {
    source         = "./configuration/"
    input = {
        tenancy      = var.tenancy_ocid
        class        = var.class
        owner        = var.owner
        organization = var.organization
        solution     = var.solution
        repository   = var.repository
        stage        = var.stage
        region       = var.region
        domains      = var.domains
        segments     = var.segments
    }
}
output "tenancy"   {
    value = module.configuration.tenancy
    description = "Static parameters for the tenancy configuration"
}
output "service"  {
    value = module.configuration.service
    description = "Static parameters for the service configuration"
}
// --- service configuration  --- //

// --- operation controls --- //
module "resident" {
    source     = "./assets/resident/"
    depends_on = [
        module.configuration
    ]
    providers = {oci = oci.init}
    tenancy   = module.configuration.tenancy
    service   = module.configuration.service
    resident  = module.configuration.resident
    input = {
        # Reference to the deployment root. The service is setup in an encapsulating child compartment 
        parent_id     = var.tenancy_ocid
        # Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed; If false, compartment will not be deleted on `terraform destroy` execution
        enable_delete = var.stage != "PROD" ? true : false
    }
}
output "resident" {
    value = {
        for resource, parameter in module.resident : resource => parameter
    }
}
// --- operation controls --- //

// --- network topology --- //
module "network" {
    source     = "./assets/network/"
    depends_on = [ 
        module.configuration, 
        module.resident
    ]
    providers = { oci = oci.home }
    tenancy   = module.configuration.tenancy
    service   = module.configuration.service
    resident  = module.configuration.resident
    for_each  = {for segment in var.segments : segment.name => segment}
    network   = module.configuration.network[each.key]
    input = {
        resident = module.resident
    }
}
output "network" {
    value = {
        for resource, parameter in module.network : resource => parameter
    }
}
// --- network topology --- //


/*/ --- application host --- //
module "operator" {
    source     = "./assets/application_host/"
    providers  = { oci = oci.home }
    depends_on = [ module.application_domain, module.service_segment, module.application_domain ]
    host_name  = "operator"
    config     = {
        service_id     = local.service_id
        compartment_id = module.application_domain.compartment_id
        deployment_type    = module.configuration.bundles[var.bundle]
        subnet_ids     = [ module.application_domain.subnet_id ]
        bastion_id     = module.application_domain.bastion_id
        ad_number      = 1
        defined_tags   = null
        freeform_tags  = { 
            code_source  = var.code_source
        }
    }
    host = {
        shape = "small"
        image = "linux"
        disk  = "san"
        nic   = "private"
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
// --- application host --- /*/