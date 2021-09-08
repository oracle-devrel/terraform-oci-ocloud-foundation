# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "config" {
  type = object({
    tenancy_id    = string,
    base          = string,   
    defined_tags  = map(any), # The different defined tags that are applied to each object by default.
    freeform_tags = map(any)  # The different defined tags that are applied to each object by default.
  })
  description = "Settings for compartment"
}

variable "compartment" {
  type = object({
    enable_delete  = bool,    #true or false, determines to protect the compartment against destroy or not
    parent         = string,  #OCID of the parent compartment
    name           = string,  #Name, assigned during creation, must be unique across all compartments in the tenancy
  })
  description = "Settings for compartment"
}

variable "roles" {
  type = map(list(any))
}
