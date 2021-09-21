# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

# This variable file contains variables for all types of DBaaS databases however as the scope is VM only,
# all non VM ones are commented.
# 
# DBaaS supports 3 different types of sources for creating a database. For this usecase we focus on 'NONE'
# which creates a new database.
#
# Source types:
# NONE: Create a new database
# DATABASE: Create a new database from an existing database, including archive redo log data.
# DB_BACKUP: Create a new database by restoring from a backup


variable "config" {
  type = object({
    tenancy_id     = string,
    compartment_id = string,
    vcn_id         = string,
    display_name   = string,
    dns_label      = string,
    defined_tags   = map(any),
    freeform_tags  = map(any)
  })
}

variable "availability_domains" {
    type = string
    description = "The availability domain where the DB system is located"
    default = ""
}

variable "compartment_id" {
    type = string
    description = "The OCID of the compartment the DB system belongs in"
    default = ""
}

variable "service" {
  description = "Common Label used with all related resources"
  type        = string
  # no default value, asking user to explicitly set this variable's value. see codingconventions.adoc  
}

variable "db_system_db_home_database_admin_password" {
    type = string
    description = "A strong password for SYS, SYSTEM, PDB Admin and TDE Wallet. The password must be at least nine characters and contain at least two uppercase, two lowercase, two numbers, and two special characters. The special characters must be _, #, or -."
    validation {
        condition     = length(var.db_system_db_home_database_admin_password) > 9
        error_message = "The password must be at least nine characters."
    }   
}

variable "db_system_db_home_database_character_set" {
    type = string
    default = "AL32UTF8"
}

variable "db_config" {
    type = string
    default = null
}

variable "deployment_type" {
    type = string
    default = null
}

# Applicable when source=DB_SYSTEM | NONE
variable "db_system_db_home_database_db_backup_config_auto_backup_enabled" {
    type = bool
    description = "(Updatable) If set to true, configures automatic backups. If you previously used RMAN or dbcli to configure backups and then you switch to using the Console or the API for backups, a new backup configuration is created and associated with your database. This means that you can no longer rely on your previously configured unmanaged backups to work."
    default = false
}

# Applicable when source=DB_SYSTEM | NONE
variable "db_system_db_home_database_db_backup_config_auto_backup_window" {
    type = string
    description = "(Updatable) Time window selected for initiating automatic backup for the database system. There are twelve available two-hour time windows. If no option is selected, a start time between 12:00 AM to 7:00 AM in the region of the database is automatically chosen. For example, if the user selects SLOT_TWO from the enum list, the automatic backup job will start in between 2:00 AM (inclusive) to 4:00 AM (exclusive). Example: SLOT_TWO"
    default = "SLOT_ONE"
}

# Applicable when source=DB_SYSTEM | NONE
 variable "db_system_db_home_database_db_backup_config_recovery_window_in_days" {
    type = number
    description = "(Updatable) Number of days between the current and the earliest point of recoverability covered by automatic backups. This value applies to automatic backups only. After a new automatic backup has been created, Oracle removes old automatic backups that are created before the window. When the value is updated, it is applied to all existing automatic backups."
    default = 7
}

variable "db_system_db_home_database_db_name" {
    type = string
    description = "The display name of the database to be created from the backup. It must begin with an alphabetic character and can contain a maximum of eight alphanumeric characters. Special characters are not permitted."
}

# Applicable when source=NONE
variable "db_system_db_home_database_db_workload" {
    type = string
    default = "OLTP"
    description = "The database workload type"
}

variable "db_system_db_home_database_defined_tags" { default = "" }
variable "db_system_db_home_database_freeform_tags" { default = "" }

# Applicable when source=NONE
variable "db_system_db_home_database_ncharacter_set" {
    type = string
    default = "AL16UTF16"
    description = "The national character set for the database. The default is AL16UTF16. Allowed values are: AL16UTF16 or UTF8"
}

# Applicable when source=NONE
variable "db_system_db_home_database_pdb_name" {
    type = string
    default = "pdb1"
    description = "The name of the pluggable database. The name must begin with an alphabetic character and can contain a maximum of thirty alphanumeric characters. Special characters are not permitted. Pluggable database should not be same as database name"
}

# Applicable when source=NONE
variable "db_system_db_home_database_tde_wallet_password" {
    type = string
    description = "The optional password to open the TDE wallet. The password must be at least nine characters and contain at least two uppercase, two lowercase, two numeric, and two special characters. The special characters must be _, #, or -"
    validation {
        condition     = can(var.db_system_db_home_database_tde_wallet_password == "") || length(var.db_system_db_home_database_tde_wallet_password) > 9
        error_message = "The password must be at least nine characters."
    }
    default = ""
}

# Required when source=NONE
variable "db_system_db_home_db_version" {
    type = string
    description = "Oracle Database version"
    default = "19.0.0.0"
}

variable "db_system_db_home_defined_tags" { default = "" }

variable "db_system_db_home_display_name" {
    type = string
    description = "The user-provided name of the Database Home"
    default = "dbhome"
}

variable "db_system_hostname" {
    type = string
    description = "The hostname for the DB system. The hostname must begin with an alphabetic character, and can contain alphanumeric characters and hyphens (-). The maximum length of the hostname is 16 characters for bare metal and virtual machine DB systems, and 12 characters for Exadata DB systems. The maximum length of the combined hostname and domain is 63 characters. Note: The hostname must be unique within the subnet. If it is not unique, the DB system will fail to provision"
    default = "oracledb"
}

# Required
variable "db_system_shape" {
    type        = string
    description = "The shape of the DB system. The shape determines resources allocated to the DB system"
    default     = "VM.Standard2.2"
}

# Required
variable "db_system_ssh_public_keys" {
    type = string
    description = "The public key portion of the key pair to use for SSH access to the DB system. Multiple public keys can be provided. The length of the combined keys cannot exceed 40,000 characters"
}

# Required
# Network compartment which contains all network resources as VCN, database subnet and database network 
# security groups
variable "nw_compartment_id" {
    type = string
    default = ""
}

# Required
# VCN
variable "vcn_id" {
    type = string
    default = ""
}

# Required
# Private subnet where the DB nodes are created
variable "subnet_id" {
    type = string
    description = "Client Subnet"
    default = ""
}

# Optional
# Only required when 2 nodes are selected
variable "db_system_cluster_name" {
    type = string
    description = "The cluster name for Exadata and 2-node RAC virtual machine DB systems. The cluster name must begin with an alphabetic character, and may contain hyphens (-). Underscores (_) are not permitted. The cluster name can be no longer than 11 characters and is not case sensitive"
    validation {
        condition     = length(var.db_system_cluster_name) <= 11
        error_message = "The cluster name can be no longer than 11 characters."
    }
    default = ""
}

# Required for VMDBs
variable "db_system_data_storage_size_in_gb" {
    type = number
    default = 512
    description = "Size (in GB) of the initial data volume that will be created and attached to a virtual machine DB system. You can scale up storage after provisioning, as needed. Note that the total storage size attached will be more than the amount you specify to allow for REDO/RECO space and software volume. Required for VMDBs"
}

# Required when source=DATABASE | DB_BACKUP | NONE
# Use ENTERPRISE_EDITION_EXTREME_PERFORMANCE for 2-node RAC
variable "db_system_database_edition" {
    type = string
    description = "The Oracle Database Edition that applies to all the databases on the DB system. Exadata DB systems and 2-node RAC DB systems require ENTERPRISE_EDITION_EXTREME_PERFORMANCE."
    default = "ENTERPRISE_EDITION"
}

# Optional
variable "db_system_db_system_options_storage_management" {
    type = string
    description = "The storage option used in DB system. ASM - Automatic storage management LVM - Logical Volume management. On 2-node instances ASM is default."
    default = "ASM"
}

variable "db_system_defined_tags" { default = "" }

# Optional. If no name is entered OCI will automatically assign a DB system name
variable "db_system_display_name" {
    type = string
    description = "The user-friendly name for the DB system. The name does not have to be unique"
}

variable "db_system_fault_domains" {
    type = list
    description = "List of the Fault Domains in which this DB system is provisioned"
    default = [ "FAULT-DOMAIN-1", "FAULT-DOMAIN-2", "FAULT-DOMAIN-3" ]
}

variable "db_system_license_model" {
    type = string
    description = "(Updatable) The Oracle license model that applies to all the databases on the DB system. The default is LICENSE_INCLUDED"
    default = "LICENSE_INCLUDED"
}

# Optional
variable "db_system_node_count" {
    type = number
    description = "The number of nodes to launch for a 2-node RAC virtual machine DB system. Specify either 1 or 2"
    default = 1      
}

# Required
variable "db_system_nsg_id" {
    type = string
    description = "A list of the OCIDs of the network security groups (NSGs) that the backup network of this DB system belongs to. Setting this to an empty array after the list is created removes the resource from all NSGs."
    default = ""
}

# Optional, supported for VM and BM Shapes
variable "db_system_private_ip" {
    type = string
    description = "A private IP address of your choice. Must be an available IP address within the subnet's CIDR. If you don't specify a value, Oracle automatically assigns a private IP address from the subnet. Supported for VM BM shape."
    default = ""
}

# Optional
# Default is NONE
variable "db_system_source" {
    type = string
    description = "The source of the database: Use NONE for creating a new database. Use DB_BACKUP for creating a new database by restoring from a backup. Use DATABASE for creating a new database from an existing database, including archive redo log data. The default is NONE"
    default = "NONE"
}

# Optional
variable "db_system_time_zone" {
    type = string
    description = "The time zone to use for the DB system"
    default = "UTC"
}
