# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "input" {
    type = object({
      internet = string,
      nat      = string,
      ipv6     = bool,
      osn      = string
    })
    description = "Resources identifier from resident module"
}

variable "assets" {
  type = object({
    resident = any
  })
  description = "Retrieve asset identifier"
}

variable "tenancy" {
  type = object({
    id      = string,
    class   = number,
    buckets = string,
    region  = map(string)
  })
  description = "Tenancy Configuration"
}

variable "resident" {
  type = object({
    owner          = string,
    name           = string,
    label          = string,
    stage          = number,
    region         = map(string)
    compartments   = map(number),
    repository     = string,
    groups         = map(string),
    policies       = map(any),
    notifications  = map(any),
    tag_namespaces = map(number),
    tags           = any
  })
  description = "Service Configuration"
}

variable "network" {
  type = object({
    name         = string,
    region       = string,
    display_name = string,
    dns_label    = string,
    compartment  = string,
    stage        = number,
    cidr         = string,
    gateways     = any,
    subnets      = map(any),
    route_table_input = list(any),
    security_groups   = map(any)
    security_lists    = any
  })
  description = "Network Configuration"
}