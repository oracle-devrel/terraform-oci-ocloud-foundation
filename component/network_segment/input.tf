# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "segment" {
  type        = number
  description = "Identify the Section, use a unique number"
}

variable "config" {
  type = object({
    service_id     = string,
    service_name   = string,
    compartment_id = string,
    source         = string,
    freeform_tags  = map(any)
  })
  description = "Service Configuration"
}

variable "network" {
  type = object({
    address_spaces                  = map(string),  # Network address prefix in CIDR notation that all of the requested subnetwork prefixes will be allocated within.
    subnet_list                     = map(number), # A list of objects describing requested subnetwork prefixes. new_bits is the number of additional network prefix bits to add, in addition to the existing prefix on base_cidr_block.
    create_drg                      = bool,
    block_nat_traffic               = bool,   # Whether or not to block traffic through NAT gateway
    service_gateway_cidr            = string # The OSN service cidr accessible through Service Gateway"
  })
  description = "Settings for the virtual cloud network"
}