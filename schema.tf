# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

## --- variables for the resource manager ---
variable "organization"            { 
  type        = string
  description =  "provide a string that identifies the commercial owner of a service"
  default     = "Organization"   # Define a name that identifies the project
  validation {
        condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,14}$", var.organization)) > 0
        error_message = "The service_name variable is required and must contain upto 15 alphanumeric characters only and start with a letter."
  }
}
variable "project"            { 
  type        = string
  description =  "provide a string that refers to a project"
  default     = "Project"   # Define a name that identifies the project
  validation {
        condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,14}$", var.project)) > 0
        error_message = "The service_name variable is required and must contain alphanumeric characters only, start with a letter and 15 character max."
  }
}
variable "environment"           { 
  type = string
  description = "define the CI/CD process stage"
  default = "DEV"           # Lifecycle stage for the code base
  validation {
        condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,2}$", var.environment)) > 0
        error_message = "The service_name variable is required and must contain alphanumeric characters only, start with a letter and 3 character max."
  }
}

variable "code_source" {
  type        = string
  description = "URL for the repository containing the infrastructure code"
  default     = "https://github.com/oracle-devrel/terraform-oci-ocloud-landing-zone/"
}

variable "admin_mail" {
  type        = string
  description = "email address of the compartment administrator"
  default     = "ocilabs@mail.com"
}

variable "bundle" {
  # allows to define provisioning tiers with "count = module.compose.bundle_id >= 2 ? 1 : 0" 
  type        = string
  description = "Determines the resource bundle to be provisioned"
  default     = "standard"
}

/*
variable "slack_channel" {
  type        = string
  description = "Create a slack app and paste webhook"
  default     = "https://bit.ly/3iqR5H8"
}
*/