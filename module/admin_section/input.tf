# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "config" {
  type = object({
    tenancy_ocid   = string,
    defined_tags   = map(any), # The different defined tags that are applied to each object by default.
    freeform_tags  = map(any)  # The different defined tags that are applied to each object by default.
  })
  description = "Settings for compartment"
}

variable "compartment" {
  type = object({
    create         = bool,    #true or false, determines to create the compartment or not
    parent         = string,  #OCID of the parent compartment
    name           = string,  #Name, assigned during creation, must be unique across all compartments in the tenancy
    description    = string,  #Description you assign to the compartment. Does not have to be unique, and it's changeable
  })
  description = "Settings for compartment"
}

variable "group" {
  type = object({
    name          = string, #The name you assign to the group during creation. The name must be unique across all compartments in the tenancy
    description   = string  #The description you assign to the Group. Does not have to be unique, and it's changeable
  })
  description = "Create a user group"
}

variable "policy" {
  type = object({
    name           = string, #The name you assign to the group during creation. The name must be unique across all compartments in the tenancy
    description    = string,  #The description you assign to the Group. Does not have to be unique, and it's changeable
    statements     = list(string)
  })
  description = "Define access policies for admin roles"
}