# Copyright (c) 2019, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "config" {
    type = object({
        compartment_id = string,
        vcn_id         = string,
        bastion_id     = string,
        ad_number      = number, 
        display_name   = string,
        dns_label      = string,
        defined_tags   = map(any),
        freeform_tags  = map(any)
    })
}

/*
variable "new_host" {
    type = object({
        server = string,
        type   = string,
        os     = string,
        size   = string,
        ad     = number 
    })
}
*/

variable "host" {
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
}

variable "session" {
    type = object({
        enable          = bool,
        type            = string,
        ttl_in_seconds  = number,
        target_port     = number
    })
}

/*
variable "notification" {
    type = object({
        notification_enabled = bool,    # Whether to enable ONS notification for the operator host (false)
        notification_endpoint = string, # The subscription notification endpoint. Email address to be notified (null)
        notification_protocol = string, # The notification protocol used ("EMAIL")
        notification_topic = string,    # The name of the notification topic ("operator")
    })
}
*/
