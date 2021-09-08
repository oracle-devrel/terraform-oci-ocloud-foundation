# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_bastion_bastion" "domain" {
  depends_on                   = [oci_core_subnet.domain]
  count                        = var.bastion.create ? 1 : 0
  bastion_type                 = "STANDARD"
  name                         = "${var.config.dns_label}bastion"
  compartment_id               = data.oci_identity_compartment.domain.id
  target_subnet_id             = oci_core_subnet.domain.id
  max_session_ttl_in_seconds   = var.bastion.max_session_ttl
  client_cidr_block_allow_list = var.bastion.client_allow_cidr
  defined_tags                 = var.config.defined_tags
  freeform_tags                = var.config.freeform_tags
}

/*
resource "oci_core_service_gateway" "domain" {
  compartment_id = var.bastion.compartment_id
  display_name   = "${var.config.display_name}_bastion_gateway"

  services {
    service_id = data.oci_core_services.ocloud.services[1]["id"]
  }

  vcn_id = var.config.vcn.id
}

resource "oci_core_default_route_table" "domain" {
  manage_default_resource_id = var.config.vcn.id
  display_name               = "BSTN_${var.config.display_name}_route_table"

  route_rules {
    destination       = lookup(data.oci_core_services.ocloud.services[1], "cidr_block")
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.domain.id
  }
}
*/