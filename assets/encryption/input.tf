# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "input" {
    type = object({
      type   = string,
      create = bool
    })
    description = "Schema input for the wallet creation"
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

variable "assets" {
  type = object({
    resident = any
  })
  description = "Retrieve asset identifier"
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
  description = "Service configuration"
}

variable "encryption" {
  type = object({
    compartment = string,
    vault       = string,
    stage       = number,
    key         = map(any),
    signatures  = map(any),
    secrets     = map(any),
    passwords   = list(string)
  })
  description = "Enabling enryption for a service resident"
}