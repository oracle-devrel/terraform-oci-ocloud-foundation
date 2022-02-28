# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

## Modify the default security list for the VCN
resource "oci_core_default_security_list" "default_security_list" {
    manage_default_resource_id = oci_core_vcn.segment.default_security_list_id
    egress_security_rules {
        protocol         = "6" // tcp
        destination      = "all-${lower(var.resident.region.key)}-services-in-oracle-services-network"
        destination_type = "SERVICE_CIDR_BLOCK"
        stateless        = false
        description      = "allow outgoing tcp traffic"
    }
    ingress_security_rules {
        protocol  = "1"
        stateless = false
        source    = var.network.cidr
        icmp_options {
            type = 3
            code = 4
        }
    }
    ingress_security_rules {
        protocol  = "1"
        stateless = false
        source    = var.network.gateways.drg.anywhere
        icmp_options {
            type = 3
            code = null
        }
    }
}

resource "oci_core_security_list" "segment" {
    compartment_id = data.oci_identity_compartments.network.compartments[0].id
    vcn_id         = oci_core_vcn.segment.id
    for_each       = var.network.security_lists
    display_name   = each.value.display_name

    // allow outbound tcp traffic to other internal segments
    egress_security_rules {
        protocol    = "6" // tcp
        destination = oci_core_vcn.segment.cidr_blocks[0]
        stateless   = false
        description = "allow outgoing tcp traffic to vcn"
    }
    // allow outbound tcp traffic to oracle service network
    egress_security_rules {
        protocol         = "6" // tcp
        destination      = "all-${lower(var.resident.region.key)}-services-in-oracle-services-network"
        destination_type = "SERVICE_CIDR_BLOCK"
        stateless        = false
        description      = "allow outgoing tcp traffic to osn"
    }
    
    // allow inbound icmp traffic
    ingress_security_rules {
        protocol    = 1
        source      = var.network.gateways.drg.anywhere
        stateless   = false
        description = "allow internal icmp traffic"
        icmp_options {
            type = 3
            code = 4
        }
    }
    // allow inbound tcp traffic from other internal segments
    ingress_security_rules {
        protocol    = 1
        source      = "10.0.0.0/8"
        stateless   = false
        description = "allow internal icmp traffic"
    }
    // allow inbound tcp traffic from oracle service segments
    ingress_security_rules {
        protocol    = 1
        source      = "172.16.0.0/12"
        stateless   = false
        description = "allow internal icmp traffic"
    }

    ingress_security_rules {
        protocol    = 1
        source      = "192.168.0.0/16"
        stateless   = false
        description = "allow internal icmp traffic"
    }

    // allow defined inbound tcp traffic
    dynamic "ingress_security_rules" {
        for_each = [for profile in each.value.ingress: {
            protocol    = profile.protocol
            source      = profile.source
            stateless   = profile.stateless
            description = profile.description
            min_port    = profile.min_port
            max_port    = profile.max_port
        }]
        content {
            protocol    = ingress_security_rules.value.protocol
            source      = ingress_security_rules.value.source
            stateless   = ingress_security_rules.value.stateless
            description = ingress_security_rules.value.description
            tcp_options {
                min  = ingress_security_rules.value.min_port
                max  = ingress_security_rules.value.max_port
            }
        }
    }
}

/*
## Create default security groups
resource "oci_core_network_security_group" "segment" {
    depends_on     = [ oci_core_vcn.segment ]
    count          = length(var.network.security_groups)
    compartment_id = data.oci_identity_compartments.network.compartments[0].id
    display_name   = var.network.security_groups[count.index]
    vcn_id         = oci_core_vcn.segment.id
    defined_tags   = local.defined_tags
    freeform_tags  = local.freeform_tags
}
*/