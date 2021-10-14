# Copyright (c) 2020 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

// --- application admin --- //
variable "application" {
  default       = "Application"
  type          = string
  description   = "Identify the Section, use a unique name"
  validation {
    condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,14}$", var.application)) > 0
    error_message = "The service_name variable is required and must contain alphanumeric characters only, start with a letter, have at least consonants and contains up to 15 letters."
  }
}
module "application_section" {
  source         = "./component/admin_section/"
  providers      = { oci = oci.home }
  depends_on = [
    oci_identity_compartment.init, 
    module.operation_section,
    module.network_section
  ]
  config ={
    tenancy_id    = var.tenancy_ocid
    source        = var.source_url
    display_name  = lower("${local.service_name}_${var.application}")
    tagspace      = [ ]
    freeform_tags = { 
      "framework" = "ocloud"
    }
  }
  compartment  = {
    enable_delete = true # Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed
    parent        = local.service_id
  }
  roles = {
    "${local.service_name}_sysops"  = [
      "Allow group ${local.service_name}_sysops to read all-resources in compartment ${lower("${local.service_name}_${var.application}")}_compartment",
      "Allow group ${local.service_name}_sysops to use volume-family in compartment ${lower("${local.service_name}_${var.application}")}_compartment",
      "Allow group ${local.service_name}_sysops to use virtual-network-family in compartment ${lower("${local.service_name}_${var.application}")}_compartment",
      "Allow group ${local.service_name}_sysops to manage instances in compartment ${lower("${local.service_name}_${var.application}")}_compartment",
      "Allow group ${local.service_name}_sysops to manage instance-images in compartment ${lower("${local.service_name}_${var.application}")}_compartment",
      "Allow group ${local.service_name}_sysops to manage object-family in compartment ${lower("${local.service_name}_${var.application}")}_compartment"
    ]
  }
}
output "app_compartment_id"       { value = module.application_section.compartment_id }
output "app_compartment_name"     { value = module.application_section.compartment_name }
output "app_compartment_roles"    { value = module.application_section.roles }
// --- application admin --- //

// --- application tier --- //
module "application_domain" {
  source         = "./component/network_domain/"
  providers      = { oci = oci.home }
  depends_on     = [ module.application_section, module.service_segment ]
  config  = {
    service_id     = local.service_id
    compartment_id = module.application_section.compartment_id
    vcn_id         = module.service_segment.vcn_id
    anywhere       = module.service_segment.anywhere
    defined_tags   = null
    freeform_tags  = {"framework" = "ocloud"}
  }
  subnet  = {
    # Select the predefined name per index
    domain                      = element(keys(module.service_segment.subnets), 0) 
    # Select the predefined range per index
    cidr_block                  = element(values(module.service_segment.subnets), 0) 
    prohibit_public_ip_on_vnic  = false
    dhcp_options_id             = null
    route_table_id              = module.service_segment.private_route_table_id
  }
  bastion  = {
    # Determine whether a bastion service will be deployed and attached
    create            = true
    client_allow_cidr = [module.service_segment.anywhere]
    max_session_ttl   = 1800
  }
  tcp_ports = {
    ingress  = [
      ["ssh",   module.service_segment.subnets.pres, 22,  22],
      ["http",  module.service_segment.anywhere,     80,  80], 
      ["https", module.service_segment.anywhere,    443, 443]
    ]
  }
}
output "app_domain_subnet"        { value = module.application_domain.subnet }
output "apP_domain_security_list" { value = module.application_domain.seclist }
output "app_domain_bastion"       { value = module.application_domain.bastion }
// --- application tier --- //

/* --- application host --- //
module "operator" {
  source         = "./component/application_host/"
  providers      = { oci = oci.home }
  depends_on     = [module.application_section, module.application_domain]
  config  = {
    compartment_id = module.application_section.compartment.id  # (Updatable) The OCID of the compartment where to create all resources
    vcn_id         = module.service_segment.vcn.id            # The id of the VCN to use when creating the operator resources
    bastion_id     = module.application_domain.bastion.id
    ad_number      = 1                                  # The availability domain number of the instance. If none is provided, it will start with AD-1 and continue in round-robin
    service_name   = "${local.service_name}_operator"   # (Updatable) A user-friendly name for the instance. Does not have to be unique, and it's changeable
    service_name      = "${local.service_name}ophst"      # The hostname for the VNIC's primary private IP
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
    timezone                    = "UTC"
    # networking parameters
    assign_public_ip            = false             # Whether the VNIC should be assigned a public IP address
    ipxe_script                 = null              # (Optional) The iPXE script which to continue the boot process on the instance
    private_ip                  = []                # Private IP addresses of your choice to assign to the VNICs
    skip_source_dest_check      = false             # Whether the source/destination check is disabled on the VNIC
    subnet_id                   = [module.application_domain.subnet.id] # The unique identifiers (OCIDs) of the subnets in which the instance primary VNICs are created
    vnic_name                   = ""                # A user-friendly name for the VNIC
    # storage parameters
    attachment_type             = "paravirtualized" # (Optional) The type of volume. The only supported values are iscsi and paravirtualized
    block_storage_sizes_in_gbs  = [50]              # Sizes of volumes to create and attach to each instance
    boot_volume_size_in_gbs     = null              # The size of the boot volume in GBs
    preserve_boot_volume        = false             # Specifies whether to delete or preserve the boot volume when terminating an instance
    use_chap                    = false             # (Applicable when attachment_type=iscsi) Whether to use CHAP authentication for the volume attachment
  }
  session = {
    enable          = false # Determine whether a ssh session via bastion service will be started
    type            = "MANAGED_SSH" # Alternatively "PORT_FORWARDING"
    ttl_in_seconds  = 1800
    target_port     = 22
  }
}
output "app_instance_summary"      { value = module.operator.summary }
output "app_instance_details"      { value = module.operator.details }
output "app_instance_windows_user" { value = module.operator.username }
output "app_instance_ol8_version"  { value = module.operator.oracle-linux-8-latest-version }
output "app_instance_ol8_id"       { value = module.operator.oracle-linux-8-latest-id }
output "app_instance_ssh"          { value = module.operator.ssh }
// --- application host --- /*/
