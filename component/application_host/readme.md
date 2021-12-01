## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_settings_host"></a> [settings\_host](#module\_settings\_host) | ../../settings/ | n/a |

## Resources

| Name | Type |
|------|------|
| [null_resource.previous](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [oci_bastion_session.ssh](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/bastion_session) | resource |
| [oci_core_instance.host](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_instance) | resource |
| [oci_core_volume.host](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume) | resource |
| [oci_core_volume_attachment.host](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_volume_attachment) | resource |
| [time_sleep.wait](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [tls_private_key.host](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [cloudinit_config.host](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |
| [oci_bastion_bastions.host](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/bastion_bastions) | data source |
| [oci_bastion_sessions.ssh](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/bastion_sessions) | data source |
| [oci_core_images.oraclelinux-8](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_images) | data source |
| [oci_core_instance_credentials.host](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_instance_credentials) | data source |
| [oci_core_instances.host](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_instances) | data source |
| [oci_core_services.host](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_services) | data source |
| [oci_core_shapes.ad1](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_shapes) | data source |
| [oci_core_subnet.domain](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_subnet) | data source |
| [oci_core_subnet.host](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_subnet) | data source |
| [oci_identity_availability_domains.host](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_availability_domains) | data source |
| [oci_identity_compartment.service](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_compartment) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config"></a> [config](#input\_config) | Service Configuration | <pre>object({<br>        service_id     = string,<br>        compartment_id = string,<br>        bundle_type    = number,<br>        subnet_ids     = list(string),<br>        bastion_id     = string,<br>        ad_number      = number,<br>        defined_tags   = map(any),<br>        freeform_tags  = map(any)<br>    })</pre> | n/a | yes |
| <a name="input_host"></a> [host](#input\_host) | Host Configuration | <pre>object({<br>        shape = string,<br>        image = string,<br>        disk  = string,<br>        nic   = string<br>    })</pre> | n/a | yes |
| <a name="input_host_name"></a> [host\_name](#input\_host\_name) | Identify the host, use a unique name | `string` | n/a | yes |
| <a name="input_ssh"></a> [ssh](#input\_ssh) | n/a | <pre>object({<br>        enable          = bool,<br>        type            = string,<br>        ttl_in_seconds  = number,<br>        target_port     = number<br>    })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_details"></a> [details](#output\_details) | ocid of created instances |
| <a name="output_oracle-linux-8-latest-id"></a> [oracle-linux-8-latest-id](#output\_oracle-linux-8-latest-id) | n/a |
| <a name="output_oracle-linux-8-latest-version"></a> [oracle-linux-8-latest-version](#output\_oracle-linux-8-latest-version) | n/a |
| <a name="output_password"></a> [password](#output\_password) | Passwords to login to Windows instance |
| <a name="output_ssh"></a> [ssh](#output\_ssh) | --- admin access --- |
| <a name="output_summary"></a> [summary](#output\_summary) | Private and Public IPs for each instance. |
| <a name="output_username"></a> [username](#output\_username) | Usernames to login to Windows instance |
