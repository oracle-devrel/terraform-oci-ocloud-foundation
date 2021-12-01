# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

resource "oci_core_instance" "host" {
  count = module.host_settings.shape.count
  // If no explicit AD number, spread instances on all ADs in round-robin. Looping to the first when last AD is reached
  availability_domain  = var.config.ad_number == null ? element(local.ADs, count.index) : element(local.ADs, var.config.ad_number - 1)
  compartment_id       = var.config.compartment_id
  display_name         = local.display_name == "" ? "" : module.host_settings.shape.count != "1" ? "${local.display_name}_${count.index + 1}" : local.display_name
  extended_metadata    = module.host_settings.image.extended_metadata
  ipxe_script          = module.host_settings.nic.ipxe_script
  preserve_boot_volume = module.host_settings.disk.preserve_boot_volume
  shape                = module.host_settings.shape.shape
  agent_config {
    are_all_plugins_disabled = false
    is_management_disabled   = false
    is_monitoring_disabled   = false
    plugins_config  {
      desired_state = "ENABLED"
      name          = "Bastion"
    }
  }
  shape_config {
    // If shape name contains ".Flex" and instance_flex inputs are not null, use instance_flex inputs values for shape_config block
    // Else use values from data.oci_core_shapes.ad1 for var.instance.shape
    memory_in_gbs = local.shape_is_flex == true && module.host_settings.shape.flex_memory_in_gbs != null ? module.host_settings.shape.flex_memory_in_gbs : local.shapes_config[module.host_settings.shape.shape]["memory_in_gbs"]
    ocpus         = local.shape_is_flex == true && module.host_settings.shape.flex_ocpus != null ? module.host_settings.shape.flex_ocpus : local.shapes_config[module.host_settings.shape.shape]["ocpus"]
  }
  create_vnic_details {
    assign_public_ip = module.host_settings.nic.assign_public_ip
    display_name     = module.host_settings.nic.vnic_name == "" ? "" : module.host_settings.shape.count != "1" ? "${module.host_settings.nic.vnic_name}_${count.index + 1}" : module.host_settings.nic.vnic_name
    hostname_label   = local.dns_label == "" ? "" : module.host_settings.shape.count != "1" ? "${local.dns_label}-${count.index + 1}" : local.dns_label
    private_ip = element(
      concat(module.host_settings.nic.private_ip, [""]),
      length(module.host_settings.nic.private_ip) == 0 ? 0 : count.index,
    )
    skip_source_dest_check = module.host_settings.nic.skip_source_dest_check
    // Current implementation requires providing a list of subnets when using ad-specific subnets
    subnet_id = data.oci_core_subnet.host[count.index % length(data.oci_core_subnet.host.*.id)].id

    freeform_tags = local.merged_freeform_tags
    defined_tags  = null
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.host.public_key_openssh
    user_data           = data.cloudinit_config.host.rendered
  }
  source_details {
    boot_volume_size_in_gbs = module.host_settings.disk.boot_volume_size_in_gbs
    source_id               = data.oci_core_images.oraclelinux-8.images.0.id
    source_type             = module.host_settings.shape.source_type
  }
  freeform_tags = local.merged_freeform_tags
  defined_tags  = null
  timeouts {
    create = module.host_settings.shape.timeout
  }
}

# --- Volume ---
resource "oci_core_volume" "host" {
  count               = module.host_settings.shape.count * length(module.host_settings.disk.block_storage_sizes_in_gbs)
  availability_domain = oci_core_instance.host[count.index % module.host_settings.shape.count].availability_domain
  compartment_id      = var.config.compartment_id
  display_name        = "${oci_core_instance.host[count.index % module.host_settings.shape.count].display_name}_volume${floor(count.index / module.host_settings.shape.count)}"
  size_in_gbs = element(
    module.host_settings.disk.block_storage_sizes_in_gbs,
    floor(count.index / module.host_settings.shape.count),
  )
  freeform_tags = local.merged_freeform_tags
  defined_tags  = null
}

# --- Volume Attachment ---
resource "oci_core_volume_attachment" "host" {
  count           = module.host_settings.shape.count * length(module.host_settings.disk.block_storage_sizes_in_gbs)
  attachment_type = module.host_settings.disk.attachment_type
  instance_id     = oci_core_instance.host[count.index % module.host_settings.shape.count].id
  volume_id       = oci_core_volume.host[count.index].id
  use_chap        = module.host_settings.disk.use_chap
}

# --- SSH Key ---
resource "tls_private_key" "host" {
  algorithm   = "RSA"
}