# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "input" {
  type = object({
    parent_id     = string,
    enable_delete = bool
  })
  description = "Settings for the service resident"
}

variable "tenancy" {
  type = object({
    class   = number,
    buckets = string,
    id      = string,
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