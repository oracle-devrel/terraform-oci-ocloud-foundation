## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.previous](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [oci_database_autonomous_database.database](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/database_autonomous_database) | resource |
| [time_sleep.wait](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [oci_database_autonomous_databases.database](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/database_autonomous_databases) | data source |
| [oci_identity_compartments.database](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_compartments) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_input"></a> [input](#input\_input) | Input for database module | <pre>object({<br>    create   = bool<br>  })</pre> | n/a | yes |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | Tenancy Configuration | <pre>object({<br>    id      = string,<br>    class   = number,<br>    buckets = string,<br>    region  = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_assets"></a> [assets](#input\_assets) | Retrieve asset identifier | <pre>object({<br>    resident   = any<br>    encryption = any<br>  })</pre> | n/a | yes |
| <a name="input_resident"></a> [resident](#input\_resident) | Service Configuration | <pre>object({<br>    owner          = string,<br>    name           = string,<br>    label          = string,<br>    stage          = number,<br>    region         = map(string)<br>    compartments   = map(number),<br>    repository     = string,<br>    groups         = map(string),<br>    policies       = map(any),<br>    notifications  = map(any),<br>    tag_namespaces = map(number),<br>    tags           = any<br>  })</pre> | n/a | yes |
| <a name="input_database"></a> [database](#input\_database) | Database Configuration | <pre>object({<br>    name         = string,<br>    cores        = number,<br>    storage      = number,<br>    type         = string,<br>    compartment  = string,<br>    stage        = number,<br>    display_name = string,<br>    version      = string,<br>    password     = string,<br>    license      = string<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_database_ids"></a> [database\_ids](#output\_database\_ids) | A list of automous databases created by the database module |
| <a name="output_service_console_url"></a> [service\_console\_url](#output\_service\_console\_url) | n/a |
| <a name="output_connection_strings"></a> [connection\_strings](#output\_connection\_strings) | n/a |
| <a name="output_connection_urls"></a> [connection\_urls](#output\_connection\_urls) | n/a |
| <a name="output_password"></a> [password](#output\_password) | n/a |
