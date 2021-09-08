# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_bastion_bastion" "ocloud" {
  bastion_type                 = "STANDARD"
  compartment_id               = var.bastion.compartment_id
  target_subnet_id             = oci_core_subnet.ocloud.id
  client_cidr_block_allow_list = var.bastion.client_allow_cidr
  defined_tags                 = var.config.defined_tags
  name                         = "bstn${var.config.dns_label}"
  freeform_tags                = var.config.freeform_tags
  max_session_ttl_in_seconds   = var.bastion.max_session_ttl
}

/*
resource "oci_core_service_gateway" "bastion_gateway" {
  compartment_id = var.bastion.compartment_id
  display_name   = "BSTN_${var.config.display_name}_Gateway"

  services {
    service_id = data.oci_core_services.ocloud.services[1]["id"]
  }

  vcn_id = var.config.vcn_id
}

resource "oci_core_default_route_table" "bastion_route_table" {
  manage_default_resource_id = var.config.vcn_id
  display_name               = "BSTN_${var.config.display_name}_Route_Table"

  route_rules {
    destination       = lookup(data.oci_core_services.ocloud.services[1], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.bastion_gateway.id
  }
}
*/