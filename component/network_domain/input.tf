# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "config" {
  type = object({
    service_id     = string,
    compartment_id = string,
    vcn_id         = string,
    defined_tags   = map(any),
    freeform_tags  = map(any),
    anywhere       = string
  })
}

variable "subnet" {
  type = object({
    domain                      = string,
    cidr_block                  = string,
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
    create             = bool,
    client_allow_cidr  = list(string),
    max_session_ttl    = number
  })
}
