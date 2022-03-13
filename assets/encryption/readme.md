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
// --- wallet configuration --- //
module "encryption" {
  source    = "github.com/ocilabs/encryption"
  depends_on = [module.configuration, module.resident]
  providers = {oci = oci.service}
  tenancy   = module.configuration.tenancy
  resident  = module.configuration.resident
  wallet    = module.configuration.wallet
  input = {
    type   = var.encryption_type == "Software" ? "DEFAULT" : "VIRTUAL_PRIVATE"
    secret = var.secret_name
    phrase = var.secret_phrase
  }
  assets = {
    resident = module.resident
  }
}
output "wallet" {
  value = {
    for resource, parameter in module.encryption : resource => parameter
  }
}
// --- wallet configuration --- //
```
## Resources

| Name | Type |
|------|------|
| [null_resource.previous](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [oci_kms_key.wallet](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/kms_key) | resource |
| [oci_kms_sign.wallet](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/kms_sign) | resource |
| [oci_kms_vault.wallet](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/kms_vault) | resource |
| [oci_kms_verify.wallet](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/kms_verify) | resource |
| [oci_vault_secret.wallet](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/resources/vault_secret) | resource |
| [time_sleep.wait](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [oci_identity_compartments.security](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/identity_compartments) | data source |
| [oci_secrets_secretbundle.wallet](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/secrets_secretbundle) | data source |
| [oci_secrets_secretbundle_versions.wallet](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/secrets_secretbundle_versions) | data source |
| [oci_vault_secret.wallet](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/vault_secret) | data source |
| [oci_vault_secrets.wallet](https://registry.terraform.io/providers/hashicorp/oci/latest/docs/data-sources/vault_secrets) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_input"></a> [input](#input\_input) | Schema input for the wallet creation | <pre>object({<br>      type   = string,<br>      secret = string,<br>      phrase = string<br>    })</pre> | n/a | yes |
| <a name="input_tenancy"></a> [tenancy](#input\_tenancy) | Tenancy Configuration | <pre>object({<br>    id      = string,<br>    class   = number,<br>    buckets = string,<br>    region  = map(string)<br>  })</pre> | n/a | yes |
| <a name="input_assets"></a> [assets](#input\_assets) | Retrieve asset identifier | <pre>object({<br>    resident = any<br>    network  = any<br>  })</pre> | n/a | yes |
| <a name="input_resident"></a> [resident](#input\_resident) | Service configuration | <pre>object({<br>    owner          = string,<br>    name           = string,<br>    label          = string,<br>    stage          = number,<br>    region         = map(string)<br>    compartments   = map(number),<br>    repository     = string,<br>    groups         = map(string),<br>    policies       = map(any),<br>    notifications  = map(any),<br>    tag_namespaces = map(number),<br>    tags           = any<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_compartment_id"></a> [compartment\_id](#output\_compartment\_id) | OCID for the security compartment |
| <a name="output_vault_id"></a> [vault\_id](#output\_vault\_id) | Identifier for the key management service (KMS) vault |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | Identifier for the master key, created for the vault |
| <a name="output_wallet_signature"></a> [wallet\_signature](#output\_wallet\_signature) | n/a |
| <a name="output_secret_id"></a> [secret\_id](#output\_secret\_id) | n/a |
