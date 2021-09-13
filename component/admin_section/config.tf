# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_tenancy"     "ocloud"       { tenancy_id = var.config.tenancy_id }           # Retrieve meta data for tenant