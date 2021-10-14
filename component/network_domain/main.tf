# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_subnet" "domain" {
  depends_on = [oci_core_security_list.domain]
  compartment_id              = data.oci_identity_compartments.domain.compartments[0].id
  vcn_id                      = data.oci_core_vcn.domain.id
  display_name                = local.display_name
  dns_label                   = local.dns_label
  cidr_block                  = var.subnet.cidr_block
  prohibit_public_ip_on_vnic  = var.subnet.prohibit_public_ip_on_vnic
  dhcp_options_id             = var.subnet.dhcp_options_id
  defined_tags                = null
  freeform_tags               = var.config.freeform_tags
  security_list_ids           = [oci_core_security_list.domain.id]
}

resource "oci_bastion_bastion" "domain" {
  depends_on                   = [oci_core_subnet.domain]
  count                        = var.bastion.create ? 1 : 0
  bastion_type                 = "STANDARD"
  name                         = local.bastion_label
  compartment_id               = data.oci_identity_compartments.domain.compartments[0].id
  target_subnet_id             = oci_core_subnet.domain.id
  max_session_ttl_in_seconds   = var.bastion.max_session_ttl
  client_cidr_block_allow_list = var.bastion.client_allow_cidr
  defined_tags                 = null
  freeform_tags                = var.config.freeform_tags
}

resource "oci_core_route_table_attachment" "domain" {
  depends_on     = [oci_core_subnet.domain]
  subnet_id      = oci_core_subnet.domain.id
  route_table_id = var.subnet.route_table_id
}

resource "oci_core_security_list" "domain" {
  compartment_id = data.oci_identity_compartments.domain.compartments[0].id
  vcn_id         = data.oci_core_vcn.domain.id
  display_name   = "${local.display_name}_security_list"

  // allow outbound tcp traffic
  egress_security_rules {
    protocol    = "6" // tcp
    destination = data.oci_core_vcn.domain.cidr_blocks[0]
    stateless   = false
    description = "allow outgoing tcp traffic"
  }

  egress_security_rules {
    protocol         = "6" // tcp
    destination      = data.oci_core_services.all_services.services[1].cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"
    stateless        = false
    description      = "allow outgoing tcp traffic"
  }
    
  // allow inbound icmp traffic of a specific type
  ingress_security_rules {
    description = "allow outgoing icmp traffic"
    protocol    = 1
    source      = var.config.anywhere
    stateless   = false

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    description = "allow internal icmp traffic"
    protocol    = 1
    source      = "10.0.0.0/8"
    stateless   = false
  }

  ingress_security_rules {
    description = "allow internal icmp traffic"
    protocol    = 1
    source      = "172.16.0.0/12"
    stateless   = false
  }

  ingress_security_rules {
    description = "allow internal icmp traffic"
    protocol    = 1
    source      = "192.168.0.0/16"
    stateless   = false
  }

  // allow inbound tcp traffic
  dynamic "ingress_security_rules" {
    for_each = var.tcp_ports.ingress
    content {
      protocol    = "6" // tcp
      source      = ingress_security_rules.value[1]
      stateless   = false
      description = "allow incoming ${ingress_security_rules.value[0]} traffic"
      
      tcp_options {
        min  = ingress_security_rules.value[2]
        max  = ingress_security_rules.value[3]
      }
    }
  }
}