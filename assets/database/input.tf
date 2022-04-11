# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "schema" {
  type = object({
    class    = string,
    create   = bool,
    password = string
  })
  description = "Input for database module"
}

variable "config" {
  type = object({
    tenancy = any,
    service = any,
    database = any
  })
}

variable "assets" {
  type = object({
    encryption = any,
    network    = any,
    resident   = any
  })
  description = "Retrieve asset identifier"
}