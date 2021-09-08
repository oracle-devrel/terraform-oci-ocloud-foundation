# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "config" {
  type = object({
    compartment_id = string,
    display_name   = string,   # Name of Virtual Cloud Network
    dns_label      = string,   # A service label to be used as part of resource names
    defined_tags   = map(any), # The different defined tags that are applied to each object by default.
    freeform_tags  = map(any)  # Compartment's OCID where VCN will be created.
  })
}

variable "vcn" {
  type = object({
    description                     = string, # Description you assign to the vcn. Does not have to be unique, and it's changeable
    address_spaces                  = map(string),  # Network address prefix in CIDR notation that all of the requested subnetwork prefixes will be allocated within.
    subnet_list                     = map(number), # A list of objects describing requested subnetwork prefixes. new_bits is the number of additional network prefix bits to add, in addition to the existing prefix on base_cidr_block.
    block_nat_traffic               = bool,   # Whether or not to block traffic through NAT gateway
    service_gateway_cidr            = string, # The OSN service cidr accessible through Service Gateway"
  })
  description = "Settings for the virtual cloud network"
}

variable "drg" {
  type = object({
    create_drg                      = bool,
    description                     = string #Description you assign to the drg. Does not have to be unique, and it's changeable
  })
  description = "Settings for the DRG"
}
