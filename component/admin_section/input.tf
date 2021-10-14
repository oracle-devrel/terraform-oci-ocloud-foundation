# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "config" {
  type = object({
    tenancy_id    = string,
    source        = string,
    display_name  = string,    # Name, assigned during creation, must be unique across all compartments in the tenancy
    freeform_tags = map(any)   # freeform tags that are applied to each compartment by default
  })
  description = "Settings for compartment"
}

variable "compartment" {
  type = object({
    enable_delete = bool,     # true or false, determines to protect the compartment against destroy or not
    parent        = string    # OCID of the parent compartment
  })
  description = "Settings for compartment"
}

variable "roles" {
  type = map(list(any))
}