# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

## --- variables for the resource manager ---
variable "organization"            { 
  type        = string
  description =  "provide a string that identifies the commercial owner of a service"
  default     = "org"   # Define a name that identifies the project
  validation {
        condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,7}$", var.organization)) > 0
        error_message = "The service_label variable is required and must contain alphanumeric characters only, start with a letter and 5 character max."
  }
}
variable "project"            { 
  type        = string
  description =  "provide a string that refers to a project"
  default     = "name"   # Define a name that identifies the project
  validation {
        condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,7}$", var.project)) > 0
        error_message = "The service_label variable is required and must contain alphanumeric characters only, start with a letter and 8 character max."
  }
}
variable "stage"           { 
  type = string
  description = "define the lifecycle status"
  default = "dev"           # Lifecycle stage for the code base
  validation {
        condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,7}$", var.stage)) > 0
        error_message = "The service_label variable is required and must contain alphanumeric characters only, start with a letter and 3 character max."
  }
}
