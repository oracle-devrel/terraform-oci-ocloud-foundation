# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "input" {
    description = "configuration paramenter for the service, defined through schema.tf"
    type = object({
        tenancy      = string,
        class        = string,
        owner        = string,
        organization = string,
        solution     = string,
        repository   = string,
        stage        = string,
        region       = string,
        domains      = list(any),
        segments     = list(any)
    })
}