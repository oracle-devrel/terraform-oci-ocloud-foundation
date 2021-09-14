# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_identity_tenancy"     "ocloud" { tenancy_id = var.config.tenancy_id } # Retrieve meta data for tenant
data "oci_identity_compartment" "domain" { id         = var.config.compartment_id }  # Retrieve meta data for the target compartment
data "oci_core_services"        "all_services" { }                                # Request a list of Oracle Service Network (osn) services
data "oci_core_vcn"             "domain" { vcn_id     = var.config.vcn_id }     # Retrieve meta data for the target vcn

# Small Configuration
# db_system_shape = VM.Standard2.2
# db_system_data_storage_size_in_gb = 512

# Medium Configuration
# db_system_shape = VM.Standard2.8
# db_system_data_storage_size_in_gb = 4096

# Medium Configuration
# db_system_shape = VM.Standard2.16
# db_system_data_storage_size_in_gb = 8192

locals {
    db_vcn_id         = try(data.oci_core_vcns.db_vcns.virtual_networks[0].id,var.vcn_id)
    nw_compartment_id = try(data.oci_identity_compartments.nw_compartments.compartments[0].id,var.nw_compartment_id)
    db_compartment_id = try(data.oci_identity_compartments.db_compartments.compartments[0].id,var.compartment_id)
    db_subnet_id      = try(data.oci_core_subnets.db_subnets.subnets[0].id,var.subnet_id)
    db_nsg_id         = try(data.oci_core_network_security_groups.db_network_security_groups.network_security_groups[0].id,var.db_system_nsg_id)
    db_system_shape = var.db_config == "Small" ? "VM.Standard2.2" : var.db_config == "Medium" ? "VM.Standard2.8" : var.db_config == "Large" ? "VM.Standard2.16" : var.db_system_shape
    db_system_data_storage_size_in_gb = var.db_config == "Small" ? 512 : var.db_config == "Medium" ? 4096 : var.db_config == "Large" ? 8192 : var.db_system_data_storage_size_in_gb

    #  2-node RAC DB systems requires ENTERPRISE_EDITION_EXTREME_PERFORMANCE edition and ASM
    db_system_node_count = var.deployment_type == "Cluster" ? 2 : var.db_system_node_count
    db_system_database_edition = local.db_system_node_count > 1 ? "ENTERPRISE_EDITION_EXTREME_PERFORMANCE" : var.db_system_database_edition
    db_system_db_system_options_storage_management = local.db_system_node_count > 1 || var.deployment_type == "Basic" ? "ASM" : var.deployment_type == "Fast Provisioning" ? "LVM" : var.db_system_db_system_options_storage_management
    # In case cluster name isn't set explicitly set it to <service label>-cluster. Note cluster name may not exceed 11 characters
    db_system_cluster_name = local.db_system_node_count > 1 && length(var.db_system_cluster_name) == 0 ? "${var.service}rac" : var.db_system_cluster_name
    # For Deployment Type Fast Provioning disable automated backups else enable it
    db_system_db_home_database_db_backup_config_auto_backup_enabled = var.deployment_type == "Fast Provisioning" ? false : var.deployment_type == "Fast Provisioning" || var.deployment_type == "Cluster" ? true : var.db_system_db_home_database_db_backup_config_auto_backup_enabled
}

data oci_identity_availability_domains "ADs" {
  compartment_id = var.tenancy_ocid
}

data "oci_identity_compartments" "nw_compartments" {
  compartment_id = var.tenancy_ocid
  name              = "${var.service}-network-cmp"
  compartment_id_in_subtree = true
  state                     = "ACTIVE"
}

data "oci_identity_compartments" "db_compartments" {
  compartment_id = var.tenancy_ocid
  name                      = "${var.service}-database-cmp"
  compartment_id_in_subtree = true
  state                     = "ACTIVE"
}

data "oci_core_vcns" "db_vcns" {
  compartment_id = local.nw_compartment_id
  display_name              = "${var.service}-0-vcn"
  state                     = "AVAILABLE"
}

data "oci_core_subnets" "db_subnets" {
  compartment_id = local.nw_compartment_id
  display_name = "${var.service}-0-db-subnet"
  state = "AVAILABLE"
}

data "oci_core_network_security_groups" "db_network_security_groups" {
  compartment_id = local.nw_compartment_id
  display_name = "${var.service}-0-vcn-db-nsg"
  state = "AVAILABLE"
}