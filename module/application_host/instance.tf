# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

resource "oci_core_instance" "ocloud" {
  count = var.instance.count
  // If no explicit AD number, spread instances on all ADs in round-robin. Looping to the first when last AD is reached
  availability_domain  = var.config.ad_number == null ? element(local.ADs, count.index) : element(local.ADs, var.config.ad_number - 1)
  compartment_id       = var.config.compartment_id
  display_name         = var.config.display_name == "" ? "" : var.instance.count != "1" ? "${var.config.display_name}_${count.index + 1}" : var.config.display_name
  extended_metadata    = var.instance.extended_metadata
  ipxe_script          = var.instance.ipxe_script
  preserve_boot_volume = var.instance.preserve_boot_volume
  shape                = var.instance.shape
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
    memory_in_gbs = local.shape_is_flex == true && var.instance.flex_memory_in_gbs != null ? var.instance.flex_memory_in_gbs : local.shapes_config[var.instance.shape]["memory_in_gbs"]
    ocpus         = local.shape_is_flex == true && var.instance.flex_ocpus != null ? var.instance.flex_ocpus : local.shapes_config[var.instance.shape]["ocpus"]
  }
  create_vnic_details {
    assign_public_ip = var.instance.assign_public_ip
    display_name     = var.instance.vnic_name == "" ? "" : var.instance.count != "1" ? "${var.instance.vnic_name}_${count.index + 1}" : var.instance.vnic_name
    hostname_label   = var.config.dns_label == "" ? "" : var.instance.count != "1" ? "${var.config.dns_label}-${count.index + 1}" : var.config.dns_label
    private_ip = element(
      concat(var.instance.private_ip, [""]),
      length(var.instance.private_ip) == 0 ? 0 : count.index,
    )
    skip_source_dest_check = var.instance.skip_source_dest_check
    // Current implementation requires providing a list of subnets when using ad-specific subnets
    subnet_id = data.oci_core_subnet.ocloud[count.index % length(data.oci_core_subnet.ocloud.*.id)].id

    freeform_tags = local.merged_freeform_tags
    defined_tags  = var.config.defined_tags
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.ocloud.public_key_openssh
    user_data           = data.cloudinit_config.ocloud.rendered
  }
  source_details {
    boot_volume_size_in_gbs = var.instance.boot_volume_size_in_gbs
    source_id               = data.oci_core_images.oraclelinux-8.images.0.id
    source_type             = var.instance.source_type
  }
  freeform_tags = local.merged_freeform_tags
  defined_tags  = var.config.defined_tags
  timeouts {
    create = var.instance.timeout
  }
}

# --- Volume ---
resource "oci_core_volume" "ocloud" {
  count               = var.instance.count * length(var.instance.block_storage_sizes_in_gbs)
  availability_domain = oci_core_instance.ocloud[count.index % var.instance.count].availability_domain
  compartment_id      = var.config.compartment_id
  display_name        = "${oci_core_instance.ocloud[count.index % var.instance.count].display_name}_volume${floor(count.index / var.instance.count)}"
  size_in_gbs = element(
    var.instance.block_storage_sizes_in_gbs,
    floor(count.index / var.instance.count),
  )
  freeform_tags = local.merged_freeform_tags
  defined_tags  = var.config.defined_tags
}

# --- Volume Attachment ---
resource "oci_core_volume_attachment" "ocloud" {
  count           = var.instance.count * length(var.instance.block_storage_sizes_in_gbs)
  attachment_type = var.instance.attachment_type
  instance_id     = oci_core_instance.ocloud[count.index % var.instance.count].id
  volume_id       = oci_core_volume.ocloud[count.index].id
  use_chap        = var.instance.use_chap
}

# --- SSH Key ---
resource "tls_private_key" "ocloud" {
  algorithm   = "RSA"
}