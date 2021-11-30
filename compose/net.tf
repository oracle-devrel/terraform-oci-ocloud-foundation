# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

variable "address_spaces" {
    type        = map(string)
    description = "Address Spaces"
    default = {
        cidr_block   = "10.0.0.0/23"
        anywhere     = "0.0.0.0/0"
        interconnect = "192.168.0.0/16"
    }
}

variable "subnets" {
    type         = map(number)
    description  = "A list with newbits for the cidrsubnet function, for subnet calculations visit http://jodies.de/ipcalc"
    default = {
        pres     = 3
        app      = 3
        db       = 3
        k8s      = 3
        k8snodes = 3
        k8slb    = 3
    }
}

output "address_spaces" { value = var.address_spaces }
output "subnets"        { value = var.subnets }