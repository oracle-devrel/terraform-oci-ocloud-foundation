# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "config" {
  type = object({
    tenancy_id     = string,
    compartment_id = string,
    vcn_id         = string,
    vcn_cidr       = string,
    display_name   = string,
    dns_label      = string,
    defined_tags   = map(any),
    freeform_tags  = map(any),
    anywhere       = string
  })
}

variable "subnet" {
  type = object({
    cidr_block                  = string,
    subnet_list                 = map(number),
    prohibit_public_ip_on_vnic  = bool, 
    dhcp_options_id             = string,
    route_table_id              = string
  })
  description                   = "Parameters for each subnet to be managed"
}

variable "tcp_ports"{
  type = object({
    ingress  = list(list(any))
  })
}

variable "bastion"{
  type = object({
    compartment_id     = string,
    client_allow_cidr  = list(string),
    max_session_ttl    = number
  })
}
