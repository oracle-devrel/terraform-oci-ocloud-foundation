// Copyright (c) 2017, 2020, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0

resource "oci_bastion_session" "ssh" {
  depends_on                                   = [ oci_core_instance.instance[0] ]
  count                                        = var.session.enable ? 1 : 0
  bastion_id                                   = data.oci_bastion_bastion.host.id
  key_details {
    public_key_content                         = oci_core_instance.instance[0].metadata.ssh_authorized_keys
  }
  target_resource_details {
    session_type                               = var.session.type
    target_resource_id                         = oci_core_instance.instance[0].id
    target_resource_operating_system_user_name = "opc"
    target_resource_port                       = var.session.target_port
    target_resource_private_ip_address         = oci_core_instance.instance[0].private_ip
  }
  display_name                                 = "${var.config.display_name}_ssh"
  key_type                                     = "PUB"
  session_ttl_in_seconds                       = var.session.ttl_in_seconds
}