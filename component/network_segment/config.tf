# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_core_services"        "all_services" { }                                # Request a list of Oracle Service Network (osn) services
data "oci_identity_compartment" "segment"      { id = var.config.compartment_id } # Retrieve meta data for the target compartment

locals {
    ## Retrieve CIDR for all Oracle Services
    osn_cidrs        = {for svc in data.oci_core_services.all_services.services : svc.cidr_block => svc.id} # Create a map of cidr for osn 
    ## Create a map from network names to allocated address prefixes in CIDR notation
    subnet_ranges    = cidrsubnets(var.vcn.address_spaces.cidr_block, values(var.vcn.subnet_list)...)
    subnet_names     = keys(var.vcn.subnet_list)
    subnet_map       = zipmap(local.subnet_names, local.subnet_ranges)
    ## Define route sets as input for the network segment
    public_rule_set  = [local.anywhere_route]
    private_rule_set = [local.nat_route, local.osn_route]
    osn_rule_set     = [local.osn_route]
    cpe_rule_set     = [local.interconnect]    #Route traffic to the onprem data center 
    ## Create route rules objects as input for the route tables
    nat_route = {
        network_entity_id = data.oci_core_nat_gateways.segment.nat_gateways[0].id
        description       = "Route traffic via NAT to the public internet"
        destination       = var.vcn.address_spaces.anywhere
        destination_type  = "CIDR_BLOCK"
    }
    anywhere_route = {
        network_entity_id = data.oci_core_internet_gateways.segment.gateways[0].id
        description       = "Route traffic to the public internet"
        destination       = var.vcn.address_spaces.anywhere
        destination_type  = "CIDR_BLOCK"
    }
    objectstorage_route  = {
        network_entity_id = data.oci_core_service_gateways.segment.service_gateways[0].id
        description       = "Route traffic to the Object Store"
        destination       = data.oci_core_services.all_services.services[0].cidr_block
        destination_type  = "SERVICE_CIDR_BLOCK"
    }
    osn_route = {
        network_entity_id = data.oci_core_service_gateways.segment.service_gateways[0].id
        description       = "Route traffic to private Oracle Services"
        destination       = data.oci_core_services.all_services.services[1].cidr_block
        destination_type  = "SERVICE_CIDR_BLOCK"
    }
    interconnect = {
        network_entity_id = data.oci_core_drgs.segment.drgs[0].id
        description       = "Route traffic to the onprem data center"
        destination       = var.vcn.address_spaces.interconnect
        destination_type  = "CIDR_BLOCK"
    }
}