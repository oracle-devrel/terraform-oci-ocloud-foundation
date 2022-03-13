// Copyright (c) 2020 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "databases" {
  value = {
    autonomous = [for database in local.adb : {
      compartment  = contains(flatten(var.resolve.domains[*].name), "database") ? "${local.service_name}_database_compartment" : local.service_name
      stage        = database.stage
      name         = database.name
      cores        = database.cores
      storage      = database.storage
      type         = database.type
      display_name = "${local.service_name}_${lower(database.type)}_${database.name}"
      version      = database.version
      license      = database.license
    }if database.type == local.database[var.input.adb]][0]
  }
}