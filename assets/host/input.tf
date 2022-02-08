# Copyright (c) 2019, 2021 Oracle Corporation and/or affiliates.  All rights reserved.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl

variable "host_name" {
    type = string
    description   = "Identify the host, use a unique name"
    validation {
        condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,14}$", var.host_name)) > 0
        error_message = "The label variable must contain alphanumeric characters only, start with a letter, contains up to 15 letters and has at least three consonants."
    }
}

variable "config" {
    type = object({
        service_id     = string,
        compartment_id = string,
        deployment_type    = number,
        subnet_ids     = list(string),
        bastion_id     = string,
        ad_number      = number,
        defined_tags   = map(any),
        freeform_tags  = map(any)
    })
    description = "Service Configuration"
}

variable "host" {
    type = object({
        shape = string,
        image = string,
        disk  = string,
        nic   = string
    })
    description = "Host Configuration"
}

variable "ssh" {
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
