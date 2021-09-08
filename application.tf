# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

module "app_section" {
  source         = "./component/admin_section/"
  providers      = { oci = oci.home }
  depends_on = [
    module.ops_section,
    module.net_section
  ]
  config ={
    tenancy_id    = var.tenancy_ocid
    base          = var.base_url
    defined_tags  = null
    freeform_tags = {"framework"= "ocloud"}
  }
  compartment  = {
    enable_delete = false #Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed
    parent        = var.tenancy_ocid
    name          = "${local.service_label}_application_compartment"
  }
  roles = {
    sysops  = [
      "Allow group sysops to read app-catalog-listing in tenancy",
      "Allow group sysops to read all-resources in compartment ${local.service_label}_application_compartment",
      "Allow group sysops to use volume-family in compartment ${local.service_label}_application_compartment",
      "Allow group sysops to use virtual-network-family in compartment ${local.service_label}_application_compartment",
      "Allow group sysops to manage instances in compartment ${local.service_label}_application_compartment",
      "Allow group sysops to manage instance-images in compartment ${local.service_label}_application_compartment",
      "Allow group sysops to manage object-family in compartment ${local.service_label}_application_compartment"
    ]
  }
}

// --- app section output ---
output "app_compartment" { value = module.app_section.compartment }
output "app_roles"       { value = module.app_section.roles }

// --- network domain ---
module "app_domain" {
  source         = "./component/network_domain/"
  providers      = { oci = oci.home }
    depends_on = [
    module.net_section,
    module.segment_1
  ]
  config  = {
    tenancy_id     = var.tenancy_ocid
    compartment_id = module.app_section.compartment.id
    vcn_id         = module.segment_1.vcn.id
    display_name   = "${local.service_name}_application"
    dns_label      = "${local.service_label}app"
    anywhere       = module.segment_1.anywhere
    defined_tags   = null
    freeform_tags  = {"framework" = "ocloud"}
  }
  subnet  = {
    cidr_block                  = module.segment_1.subnets.app
    prohibit_public_ip_on_vnic  = false
    dhcp_options_id             = null
    route_table_id              = module.segment_1.private_route_table.id
  }
  bastion  = {
    create            = false # Determine whether a bastion service will be deployed and attached
    client_allow_cidr = [module.segment_1.anywhere]
    max_session_ttl   = 1800
  }
  tcp_ports = {
    ingress  = [
      ["ssh",   module.segment_1.subnets.pres, 22,  22],
      ["http",  module.segment_1.anywhere,     80,  80], 
      ["https", module.segment_1.anywhere,    443, 443]
    ]
  }
}

// --- db domain output ---
output "app_domain_subnet"        { value = module.app_domain.subnet }
output "app_domain_security_list" { value = module.app_domain.seclist }
output "app_domain_bastion"       { value = module.app_domain.bastion }

// --- application host ---
module "operator" {
  source         = "./component/application_host/"
  providers      = { oci = oci.home }
  depends_on     = [module.app_section, module.app_domain]
  config  = {
    compartment_id = module.ops_section.compartment.id  # (Updatable) The OCID of the compartment where to create all resources
    vcn_id         = module.segment_1.vcn.id            # The id of the VCN to use when creating the operator resources
    bastion_id     = module.pres_domain.bastion.id
    ad_number      = 1                                  # The availability domain number of the instance. If none is provided, it will start with AD-1 and continue in round-robin
    display_name   = "${local.service_name}_operator"   # (Updatable) A user-friendly name for the instance. Does not have to be unique, and it's changeable
    dns_label      = "${local.service_label}ophst"      # The hostname for the VNIC's primary private IP
    defined_tags   = null                               # predefined and scoped to a namespace to tag the resources created using defined tags
    freeform_tags  = {"framework" = "ocloud"}           # simple key-value pairs to tag the resources created using freeform tags
  }
  host = {
    count                       = 1                 # Number of identical instances to launch from a single module
    timeout                     = "25m"             # Timeout setting for creating instance
    flex_memory_in_gbs          = null              # (Updatable) The total amount of memory available to the instance, in gigabytes
    flex_ocpus                  = null              # (Updatable) The total number of OCPUs available to the instance
    shape                       = "VM.Standard2.1"  # The shape of an instance
    source_type                 = "image"           # The source type for the instance
    # operating system parameters
    extended_metadata           = {}                # (Updatable) Additional metadata key/value pairs that you provide 
    resource_platform           = "linux"           # Platform to create resources in
    user_data                   = null              # Provide your own base64-encoded data to be used by Cloud-Init to run custom scripts or provide custom Cloud-Init configuration
    timezone                    = "America/New_York"
    # networking parameters
    assign_public_ip            = false             # Whether the VNIC should be assigned a public IP address
    ipxe_script                 = null              # (Optional) The iPXE script which to continue the boot process on the instance
    private_ip                  = []                # Private IP addresses of your choice to assign to the VNICs
    skip_source_dest_check      = false             # Whether the source/destination check is disabled on the VNIC
    subnet_id                   = [module.app_domain.subnet.id] # The unique identifiers (OCIDs) of the subnets in which the instance primary VNICs are created
    vnic_name                   = ""                # A user-friendly name for the VNIC
    # storage parameters
    attachment_type             = "paravirtualized" # (Optional) The type of volume. The only supported values are iscsi and paravirtualized
    block_storage_sizes_in_gbs  = [50]              # Sizes of volumes to create and attach to each instance
    boot_volume_size_in_gbs     = null              # The size of the boot volume in GBs
    preserve_boot_volume        = false             # Specifies whether to delete or preserve the boot volume when terminating an instance
    use_chap                    = false             # (Applicable when attachment_type=iscsi) Whether to use CHAP authentication for the volume attachment
  }
  session = {
    enable          = true # Determine whether a ssh session via bastion service will be started
    type            = "MANAGED_SSH" # Alternatively "PORT_FORWARDING"
    ttl_in_seconds  = 1800
    target_port     = 22
  }
}

// --- operator host output ---
output "app_instance_summary"      { value = module.operator.summary }
output "app_instance_details"      { value = module.operator.details }
output "app_instance_windows_user" { value = module.operator.username }
output "app_instance_ol8_version"  { value = module.operator.oracle-linux-8-latest-version }
output "app_instance_ol8_id"       { value = module.operator.oracle-linux-8-latest-id }
output "app_instance_ssh"          { value = module.operator.ssh }