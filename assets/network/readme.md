## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Module
```
// --- network configuration --- //
module "network" {
  source = "github.com/ocilabs/network"
  depends_on = [module.configuration, module.resident]
  providers = {oci = oci.service}
  for_each  = {for segment in local.segments : segment.name => segment}
  tenancy   = module.configuration.tenancy
  resident  = module.configuration.resident
  network   = module.configuration.network[each.key]
  input = {
    internet = var.internet
    nat      = var.nat
    ipv6     = var.ipv6
    osn      = var.osn
  }
  assets = {
    resident = module.resident
  }
}
output "network" {
  value = {
    for resource, parameter in module.network : resource => parameter
    }
}
// --- network configuration --- //
```

## Resources

| Name | Type |
|------|------|
| [null_resource.previous](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [oci_core_default_security_list.default_security_list](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_default_security_list) | resource |
| [oci_core_drg.segment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_drg) | resource |
| [oci_core_drg_attachment.segment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_drg_attachment) | resource |
| [oci_core_internet_gateway.segment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_internet_gateway) | resource |
| [oci_core_nat_gateway.segment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_nat_gateway) | resource |
| [oci_core_route_table.segment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_route_table) | resource |
| [oci_core_security_list.segment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_security_list) | resource |
| [oci_core_service_gateway.segment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_service_gateway) | resource |
| [oci_core_subnet.segment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_subnet) | resource |
| [oci_core_vcn.segment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/core_vcn) | resource |
| [time_sleep.wait](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [oci_core_drgs.segment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_drgs) | data source |
| [oci_core_internet_gateways.segment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_internet_gateways) | data source |
| [oci_core_nat_gateways.segment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_nat_gateways) | data source |
| [oci_core_route_tables.default_route_table](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_route_tables) | data source |
| [oci_core_service_gateways.segment](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_service_gateways) | data source |
| [oci_core_services.all](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_services) | data source |
| [oci_core_services.storage](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/core_services) | data source |
| [oci_identity_compartments.network](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_compartments) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_input"></a> [input](#input\_input) | Resources identifier from resident module | <pre>object({<br>      internet = string,<br>      nat      = string,<br>      ipv6     = bool,<br>      osn      = string<br>    })</pre> | n/a | yes |
| <a name="input_assets"></a> [assets](#input\_assets) | Retrieve asset identifier | <pre>object({<br>    resident = any<br>  })</pre> | n/a | yes |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | Tenancy Configuration | <pre>object({<br>    id      = string,<br>    class   = number,<br>    buckets = string,<br>    region  = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_resident"></a> [resident](#input\_resident) | Service Configuration | <pre>object({<br>    owner          = string,<br>    name           = string,<br>    label          = string,<br>    stage          = number,<br>    region         = map(string)<br>    compartments   = map(number),<br>    repository     = string,<br>    groups         = map(string),<br>    policies       = map(any),<br>    notifications  = map(any),<br>    tag_namespaces = map(number),<br>    tags           = any<br>  })</pre> | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Network Configuration | <pre>object({<br>    name         = string,<br>    region       = string,<br>    display_name = string,<br>    dns_label    = string,<br>    compartment  = string,<br>    stage        = number,<br>    cidr         = string,<br>    gateways     = any,<br>    route_tables = map(any),<br>    subnets      = map(any),<br>    security_lists = any<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_compartment_id"></a> [compartment\_id](#output\_compartment\_id) | OCID for the network compartment |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | Identifier for the Virtual Cloud Network (VCN) |
| <a name="output_gateways"></a> [gateways](#output\_gateways) | A list of gateways for the Virtual Cloud Network (VCN) |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | A list of subnets for the Virtual Cloud Network (VCN) |
| <a name="output_route_tables"></a> [route\_tables](#output\_route\_tables) | A list of route\_tables for the Virtual Cloud Network (VCN) |
| <a name="output_security_lists"></a> [security\_lists](#output\_security\_lists) | All security lists defined for the Virtual Cloud Network (VCN) |
