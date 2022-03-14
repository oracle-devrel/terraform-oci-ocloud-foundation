# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "input" {
  type = object({
    create   = bool
  })
  description = "Input for database module"
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
    resident   = any
    encryption = any
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
  description = "Service Configuration"
}

variable "database" {
  type = object({
    name         = string,
    cores        = number,
    storage      = number,
    type         = string,
    compartment  = string,
    stage        = number,
    display_name = string,
    version      = string,
    password     = string,
    license      = string
  })
  description = "Database Configuration"
}