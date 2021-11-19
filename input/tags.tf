# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

//--- input ---
variable "tag_family" {
    type        = string
    description = "..."
    default     = "budget"
}

// --- config ---
variable "budget_tags" {
    type = object({
        cost_center = number,
        created_by  = string,
        created_on  = string
        })
    description = "budget tags"
    default     = {
        cost_center = 0
        created_by  = "user_name"
        created_on  = "datetime"
    }
}

variable "operation_tags" {
    type = object({
        application         = string,
        application_version = string,
        last_updated        = string
    })
    description = "operation tags"
    default     = {
        application         = "application_name"
        application_version = "application_version"
        last_updated        = "last_updated"
    }
}

variable "compliance_tags" {
    type = object({
        data_classification = list(string)
    })
    description = "compliance tags"
    default     = {
        data_classification = ["public", "confidential", "secret", "top_secret"]
    }
}

// --- output ---
output "budget_tags" {
  value = var.budget_tags
}

output "operation_tags" {
  value = var.operation_tags
}

output "compliance_tags" {
  value = var.compliance_tags
}