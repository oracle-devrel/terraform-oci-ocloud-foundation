# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

resource "oci_core_instance" "instance" {
  count = var.host.count
  // If no explicit AD number, spread instances on all ADs in round-robin. Looping to the first when last AD is reached
  availability_domain  = var.config.ad_number == null ? element(local.ADs, count.index) : element(local.ADs, var.config.ad_number - 1)
  compartment_id       = var.config.compartment_id
  display_name         = var.config.display_name == "" ? "" : var.host.count != "1" ? "${var.config.display_name}_operator_host_${count.index + 1}" : "${var.config.display_name}_operator_host"
  extended_metadata    = var.host.extended_metadata
  ipxe_script          = var.host.ipxe_script
  preserve_boot_volume = var.host.preserve_boot_volume
  shape                = var.host.shape
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
    memory_in_gbs = local.shape_is_flex == true && var.host.flex_memory_in_gbs != null ? var.host.flex_memory_in_gbs : local.shapes_config[var.host.shape]["memory_in_gbs"]
    ocpus         = local.shape_is_flex == true && var.host.flex_ocpus != null ? var.host.flex_ocpus : local.shapes_config[var.host.shape]["ocpus"]
  }
  create_vnic_details {
    assign_public_ip = var.host.assign_public_ip
    display_name     = var.host.vnic_name == "" ? "" : var.host.count != "1" ? "${var.host.vnic_name}_${count.index + 1}" : var.host.vnic_name
    hostname_label   = var.config.dns_label == "" ? "" : var.host.count != "1" ? "${var.config.dns_label}-${count.index + 1}" : var.config.dns_label
    private_ip = element(
      concat(var.host.private_ip, [""]),
      length(var.host.private_ip) == 0 ? 0 : count.index,
    )
    skip_source_dest_check = var.host.skip_source_dest_check
    // Current implementation requires providing a list of subnets when using ad-specific subnets
    subnet_id = data.oci_core_subnet.host[count.index % length(data.oci_core_subnet.host.*.id)].id

    freeform_tags = local.merged_freeform_tags
    defined_tags  = var.config.defined_tags
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.host.public_key_openssh
    user_data           = data.cloudinit_config.instance.rendered
  }
  source_details {
    boot_volume_size_in_gbs = var.host.boot_volume_size_in_gbs
    source_id               = data.oci_core_images.oraclelinux-8.images.0.id
    source_type             = var.host.source_type
  }
  freeform_tags = local.merged_freeform_tags
  defined_tags  = var.config.defined_tags
  timeouts {
    create = var.host.timeout
  }
}

# --- Volume ---
resource "oci_core_volume" "instance" {
  count               = var.host.count * length(var.host.block_storage_sizes_in_gbs)
  availability_domain = oci_core_instance.instance[count.index % var.host.count].availability_domain
  compartment_id      = data.oci_identity_compartment.host.id
  display_name        = "${oci_core_instance.instance[count.index % var.host.count].display_name}_volume${floor(count.index / var.host.count)}"
  size_in_gbs = element(
    var.host.block_storage_sizes_in_gbs,
    floor(count.index / var.host.count),
  )
  freeform_tags = local.merged_freeform_tags
  defined_tags  = var.config.defined_tags
}

# --- Volume Attachment ---
resource "oci_core_volume_attachment" "instance" {
  count           = var.host.count * length(var.host.block_storage_sizes_in_gbs)
  attachment_type = var.host.attachment_type
  instance_id     = oci_core_instance.instance[count.index % var.host.count].id
  volume_id       = oci_core_volume.instance[count.index].id
  use_chap        = var.host.use_chap
}

# --- SSH Key ---
resource "tls_private_key" "host" {
  algorithm   = "RSA"
}