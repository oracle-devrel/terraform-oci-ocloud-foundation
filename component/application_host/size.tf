// Copyright (c) 2019, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

/*
variable "small" {
    type = object({
        count                       = number,
        timeout                     = string,
        flex_memory_in_gbs          = number,
        flex_ocpus                  = number,
        shape                       = string,
        source_type                 = string,
        # operating system parameters
        extended_metadata           = map(any),
        resource_platform           = string,
        user_data                   = string,
        timezone                    = string,
        # networking parameters
        assign_public_ip            = bool,
        ipxe_script                 = string,
        private_ip                  = list(string),
        skip_source_dest_check      = bool,
        subnet_id                   = list(string),
        vnic_name                   = string,
        # storage parameters
        attachment_type             = string,
        block_storage_sizes_in_gbs  = list(number),
        boot_volume_size_in_gbs     = number,
        preserve_boot_volume        = bool,
        use_chap                    = bool
    })
    description = "VCN parameters"
    default = {
        count                       = 1                 # Number of identical instances to launch from a single module
        timeout                     = "25m"             # Timeout setting for creating instance
        flex_memory_in_gbs          = null              # (Updatable) The total amount of memory available to the instance, in gigabytes
        flex_ocpus                  = null              # (Updatable) The total number of OCPUs available to the instance
        shape                       = "VM.Standard2.1"  # The shape of an instance
        source_type                 = "image"           # The source type for the instance

        extended_metadata           = {}                # (Updatable) Additional metadata key/value pairs that you provide 
        resource_platform           = "linux"           # Platform to create resources in
        user_data                   = null              # Provide your own base64-encoded data to be used by Cloud-Init to run custom scripts or provide custom Cloud-Init configuration
        timezone                    = "America/New_York"

        assign_public_ip            = false             # Whether the VNIC should be assigned a public IP address
        ipxe_script                 = null              # (Optional) The iPXE script which to continue the boot process on the instance
        private_ip                  = []                # Private IP addresses of your choice to assign to the VNICs
        skip_source_dest_check      = false             # Whether the source/destination check is disabled on the VNIC
        subnet_id                   = [module.application_domain.subnet.id] # The unique identifiers (OCIDs) of the subnets in which the instance primary VNICs are created
        vnic_name                   = ""                # A user-friendly name for the VNIC

        attachment_type             = "paravirtualized" # (Optional) The type of volume. The only supported values are iscsi and paravirtualized
        block_storage_sizes_in_gbs  = [50]              # Sizes of volumes to create and attach to each instance
        boot_volume_size_in_gbs     = null              # The size of the boot volume in GBs
        preserve_boot_volume        = false             # Specifies whether to delete or preserve the boot volume when terminating an instance
        use_chap                    = false             # (Applicable when attachment_type=iscsi) Whether to use CHAP authentication for the volume attachment
    }
}
*/