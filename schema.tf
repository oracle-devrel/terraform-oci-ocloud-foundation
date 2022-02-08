# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

## --- variables for the resource manager ---
variable "organization"            { 
    type        = string
    description =  "The organization represents an unique identifier for a service owner and triggers the definition of groups on root compartment level"
    default     = "Organization"
    validation {
        condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,14}$", var.organization)) > 0
        error_message = "The service_name variable is required and must contain upto 15 alphanumeric characters only and start with a letter."
    }
}
variable "solution"            { 
    type        = string
    description =  "The solution represents an unique identifier for a service defined on root compartment level"
    default     = "Service"   # Define a name that identifies the service
    validation {
        condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,14}$", var.solution)) > 0
        error_message = "The service_name variable is required and must contain alphanumeric characters only, start with a letter and 15 character max."
    }
}

variable "repository" {
    type        = string
    description = "The service configuration is stored using infrastructure code in a repository"
    default     = "https://github.com/oracle-devrel/terraform-oci-ocloud-landing-zone/"
}

variable "owner" {
    type        = string
    description = "The service owner is identified by his or her eMail address"
    default     = "RobotNotExist@oracle.com"
}

variable "class" {
    type        = string
    description = "The tenancy classification sets boundaries for resource deployments"
    default     = "enterprise"
}

variable "stage"           { 
    type = string
    description = "The stage variable triggers lifecycle related resources to be provisioned"
    default = "DEV"           # Lifecycle stage for the code base
    validation {
        condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,3}$", var.stage)) > 0
        error_message = "A service_name variable is required and must contain alphanumeric characters only, start with a letter and 4 character max."
    }
}

variable "region" {
    type        = string
    description = "The region defines the target region for service deployments"
    default     = "us-ashburn-1"
}

variable "domains" {
    default = [
        {
            name     = "operation"
            stage    = 0
            roles    = ["cloudops", "auditor", "secops"]
            channels = ["activation", "events"]
        },{
            name     = "network"
            stage    = 0
            roles    = ["netops"]
            channels = ["events"]
        },{
            name     = "database"
            stage    = 0
            roles    = ["dba"]
            channels = ["events"]
        },{
            name     = "application"
            stage    = 0
            roles    = ["sysops"]
            channels = ["events"]
        }
    ]
    description = "Administrator domains reflect the structure of a service management organization and ensure the seperation of concerns"
}

variable "segments" {
    default = [
        {
            name        = "core"
            cidr        = "10.0.0.0/23"
            stage       = 0
            # The referenced segment need to have at least one subnet defined in subnets.tf file before running apply 
            topology    = ["host", "nodes", "container"]
            # "ENABLE" or "DISABLE" access from public internet
            internet    = "ENABLE"
            # Access to the Oracle Service Network, options include "DISABLE", "STORAGE" or "ALL"
            osn         = "ALL" 
            # "ENABLE" or "DISABLE" Network Address Translation for private subnets
            nat         = "ENABLE" 
            ipv6        = false
        }
    ]
    description = "Network segments define a service toplogy with route rules and port filters between subnets"
}