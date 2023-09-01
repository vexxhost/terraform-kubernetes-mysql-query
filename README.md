<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.23.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.23.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_job.query](https://registry.terraform.io/providers/hashicorp/kubernetes/2.23.0/docs/resources/job) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | Additional environment variables to pass to the container | `map(string)` | `{}` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | Hostname of the database | `string` | n/a | yes |
| <a name="input_image"></a> [image](#input\_image) | Image to use for the database client | `string` | `"docker.io/library/mariadb:11"` | no |
| <a name="input_job_name"></a> [job\_name](#input\_job\_name) | Name of the job running the query | `string` | n/a | yes |
| <a name="input_job_namespace"></a> [job\_namespace](#input\_job\_namespace) | Namespace for the job running the query | `string` | n/a | yes |
| <a name="input_query"></a> [query](#input\_query) | Query to run | `string` | n/a | yes |
| <a name="input_root_password_secret_key"></a> [root\_password\_secret\_key](#input\_root\_password\_secret\_key) | Key of the secret containing the root password | `string` | `"root"` | no |
| <a name="input_root_password_secret_name"></a> [root\_password\_secret\_name](#input\_root\_password\_secret\_name) | Name of the secret containing the root password | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->