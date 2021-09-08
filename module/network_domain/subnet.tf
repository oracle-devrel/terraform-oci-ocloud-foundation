# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_subnet" "ocloud" {
  compartment_id              = var.config.compartment_id
  vcn_id                      = var.config.vcn_id
  display_name                = var.config.display_name
  dns_label                   = var.config.dns_label
  cidr_block                  = cidrsubnet(var.subnet.cidr_block, var.subnet.new_bits, 0)
  prohibit_public_ip_on_vnic  = var.subnet.prohibit_public_ip_on_vnic
  dhcp_options_id             = var.subnet.dhcp_options_id
  defined_tags                = var.config.defined_tags
  freeform_tags               = var.config.freeform_tags
  security_list_ids           = [oci_core_security_list.ocloud.id]
}

resource "oci_core_route_table_attachment" "ocloud" {  
  subnet_id      = oci_core_subnet.ocloud.id
  route_table_id = var.subnet.route_table_id
}

resource "oci_core_security_list" "ocloud" {
  compartment_id = var.config.compartment_id
  vcn_id         = var.config.vcn_id
  display_name   = "Default port filter for ${var.config.display_name} domain with range ${var.subnet.cidr_block}"

    // allow outbound tcp traffic
  egress_security_rules {
    protocol    = "6" // tcp
    destination = var.config.vcn_cidr
    stateless   = false
    description = "allow outgoing tcp traffic"
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
