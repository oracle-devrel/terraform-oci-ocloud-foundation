// Copyright (c) 2020 Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

output "tenancy" {
  value = {
    id       = var.solution.tenancy
    class    = local.classification[var.solution.class]
    buckets  = local.storage_namespace
    region   = {
      key  = local.home_region_key
      name = local.home_region_name
      }
  }
}