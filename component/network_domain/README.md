## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| oci | n/a |

## Modules

<pre>
module "network_domain" {
  source         = "./module/broadcast_domain/"
  providers      = { oci = oci.home }
  tenancy_ocid   = var.tenancy_ocid
  defined_tags   = null
  freeform_tags  = {"framework"= "ocloud"}
  subnet  = {
    display_name                = "NET_${local.service_name}"
    dns_label                   = "net${local.service_label}"
    vcn_id                      = module.ocloud1_segment.vcn.id
    cidr_block                  = cidrsubnet(module.ocloud1_segment.vcn.cidr_block, 4, 0)
    compartment_id              = module.ops_section.compartment_id
    prohibit_public_ip_on_vnic  = "false"
    dhcp_options_id             = null
    internet_gateway            = module.network_segment.internet_gateway.id
    route_rules                 = [ module.ocloud1_segment.osn_route, module.ocloud1_segment.nat_route ]
  }
}
</pre>

Please change the keys **network**, **net** and **NET** to a unique name

## Resources

| Name |
|------|
| [oci_core_subnet](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_subnet) |
| [oci_core_security_list](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_security_list) |
| [oci_core_route_table](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_route_table) |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| vcn\_id | ... | `string` | `"..."` | no |
| service\_label | A service label to be used as part of resource names. | `string` | `"cis"` | no |
| dns\_label | A label prefix for the subnet, used in conjunction with the VNIC's hostname and VCN's DNS label to form a fully qualified domain name (FQDN) for each VNIC within this subnet. | `string` | `"subnet"` | no |
| subnets | Parameters for each subnet to be managed. | <pre>map(object({<br>    compartment_id    = string,<br>    defined_tags      = map(string),<br>    freeform_tags     = map(string),<br>    dynamic_cidr      = bool,<br>    cidr              = string,<br>    cidr_len          = number,<br>    cidr_num          = number,<br>    enable_dns        = bool,<br>    dns_label         = string,<br>    private           = bool,<br>    ad                = number,<br>    dhcp_options_id   = string,<br>    route_table_id    = string,<br>    security_list_ids = list(string)<br>  }))</pre> | n/a | yes |
| cidr\_block | A domain covers a single, contiguous IPv4 CIDR block of your choice. | `string` | `"10.0.0.0/16"` | no |
| prohibit\_public\_ip\_on\_vnic | ... | `string` | `"..."` | no |
| dhcp\_options\_id | ... | `string` | `"..."` | no |
| route\_tables | Parameters for each route table to be managed. | <pre>map(object({<br>    compartment_id = string<br>    route_rules    = list(object({<br>      is_create         = bool<br>      destination       = string,<br>      destination_type  = string,<br>      network_entity_id = string<br>    }))<br>  }))</pre> | n/a | yes |
| security\_list\_ids | ... | `string` | `"..."` | no |
| anywhere\_cidr | n/a | `string` | `"0.0.0.0/0"` | no |
| default\_compartment\_id | The default compartment OCID to use for resources (unless otherwise specified). | `string` | `""` | no |
| default\_defined\_tags | The different defined tags that are applied to each object by default. | `map(string)` | `{}` | no |
| default\_freeform\_tags | The different freeform tags that are applied to each object by default. | `map(string)` | `{}` | no |
| default\_security\_list\_id | The id of the default security list. | `string` | `""` | no |
| nsgs | Parameters for customizing Network Security Group(s). | <pre>map(object({<br>    compartment_id  = string,<br>    defined_tags    = map(string),<br>    freeform_tags   = map(string),<br>    ingress_rules   = list(object({<br>      description   = string,<br>      stateless     = bool,<br>      protocol      = string,<br>      src           = string,<br>      # Allowed values: CIDR_BLOCK, SERVICE_CIDR_BLOCK, NETWORK_SECURITY_GROUP, NSG_NAME<br>      src_type      = string,<br>      src_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      dst_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      icmp_type     = number,<br>      icmp_code     = number<br>    })),<br>    egress_rules    = list(object({<br>      description   = string,<br>      stateless     = bool,<br>      protocol      = string,<br>      dst           = string,<br>      # Allowed values: CIDR_BLOCK, SERVICE_CIDR_BLOCK, NETWORK_SECURITY_GROUP, NSG_NAME<br>      dst_type      = string,<br>      src_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      dst_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      icmp_type     = number,<br>      icmp_code     = number<br>    }))<br>  }))</pre> | `{}` | no |
| ports\_not\_allowed\_from\_anywhere\_cidr | n/a | `list(number)` | <pre>[<br>  22,<br>  3389<br>]</pre> | no |
| security\_lists | Parameters for customizing Security List(s). | <pre>map(object({<br>    compartment_id  = string,<br>    defined_tags    = map(string),<br>    freeform_tags   = map(string),<br>    ingress_rules   = list(object({<br>      stateless     = bool,<br>      protocol      = string,<br>      src           = string,<br>      src_type      = string,<br>      src_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      dst_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      icmp_type     = number,<br>      icmp_code     = number<br>    })),<br>    egress_rules    = list(object({<br>      stateless     = bool,<br>      protocol      = string,<br>      dst           = string,<br>      dst_type      = string,<br>      src_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      dst_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      icmp_type     = number,<br>      icmp_code     = number<br>    }))<br>  }))</pre> | `{}` | no |
| standalone\_nsg\_rules | Any standalone NSG rules that should be added (whether or not the NSG is defined here). | <pre>object({<br>    ingress_rules   = list(object({<br>      nsg_id        = string,<br>      description   = string,<br>      stateless     = bool,<br>      protocol      = string,<br>      src           = string,<br>      # Allowed values: CIDR_BLOCK, SERVICE_CIDR_BLOCK, NETWORK_SECURITY_GROUP, NSG_NAME<br>      src_type      = string,<br>      src_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      dst_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      icmp_type     = number,<br>      icmp_code     = number<br>    })),<br>    egress_rules    = list(object({<br>      nsg_id        = string,<br>      description   = string,<br>      stateless     = bool,<br>      protocol      = string,<br>      dst           = string,<br>      # Allowed values: CIDR_BLOCK, SERVICE_CIDR_BLOCK, NETWORK_SECURITY_GROUP, NSG_NAME<br>      dst_type      = string,<br>      src_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      dst_port      = object({<br>        min         = number,<br>        max         = number<br>      }),<br>      icmp_type     = number,<br>      icmp_code     = number<br>    }))<br>  })</pre> | <pre>{<br>  "egress_rules": [],<br>  "ingress_rules": []<br>}</pre> | no |
| vcn\_cidr | The vcn cidr block. | `string` | `""` | no |
| vcn\_id | The VCN id where the Security List(s) should be created. | `string` | `""` | no |


## Outputs

| Name | Description |
|------|-------------|
| subnets | The managed subnets, indexed by display\_name. |
| route\_tables | The managed route tables, indexed by display\_name. |
| security\_lists | The security list(s) created/managed. |
