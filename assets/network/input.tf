# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "schema" {
  type = object({
    internet = string,
    nat      = string,
    ipv6     = bool,
    osn      = string
  })
  description = "Input for database module"
}

variable "config" {
  type = object({
    tenancy = any,
    service = any,
    network = any
  })
}

variable "assets" {
  type = object({
    encryption = any,
    resident   = any
  })
  description = "Retrieve asset identifier"
}