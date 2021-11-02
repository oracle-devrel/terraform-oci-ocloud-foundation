# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "section_name" {
  type          = string
  description   = "Identify the section, use a unique name"
  validation {
    condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,14}$", var.section_name)) > 0
    error_message = "The service_name variable is required and must contain alphanumeric characters only, start with a letter, have at least consonants and contains up to 15 letters."
  }
}

variable "config" {
  type = object({
    tenancy_id    = string,
    source        = string,
    service_name  = string,
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