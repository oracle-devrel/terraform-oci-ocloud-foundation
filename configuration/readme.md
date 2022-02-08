## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_host"></a> [host](#input\_host) | Host Configuration | <pre>object({<br>        shape = string,<br>        image = string,<br>        disk  = string,<br>        nic   = string<br>    })</pre> | <pre>{<br>  "disk": "san",<br>  "image": "linux",<br>  "nic": "private",<br>  "shape": "small"<br>}</pre> | no |
| <a name="input_shape"></a> [shape](#input\_shape) | Instance Parameters | <pre>map(object({<br>        count              = number,<br>        timeout            = string,<br>        flex_memory_in_gbs = number,<br>        flex_ocpus         = number,<br>        shape              = string,<br>        source_type        = string<br>    }))</pre> | <pre>{<br>  "medium": {<br>    "count": 1,<br>    "flex_memory_in_gbs": null,<br>    "flex_ocpus": null,<br>    "shape": "VM.Standard2.4",<br>    "source_type": "image",<br>    "timeout": "25m"<br>  },<br>  "small": {<br>    "count": 1,<br>    "flex_memory_in_gbs": null,<br>    "flex_ocpus": null,<br>    "shape": "VM.Standard2.1",<br>    "source_type": "image",<br>    "timeout": "25m"<br>  }<br>}</pre> | no |
| <a name="input_nic"></a> [nic](#input\_nic) | Network Parameters | <pre>map(object({<br>        assign_public_ip       = bool,<br>        ipxe_script            = string,<br>        private_ip             = list(string),<br>        skip_source_dest_check = bool,<br>        vnic_name              = string<br>    }))</pre> | <pre>{<br>  "private": {<br>    "assign_public_ip": false,<br>    "ipxe_script": null,<br>    "private_ip": [],<br>    "skip_source_dest_check": false,<br>    "vnic_name": "private"<br>  },<br>  "public": {<br>    "assign_public_ip": true,<br>    "ipxe_script": null,<br>    "private_ip": [],<br>    "skip_source_dest_check": false,<br>    "vnic_name": "public"<br>  }<br>}</pre> | no |
| <a name="input_image"></a> [image](#input\_image) | Operating System Parameters | <pre>map(object({<br>        # operating system parameters<br>        extended_metadata = map(any),<br>        resource_platform = string,<br>        user_data         = string,<br>        timezone          = string<br>    }))</pre> | <pre>{<br>  "linux": {<br>    "extended_metadata": {},<br>    "resource_platform": "linux",<br>    "timezone": "UTC",<br>    "user_data": null<br>  }<br>}</pre> | no |
| <a name="input_disk"></a> [disk](#input\_disk) | Storage Parameters | <pre>map(object({<br>        attachment_type            = string,<br>        block_storage_sizes_in_gbs = list(number),<br>        boot_volume_size_in_gbs    = number,<br>        preserve_boot_volume       = bool,<br>        use_chap                   = bool<br>    }))</pre> | <pre>{<br>  "san": {<br>    "attachment_type": "paravirtualized",<br>    "block_storage_sizes_in_gbs": [<br>      50<br>    ],<br>    "boot_volume_size_in_gbs": null,<br>    "preserve_boot_volume": false,<br>    "use_chap": false<br>  }<br>}</pre> | no |
| <a name="input_input"></a> [input](#input\_input) | configuration paramenter for the service, defined through schema.tf | <pre>object({<br>        tenancy      = string,<br>        class        = string,<br>        owner        = string,<br>        organization = string,<br>        solution     = string,<br>        repository   = string,<br>        stage        = string,<br>        region       = string,<br>        domains      = list(any),<br>        segments     = list(any)<br>    })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_shape"></a> [shape](#output\_shape) | --- output --- |
| <a name="output_image"></a> [image](#output\_image) | n/a |
| <a name="output_disk"></a> [disk](#output\_disk) | n/a |
| <a name="output_nic"></a> [nic](#output\_nic) | n/a |
| <a name="output_shapes"></a> [shapes](#output\_shapes) | n/a |
| <a name="output_images"></a> [images](#output\_images) | n/a |
| <a name="output_disks"></a> [disks](#output\_disks) | n/a |
| <a name="output_nics"></a> [nics](#output\_nics) | n/a |
| <a name="output_network"></a> [network](#output\_network) | n/a |
| <a name="output_resident"></a> [resident](#output\_resident) | n/a |
| <a name="output_service"></a> [service](#output\_service) | n/a |
| <a name="output_tenancy"></a> [tenancy](#output\_tenancy) | n/a |
