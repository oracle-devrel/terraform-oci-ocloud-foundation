// Copyright (c) 2020 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "service" {
    value = {
        name      = local.service_name
        label     = local.service_label
        stage     = local.lifecycle[var.input.stage]
        region    = {
            key  = local.region_key
            name = local.region_name
        }
    }
}