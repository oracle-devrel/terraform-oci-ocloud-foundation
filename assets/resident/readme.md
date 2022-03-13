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
// --- operation controls --- //
provider "oci" {
  alias  = "home"
  region = module.configuration.tenancy.region.key
}
module "resident" {
  source = "github.com/ocilabs/resident"
  depends_on = [module.configuration]
  providers = {oci = oci.home}
  tenancy   = module.configuration.tenancy
  resident  = module.configuration.resident
  input = {
    # Reference to the deployment root. The service is setup in an encapsulating child compartment 
    parent_id     = var.parent
    # Enable compartment delete on destroy. If true, compartment will be deleted when `terraform destroy` is executed; If false, compartment will not be deleted on `terraform destroy` execution
    enable_delete = alltrue([var.stage != "PROD" ? true : false, var.amend])
  }
}
output "resident" {
  value = {
    for resource, parameter in module.resident : resource => parameter
  }
}
// --- operation controls --- //
```

## Resources

| Name | Type |
|------|------|
| [null_resource.previous](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [oci_identity_compartment.domains](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_compartment) | resource |
| [oci_identity_compartment.resident](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_compartment) | resource |
| [oci_identity_group.resident](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_group) | resource |
| [oci_identity_policy.domains](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_policy) | resource |
| [oci_identity_tag.resident](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_tag) | resource |
| [oci_identity_tag_default.resident](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_tag_default) | resource |
| [oci_identity_tag_namespace.resident](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/identity_tag_namespace) | resource |
| [oci_ons_notification_topic.resident](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/ons_notification_topic) | resource |
| [oci_ons_subscription.resident](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/ons_subscription) | resource |
| [time_sleep.wait](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [oci_identity_tenancy.resident](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_tenancy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_input"></a> [input](#input\_input) | Settings for the service resident | <pre>object({<br>    parent_id     = string,<br>    enable_delete = bool<br>  })</pre> | n/a | yes |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | Tenancy Configuration | <pre>object({<br>    class   = number,<br>    buckets = string,<br>    id      = string,<br>    region  = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_resident"></a> [resident](#input\_resident) | Service Configuration | <pre>object({<br>    owner          = string,<br>    name           = string,<br>    label          = string,<br>    stage          = number,<br>    region         = map(string)<br>    compartments   = map(number),<br>    repository     = string,<br>    groups         = map(string),<br>    policies       = map(any),<br>    notifications  = map(any),<br>    tag_namespaces = map(number),<br>    tags           = any<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The Oracle Cloud Identifier (OCID) for the service compartment. It allows to retrieve the compartment details using data blocks. |
| <a name="output_parent_id"></a> [parent\_id](#output\_parent\_id) | The OCID of the parent compartment for the service. |
| <a name="output_compartment_ids"></a> [compartment\_ids](#output\_compartment\_ids) | A list of OCID for the child compartments, representing the different administration domain. |
| <a name="output_namespace_ids"></a> [namespace\_ids](#output\_namespace\_ids) | A list of tag\_namespaces created for the service compartment in the tenancy. This allows to define separate tags for every service. Namespace names have to be unique. |
| <a name="output_tag_ids"></a> [tag\_ids](#output\_tag\_ids) | A list of tags, created in the tag namespaces. |
| <a name="output_group_ids"></a> [group\_ids](#output\_group\_ids) | A list of groups, created for the service in the tenancy or root compartment. This allows to define separate policies for every service. Group names have to be unique. |
| <a name="output_notifications"></a> [notifications](#output\_notifications) | A list of notifcation topics, defined for a resident. |
| <a name="output_policy_ids"></a> [policy\_ids](#output\_policy\_ids) | A list of policy controls, defined for the different admistrator roles. Policy names correspond with the groups defined on tenancy level. |
| <a name="output_freeform_tags"></a> [freeform\_tags](#output\_freeform\_tags) | A list of predefined freeform tags, referenced in the provisioning process. |
| <a name="output_defined_tags"></a> [defined\_tags](#output\_defined\_tags) | A list of actionable tags, utilized for operation, budget- and compliance control. |
