// Copyright (c) 2017, 2020, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0

/*
resource "oci_bastion_session" "managed_ssh" {
  depends_on = [
    oci_core_instance.ocloud
  ]
  bastion_id                                   = var.ssh.bastion_id
  key_details {
    public_key_content                         = tls_private_key.ocloud.public_key_openssh
  }
  target_resource_details {
    session_type                               = "MANAGED_SSH"
    target_resource_id                         = oci_core_instance.ocloud[0].id
    target_resource_operating_system_user_name = "opc"
    target_resource_port                       = var.ssh.target_port
    target_resource_private_ip_address         = oci_core_instance.ocloud[0].private_ip
  }

  display_name                                 = var.ssh.display_name
  key_type                                     = "PUB"
  session_ttl_in_seconds                       = var.ssh.ttl_in_seconds
}
*/

resource "oci_bastion_session" "port_forwarding" {
  depends_on = [
    oci_core_instance.ocloud
  ]
  bastion_id                                   = var.ssh.bastion_id
  key_details {
    public_key_content                         = tls_private_key.ocloud.public_key_openssh
  }
  target_resource_details {
    session_type                               = "PORT_FORWARDING"
    target_resource_id                         = oci_core_instance.ocloud[0].id
    target_resource_port                       = var.ssh.target_port
    target_resource_private_ip_address         = oci_core_instance.ocloud[0].private_ip
  }

  display_name                                 = var.ssh.display_name
  key_type                                     = "PUB"
  session_ttl_in_seconds                       = var.ssh.ttl_in_seconds
}
