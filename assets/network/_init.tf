# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- terraform provider --- 
terraform {
    required_providers {
        oci = {
            source = "hashicorp/oci"
        }
    }
}

data "oci_core_services" "all" {
    filter {
        name   = "name"
        values = ["All .* Services In Oracle Services Network"]
        regex  = true
    }
}

data "oci_core_services" "storage" {
    filter {
        name   = "name"
        values = ["OCI .* Object Storage"]
        regex  = true
    }
}

data "oci_identity_compartments" "network" {
    compartment_id = var.tenancy.id
    access_level   = "ANY"
    compartment_id_in_subtree = true
    name           = try(var.network.compartment, var.service.name)
    state          = "ACTIVE"
}

data "oci_core_drgs" "segment" {
    depends_on = [oci_core_drg.segment]
    count          = var.network.gateways.drg.create == true ? 1 : 0
    compartment_id = data.oci_identity_compartments.network.compartments[0].id
}

data "oci_core_internet_gateways" "segment" {
    depends_on = [oci_core_internet_gateway.segment]
    count          = var.network.gateways.internet.create == true ? 1 : 0
    compartment_id = data.oci_identity_compartments.network.compartments[0].id
    display_name   = var.network.gateways.internet.name
    state          = "AVAILABLE"
    vcn_id         = oci_core_vcn.segment.id
}

data "oci_core_nat_gateways" "segment" {
    depends_on = [oci_core_nat_gateway.segment]
    count          = var.network.gateways.nat.create == true ? 1 : 0
    compartment_id = data.oci_identity_compartments.network.compartments[0].id
    display_name   = var.network.gateways.nat.name
    state          = "AVAILABLE"
    vcn_id         = oci_core_vcn.segment.id
}

data "oci_core_service_gateways" "segment" {
    depends_on = [oci_core_service_gateway.segment]
    count          = var.network.gateways.osn.create == true ? 1 : 0
    compartment_id = data.oci_identity_compartments.network.compartments[0].id
    state          = "AVAILABLE"
    vcn_id         = oci_core_vcn.segment.id
}

data "oci_core_route_tables" "default_route_table" {
    depends_on     = [oci_core_vcn.segment]
    compartment_id = data.oci_identity_compartments.network.compartments[0].id
    display_name   = "Default Route Table for organization_service_dev_1" 
    state          = "AVAILABLE"
    vcn_id         = oci_core_vcn.segment.id
}

data "oci_core_security_lists" "default_security_list" {
    depends_on     = [oci_core_vcn.segment]
    compartment_id = data.oci_identity_compartments.network.compartments[0].id
    display_name   = "Default Security List for organization_service_dev_1"
    state          = "AVAILABLE"
    vcn_id         = oci_core_vcn.segment.id
}


locals {
    gateways = zipmap(
        compact([
            length(data.oci_core_drgs.segment) > 0 ? data.oci_core_drgs.segment[0].drgs[0].display_name : null,
            length(data.oci_core_internet_gateways.segment) > 0 ? data.oci_core_internet_gateways.segment[0].gateways[0].display_name : null,
            length(data.oci_core_nat_gateways.segment) > 0 ? data.oci_core_nat_gateways.segment[0].nat_gateways[0].display_name : null,
            length(data.oci_core_service_gateways.segment) > 0 ? data.oci_core_service_gateways.segment[0].service_gateways[0].display_name : null
        ]),
        compact([
            length(data.oci_core_drgs.segment) > 0 ? data.oci_core_drgs.segment[0].drgs[0].id : null,
            length(data.oci_core_internet_gateways.segment) > 0 ? data.oci_core_internet_gateways.segment[0].gateways[0].id : null,
            length(data.oci_core_nat_gateways.segment) > 0 ? data.oci_core_nat_gateways.segment[0].nat_gateways[0].id : null,
            length(data.oci_core_service_gateways.segment) > 0 ? data.oci_core_service_gateways.segment[0].service_gateways[0].id : null
        ])
    )
    osn_ids = {
        "all"     = lookup(data.oci_core_services.all.services[0], "id")
        "storage" = lookup(data.oci_core_services.storage.services[0], "id")
    }
    osn_cidrs = {
        "all"     = lookup(data.oci_core_services.all.services[0], "cidr_block")
        "storage" = lookup(data.oci_core_services.storage.services[0], "cidr_block")
    }
}

/*
locals {

    subnet_cidrs = zipmap(
        keys(module.settings.vcns[var.network.name].security_lists),
        [ for list in module.settings.vcns[var.network.name].security_lists : {
            for subnet in list.subnets : 
            subnet => lookup(module.settings.vcns[var.network.name].cidrs, subnet, "") 
        }]
    )
    # Create a map of cidr for all services in the Oracle Services Netwqork (OSN)
    #osn_cidrs        = { for service in data.oci_core_services.all[0].services : service.cidr_block => service.id }


    ingress_filter {
        application = [ local.allowing["ingress"] ]
    }
    connections = {
        cloud    = var.vcn.drg.vcn
        anywhere = var.vcn.drg.anywhere
        onprem   = var.vcn.drg.cpe
    }
    allow = {
        ingress = { for zone in local.security_zones : "${zone}_ingress" => var.vcn.security_lists[zone].ingress... }
        egress =  { for zone in local.security_zones : "${zone}_egress"  => var.vcn.security_lists[zone].egress...  }
    }
    security_zones = keys(var.vcn.security_lists)
}
*/

// Define the wait state for the data requests
resource "null_resource" "previous" {}

// This resource will destroy (potentially immediately) after null_resource.next
resource "time_sleep" "wait" {
    depends_on = [null_resource.previous]
    create_duration = "2m"
}