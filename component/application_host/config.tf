// Copyright 2017, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl/

data "oci_identity_compartment" "service" { id        = var.config.service_id }
data "oci_core_subnet"          "domain"  { subnet_id = var.config.subnet_ids[0] }

// --- Get all the Availability Domains for the region
data "oci_identity_availability_domains" "host" { compartment_id = var.config.compartment_id }
// --- Retrieve meta data for the target compartment
data "oci_core_services"                 "host" { }

// --- Filter on AD1 to remove duplicates. ocloud should give all the shapes supported on the region
data "oci_core_shapes" "ad1" {
  compartment_id      = var.config.compartment_id
  availability_domain = local.ADs[0]
}

data "oci_core_subnet" "host" {
  count     = length(var.config.subnet_ids)
  subnet_id = element(var.config.subnet_ids, count.index)
}

// --- Bastion Datasource  ----
data "oci_bastion_bastions" "host" {
  compartment_id          = data.oci_core_subnet.domain.compartment_id
  bastion_id              = var.config.bastion_id
  bastion_lifecycle_state = "ACTIVE"
}

// --- Instance Credentials Datasource ---
data "oci_core_instance_credentials" "host" {
  #count       = var.host.resource_platform != "linux" ? var.host.count : 0
  count       = module.host.image.resource_platform != "linux" ? module.host.shape.count : 0
  instance_id = oci_core_instance.host[count.index].id
}

// --- cloud init ---
data "cloudinit_config" "host" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "instance.yaml"
    content_type = "text/cloud-config"
    content = templatefile(
      local.cloudinit, {
        shell_script = local.shell_script,
        timezone     = module.host.image.timezone,
      }
    )
  }
}

// --- get latest Oracle Linux 8 image ---
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

data "oci_core_instances" "host" {
  depends_on = [ oci_core_instance.host ]
  compartment_id = var.config.compartment_id
  filter {
    name   = "display_name"
    values = ["${local.display_name}_operator_host"]
  }
}

data "oci_bastion_sessions" "ssh" {
  depends_on              = [ oci_bastion_session.ssh ]
  bastion_id              = var.config.bastion_id
  session_lifecycle_state = "ACTIVE"
  filter {
    name    = "display_name"
    values  = ["${local.display_name}_ssh"]
  }
}

locals {
  # naming conventions
  display_name  = "${data.oci_identity_compartment.service.name}_${var.host_name}"
  dns_label     = "${format("%s%s%s", lower(substr(split("_", data.oci_identity_compartment.service.name)[0], 0, 3)), lower(substr(split("_", data.oci_identity_compartment.service.name)[1], 0, 5)), substr("${var.host_name}", 0, 2))}"
  bastion_label = "${local.dns_label}bstn"
  ADs = [
    # Iterate through data.oci_identity_availability_domains.ad and create a list containing AD names
    for i in data.oci_identity_availability_domains.host.availability_domains : i.name
  ]
  default_freeform_tags = {
    # ocloud list of freeform tags are added by default to user provided freeform tags (var.config.freeform_tags) if local.merged_freeform_tags is used
    terraformed = "Please do not edit manually"
    module      = "oracle-terraform-modules/compute-instance/oci"
  }
  merged_freeform_tags = merge(local.default_freeform_tags, var.config.freeform_tags)
  shapes_config = {
    # prepare data with default values for flex shapes. Used to populate shape_config block with default values
    # Iterate through data.oci_core_shapes.ad1.shapes (ocloud exclude duplicate data in multi-ad regions) and create a map { name = { memory_in_gbs = "xx"; ocpus = "xx" } }
    for i in data.oci_core_shapes.ad1.shapes : i.name => {
      "memory_in_gbs" = i.memory_in_gbs
      "ocpus"         = i.ocpus
    }
  }
  shape_is_flex = length(regexall("^*.Flex", module.host.shape.shape)) > 0 # evaluates to boolean true when var.instance.shape contains .Flex
  instances_details = [
    # display name, Primary VNIC Public/Private IP for each instance
    for i in oci_core_instance.host : <<EOT
    ${~i.display_name~}
    Primary-PublicIP: %{if i.public_ip != ""}${i.public_ip~}%{else}N/A%{endif~}
    Primary-PrivateIP: ${i.private_ip~}
    EOT
  ]
  cloudinit      = "${path.module}/instance.yaml"
  shell_script   = base64gzip(
    templatefile("${path.module}/instance.sh",
      {
        ol = "8"
      }
    )
  )
}

// --- Standard Server Configurations
module "host" {
  source     = "./input/"
  host = {
    shape = var.host.shape
    image = var.host.image
    disk  = var.host.disk
    nic   = var.host.nic
  }
}

// Define the wait state for the data requests. This resource will destroy (potentially immediately) after null_resource.next
resource "null_resource" "previous" {}

resource "time_sleep" "wait" {
  depends_on      = [null_resource.previous]
  create_duration = "6m"
}

// --- required terraform provider --- 
terraform {
  required_providers {
    oci = {
      source = "hashicorp/oci"
    }
  }
}