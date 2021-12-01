## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_identity_compartment.service](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_compartment) | data source |
| [oci_identity_regions.tenancy](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_regions) | data source |
| [oci_identity_tenancy.service](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_tenancy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_spaces"></a> [address\_spaces](#input\_address\_spaces) | Address Spaces | `map(string)` | <pre>{<br>  "anywhere": "0.0.0.0/0",<br>  "cidr_block": "10.0.0.0/23",<br>  "interconnect": "192.168.0.0/16"<br>}</pre> | no |
| <a name="input_bundle"></a> [bundle](#input\_bundle) | deployment bundle parameter | `string` | `"standard"` | no |
| <a name="input_bundles"></a> [bundles](#input\_bundles) | --- config --- The bundle argument allows to define provisioning tiers with "count = module.settings.bundle\_id >= 2 ? 1 : 0" | `map(number)` | <pre>{<br>  "free_tier": 1,<br>  "payg": 2,<br>  "premium": 4,<br>  "standard": 3<br>}</pre> | no |
| <a name="input_collections"></a> [collections](#input\_collections) | tag collections for default\_tags | <pre>object({<br>        budget = object({<br>            cost_center = list(string),<br>            account     = list(number),<br>            created_by  = string,<br>            created_on  = string<br>        })<br>        operation = object({<br>            solution     = list(string),<br>            application  = list(string),<br>            version      = number,<br>            last_updated = string<br>        })<br>        governance = object({<br>            bundle          = list(string),<br>            confidentiality = list(string)<br>        })<br>    })</pre> | <pre>{<br>  "budget": {<br>    "account": [<br>      0,<br>      1,<br>      2,<br>      3<br>    ],<br>    "cost_center": [<br>      "not defined",<br>      "HR",<br>      "IT",<br>      "Sales"<br>    ],<br>    "created_by": "name",<br>    "created_on": "date"<br>  },<br>  "governance": {<br>    "bundle": [<br>      "free_tier",<br>      "payg",<br>      "standard",<br>      "premium"<br>    ],<br>    "confidentiality": [<br>      "public",<br>      "confidential",<br>      "secret"<br>    ]<br>  },<br>  "operation": {<br>    "application": [<br>      "not defined",<br>      "PeopleSoft",<br>      "Siebel"<br>    ],<br>    "last_updated": "date",<br>    "solution": [<br>      "not defined",<br>      "ERP",<br>      "SCM",<br>      "PLM",<br>      "CX"<br>    ],<br>    "version": 0<br>  }<br>}</pre> | no |
| <a name="input_disk"></a> [disk](#input\_disk) | Storage Parameters | <pre>map(object({<br>        attachment_type            = string,<br>        block_storage_sizes_in_gbs = list(number),<br>        boot_volume_size_in_gbs    = number,<br>        preserve_boot_volume       = bool,<br>        use_chap                   = bool<br>    }))</pre> | <pre>{<br>  "san": {<br>    "attachment_type": "paravirtualized",<br>    "block_storage_sizes_in_gbs": [<br>      50<br>    ],<br>    "boot_volume_size_in_gbs": null,<br>    "preserve_boot_volume": false,<br>    "use_chap": false<br>  }<br>}</pre> | no |
| <a name="input_host"></a> [host](#input\_host) | Host Configuration | <pre>object({<br>        shape = string,<br>        image = string,<br>        disk  = string,<br>        nic   = string<br>    })</pre> | <pre>{<br>  "disk": "san",<br>  "image": "linux",<br>  "nic": "private",<br>  "shape": "small"<br>}</pre> | no |
| <a name="input_image"></a> [image](#input\_image) | Operating System Parameters | <pre>map(object({<br>        # operating system parameters<br>        extended_metadata = map(any),<br>        resource_platform = string,<br>        user_data         = string,<br>        timezone          = string<br>    }))</pre> | <pre>{<br>  "linux": {<br>    "extended_metadata": {},<br>    "resource_platform": "linux",<br>    "timezone": "UTC",<br>    "user_data": null<br>  }<br>}</pre> | no |
| <a name="input_nic"></a> [nic](#input\_nic) | Network Parameters | <pre>map(object({<br>        assign_public_ip       = bool,<br>        ipxe_script            = string,<br>        private_ip             = list(string),<br>        skip_source_dest_check = bool,<br>        vnic_name              = string<br>    }))</pre> | <pre>{<br>  "private": {<br>    "assign_public_ip": false,<br>    "ipxe_script": null,<br>    "private_ip": [],<br>    "skip_source_dest_check": false,<br>    "vnic_name": "private"<br>  },<br>  "public": {<br>    "assign_public_ip": true,<br>    "ipxe_script": null,<br>    "private_ip": [],<br>    "skip_source_dest_check": false,<br>    "vnic_name": "public"<br>  }<br>}</pre> | no |
| <a name="input_service_id"></a> [service\_id](#input\_service\_id) | n/a | `any` | n/a | yes |
| <a name="input_shape"></a> [shape](#input\_shape) | Instance Parameters | <pre>map(object({<br>        count              = number,<br>        timeout            = string,<br>        flex_memory_in_gbs = number,<br>        flex_ocpus         = number,<br>        shape              = string,<br>        source_type        = string<br>    }))</pre> | <pre>{<br>  "medium": {<br>    "count": 1,<br>    "flex_memory_in_gbs": null,<br>    "flex_ocpus": null,<br>    "shape": "VM.Standard2.4",<br>    "source_type": "image",<br>    "timeout": "25m"<br>  },<br>  "small": {<br>    "count": 1,<br>    "flex_memory_in_gbs": null,<br>    "flex_ocpus": null,<br>    "shape": "VM.Standard2.1",<br>    "source_type": "image",<br>    "timeout": "25m"<br>  }<br>}</pre> | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A list with newbits for the cidrsubnet function, for subnet calculations visit http://jodies.de/ipcalc | `map(number)` | <pre>{<br>  "app": 3,<br>  "db": 3,<br>  "k8s": 3,<br>  "k8slb": 3,<br>  "k8snodes": 3,<br>  "pres": 3<br>}</pre> | no |
| <a name="input_tag"></a> [tag](#input\_tag) | selection a single value to be assigned a tag | `string` | `"created_by"` | no |
| <a name="input_tag_collection"></a> [tag\_collection](#input\_tag\_collection) | a collection a tags | `string` | `"operation"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address_spaces"></a> [address\_spaces](#output\_address\_spaces) | n/a |
| <a name="output_bundle_id"></a> [bundle\_id](#output\_bundle\_id) | n/a |
| <a name="output_bundles"></a> [bundles](#output\_bundles) | --- output --- |
| <a name="output_default_value"></a> [default\_value](#output\_default\_value) | n/a |
| <a name="output_disk"></a> [disk](#output\_disk) | n/a |
| <a name="output_disks"></a> [disks](#output\_disks) | n/a |
| <a name="output_image"></a> [image](#output\_image) | n/a |
| <a name="output_images"></a> [images](#output\_images) | n/a |
| <a name="output_location_key"></a> [location\_key](#output\_location\_key) | n/a |
| <a name="output_location_name"></a> [location\_name](#output\_location\_name) | n/a |
| <a name="output_nic"></a> [nic](#output\_nic) | n/a |
| <a name="output_nics"></a> [nics](#output\_nics) | n/a |
| <a name="output_shape"></a> [shape](#output\_shape) | --- output --- |
| <a name="output_shapes"></a> [shapes](#output\_shapes) | n/a |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | n/a |
| <a name="output_tag_collections"></a> [tag\_collections](#output\_tag\_collections) | n/a |
| <a name="output_tag_values"></a> [tag\_values](#output\_tag\_values) | n/a |
