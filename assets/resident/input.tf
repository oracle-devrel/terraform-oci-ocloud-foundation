# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "schema" {
  type = object({
    enable_delete = bool,
    parent_id     = string,
    user_id       = string
  })
  description = "Input for database module"
}

variable "config" {
  type = object({
    tenancy  = any,
    service = any
  })
}