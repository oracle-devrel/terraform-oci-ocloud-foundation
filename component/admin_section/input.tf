# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "config" {
  type = object({
    tenancy_id    = string,
    source        = string,
    display_name  = string,
    freeform_tags = map(any)
  })
  description = "Settings for adminstrator section"
}

variable "compartment" {
  type = object({
    enable_delete = bool,
    parent        = string
  })
  description = "Settings for compartment"
}

variable "roles" {
  type = map(list(any))
  description = "Role definitions"
}