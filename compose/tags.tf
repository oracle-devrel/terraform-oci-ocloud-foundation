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
            cost_center = [ "to be set", "HR", "IT", "Sales" ]
            account     = [ 0, 1, 2, 3 ],
            created_by  = "to be set"
            created_on  = "to be set"
        }
        operation = {
            solution     = [ "to be set", "ERP", "SCM", "PLM", "CX" ]
            application  = [ "to be set", "PeopleSoft", "Siebel" ]
            version      = 0
            last_updated = "to be set"
        }
        governance = {
            bundle          = [ "to be set", "free_tier", "payg", "standard", "premium" ]
            confidentiality = [ "to be set", "public", "confidential", "secret" ]
        }
    }
}

// --- output ---
locals {
    tagsbycollection = { 
        for collection, tags in var.collections : collection => [for tag in keys(tags): tag] 
    }

    tagpairs = flatten([ 
        for collection, tags in local.tagsbycollection :  
            [ for tag in tags : {
                "namespace" = collection
                "tag"       = tag
            }]
    ])

    valuesbytag = flatten([
        for collection, tags in var.collections: flatten([
            for tag, values in tags: { 
                tag   = tag
                value = flatten([values])[0]
            } 
        ])
    ])
}

output "tag_namespaces"  { value = keys(local.tagsbycollection) }
output "tag_collection" { value = local.tagsbycollection }
output "identity_tags"   { value = local.tagsbycollection["${var.tag_collection}"] }
output "default_values"  { value = local.valuesbytag }