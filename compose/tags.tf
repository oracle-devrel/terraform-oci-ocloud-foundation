# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

//--- input ---
variable "tag_collection" {
    type        = string
    description = "a collection a tags"
    default     = "operation"
}

variable "tag" {
    type        = string
    description = "selection a single value to be assigned a tag"
    default     = "created_by"
}

// --- config ---
variable "collections" {
    description = "tag collections for default_tags"
    type = object({
        budget = object({
            cost_center = list(string),
            account     = list(number),
            created_by  = string,
            created_on  = string
        })
        operation = object({
            solution     = list(string),
            application  = list(string),
            version      = number,
            last_updated = string
        })
        governance = object({
            bundle          = list(string),
            confidentiality = list(string)
        })
    })
    default = {
        budget = {
            cost_center = [ "not defined", "HR", "IT", "Sales" ]
            account     = [ 0, 1, 2, 3 ],
            created_by  = "name"
            created_on  = "date"
        }
        operation = {
            solution     = [ "not defined", "ERP", "SCM", "PLM", "CX" ]
            application  = [ "not defined", "PeopleSoft", "Siebel" ]
            version      = 0
            last_updated = "date"
        }
        governance = {
            bundle          = [ "free_tier", "payg", "standard", "premium" ]
            confidentiality = [ "public", "confidential", "secret" ]
        }
    }
}

// --- output ---
locals {
    tagsbycollection = { for collection, tags in var.collections : collection => [for tag in keys(tags): tag] }
    valuesbytag = merge([for collection, tags in var.collections: { for tag, values in tags: tag => flatten([values]) }]...)
    defaultvalue = merge([for collection, tags in var.collections: { for tag, values in tags: tag => flatten([values])[0] }]...)
}

output "tag_collections" { value = local.tagsbycollection }
output "tag_values"      { value = local.valuesbytag }
output "default_value"   { value = local.defaultvalue }