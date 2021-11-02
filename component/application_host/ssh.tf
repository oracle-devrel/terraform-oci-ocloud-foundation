# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

resource "oci_bastion_session" "ssh" {
  depends_on                                   = [ oci_core_instance.host ]
  count                                        = var.ssh.enable == true ? 1 : 0
  bastion_id                                   = var.config.bastion_id
  key_details {
    public_key_content                         = oci_core_instance.host[0].metadata.ssh_authorized_keys
  }
  target_resource_details {
    session_type                               = var.ssh.type
    target_resource_id                         = oci_core_instance.host[0].id
    target_resource_operating_system_user_name = "opc"
    target_resource_port                       = var.ssh.target_port
    target_resource_private_ip_address         = oci_core_instance.host[0].private_ip
  }
  display_name                                 = "${local.display_name}_ssh"
  key_type                                     = "PUB"
  session_ttl_in_seconds                       = var.ssh.ttl_in_seconds
}