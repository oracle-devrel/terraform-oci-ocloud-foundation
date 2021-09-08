# Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/


# --- Get all the Availability Domains for the region
data "oci_identity_availability_domains" "ad" {
  compartment_id = var.config.compartment_id
}

# --- Subnet Datasource  ----
data "oci_core_subnet" "ocloud" {
  count     = length(var.instance.subnet_id)
  subnet_id = element(var.instance.subnet_id, count.index)
}

# --- Shapes ----
// Create a data source for compute shapes.
// Filter on AD1 to remove duplicates. ocloud should give all the shapes supported on the region.
// ocloud will not check quota and limits for AD requested at resource creation
data "oci_core_shapes" "ad1" {
  compartment_id      = var.config.compartment_id
  availability_domain = local.ADs[0]
}

locals {
  ADs = [
    // Iterate through data.oci_identity_availability_domains.ad and create a list containing AD names
    for i in data.oci_identity_availability_domains.ad.availability_domains : i.name
  ]
  default_freeform_tags = {
    # * ocloud list of freeform tags are added by default to user provided freeform tags (var.config.freeform_tags) if local.merged_freeform_tags is used
    terraformed = "Please do not edit manually"
    module      = "oracle-terraform-modules/compute-instance/oci"
  }
  merged_freeform_tags = merge(local.default_freeform_tags, var.config.freeform_tags)
  shapes_config = {
    // prepare data with default values for flex shapes. Used to populate shape_config block with default values
    // Iterate through data.oci_core_shapes.ad1.shapes (ocloud exclude duplicate data in multi-ad regions) and create a map { name = { memory_in_gbs = "xx"; ocpus = "xx" } }
    for i in data.oci_core_shapes.ad1.shapes : i.name => {
      "memory_in_gbs" = i.memory_in_gbs
      "ocpus"         = i.ocpus
    }
  }
  shape_is_flex = length(regexall("^*.Flex", var.instance.shape)) > 0 # evaluates to boolean true when var.instance.shape contains .Flex
  instances_details = [
    // display name, Primary VNIC Public/Private IP for each instance
    for i in oci_core_instance.ocloud : <<EOT
    ${~i.display_name~}
    Primary-PublicIP: %{if i.public_ip != ""}${i.public_ip~}%{else}N/A%{endif~}
    Primary-PrivateIP: ${i.private_ip~}
    EOT
  ]
  cloudinit      = "${path.module}/ocloud.yaml"
  shell_script   = base64gzip(
    templatefile("${path.module}/ocloud.sh",
      {
        ol = "8"
      }
    )
  )
}

# --- Instance Credentials Datasource ---
data "oci_core_instance_credentials" "ocloud" {
  count       = var.instance.resource_platform != "linux" ? var.instance.count : 0
  instance_id = oci_core_instance.ocloud[count.index].id
}

# cloud init
data "cloudinit_config" "ocloud" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "ocloud.yaml"
    content_type = "text/cloud-config"
    content = templatefile(
      local.cloudinit, {
        shell_script = local.shell_script,
        timezone     = var.instance.timezone,
      }
    )
  }
}

# get latest Oracle Linux 8 image
data "oci_core_images" "oraclelinux-8" {
  compartment_id           = var.config.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  filter {
    name = "display_name"
    values = ["^([a-zA-z]+)-([a-zA-z]+)-([\\.0-9]+)-([\\.0-9-]+)$"]
    regex = true
  }
}

/*
# bastion sessions
data "oci_bastion_sessions" "ocloud" {
  bastion_id = var.ssh.bastion_id
  display_name            = var.ssh.display_name
  session_id              = oci_bastion_session.managed_ssh.id
  session_lifecycle_state = "ACTIVE"
}
*/

data "oci_bastion_sessions" "port_forwarding" {
  bastion_id = var.ssh.bastion_id
  display_name            = var.ssh.display_name
  session_id              = oci_bastion_session.port_forwarding.id
  session_lifecycle_state = "ACTIVE"
}
