## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_services.all](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_services) | data source |
| [oci_core_services.storage](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_services) | data source |
| [oci_identity_availability_domains.tenancy](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_availability_domains) | data source |
| [oci_identity_regions.tenancy](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_regions) | data source |
| [oci_identity_tenancy.resident](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_tenancy) | data source |
| [oci_objectstorage_namespace.tenancy](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/objectstorage_namespace) | data source |
| [template_file.ad_names](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_input"></a> [input](#input\_input) | configuration paramenter for the service, defined through schema.tf | <pre>object({<br>        tenancy      = string,<br>        class        = string,<br>        owner        = string,<br>        organization = string,<br>        solution     = string,<br>        repository   = string,<br>        stage        = string,<br>        region       = string,<br>        domains      = list(any),<br>        segments     = list(any)<br>    })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network"></a> [network](#output\_network) | n/a |
| <a name="output_resident"></a> [resident](#output\_resident) | n/a |
| <a name="output_tenancy"></a> [tenancy](#output\_tenancy) | n/a |
