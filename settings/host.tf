# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- input ---
variable "host" {
    type = object({
        shape = string,
        image = string,
        disk  = string,
        nic   = string
    })
    description = "Host Configuration"
    default = {
        shape = "small"
        image = "linux"
        disk  = "san"
        nic   = "private"
  }
}

// --- Standard Server Configurations
variable "shape" {
    type = map(object({
        count              = number,
        timeout            = string,
        flex_memory_in_gbs = number,
        flex_ocpus         = number,
        shape              = string,
        source_type        = string
    }))
    description = "Instance Parameters"
    default = {
        small = {
            count              = 1
            timeout            = "25m"
            flex_memory_in_gbs = null
            flex_ocpus         = null
            shape              = "VM.Standard2.1"
            source_type        = "image"
        },
        medium = {
            count              = 1
            timeout            = "25m"
            flex_memory_in_gbs = null
            flex_ocpus         = null
            shape              = "VM.Standard2.4"
            source_type        = "image"
        }
    }
}

variable "nic" {
    type = map(object({
        assign_public_ip       = bool,
        ipxe_script            = string,
        private_ip             = list(string),
        skip_source_dest_check = bool,
        vnic_name              = string
    }))
    description = "Network Parameters"
    default = {
        private = {
            assign_public_ip       = false
            ipxe_script            = null
            private_ip             = []
            skip_source_dest_check = false
            vnic_name              = "private"
        }, 
        public = {
            assign_public_ip       = true
            ipxe_script            = null
            private_ip             = []
            skip_source_dest_check = false
            vnic_name              = "public"
        }
    }
}

variable "image" {
    type = map(object({
        # operating system parameters
        extended_metadata = map(any),
        resource_platform = string,
        user_data         = string,
        timezone          = string
    }))
    description = "Operating System Parameters"
    default = {
        linux = {
            extended_metadata = {}
            resource_platform = "linux"
            user_data         = null
            timezone          = "UTC"
        }
    }
}

variable "disk" {
    type = map(object({
        attachment_type            = string,
        block_storage_sizes_in_gbs = list(number),
        boot_volume_size_in_gbs    = number,
        preserve_boot_volume       = bool,
        use_chap                   = bool
    }))
    description = "Storage Parameters"
    default = {
        san = {
            attachment_type             = "paravirtualized"
            block_storage_sizes_in_gbs  = [50]
            boot_volume_size_in_gbs     = null
            preserve_boot_volume        = false
            use_chap                    = false
        }
    }
}

// --- output ---
output "shape"  { value = var.shape[var.host.shape] }
output "image"  { value = var.image[var.host.image] }
output "disk"   { value = var.disk[var.host.disk] }
output "nic"    { value = var.nic[var.host.nic] }
output "shapes" { value = keys(var.shape) }
output "images" { value = keys(var.image) }
output "disks"  { value = keys(var.disk) }
output "nics"   { value = keys(var.nic) }