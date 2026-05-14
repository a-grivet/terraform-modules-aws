# Elastic Container Registry

> Terraform module that creates an Elastic Container Registry repository with lifecycle management options.

---

## What it does

- creates an ECR repository for container images
- supports image scanning configuration
- supports lifecycle rules to control image retention
- exposes repository attributes used by CI/CD and ECS deployments

---

## Usage

```hcl
module "ecr" {
  source = "git::ssh://git@github.com/your-org/terraform-modules.git//modules/ecr?ref=v1.0.0"

  project_name = "my-app"
  environment  = "dev"
}
```

---

## Notes

- this module is commonly used by ECS-based blueprints and their CI/CD pipelines
- repository lifecycle settings are especially useful to keep non-production registries clean

---

<!-- BEGIN_TF_DOCS -->
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.7.4 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_id | Application identifier (AppId) as registered in the your application catalog. | `string` | n/a | yes |
| environment | Environment code: c (poc), t (test/sandbox), d (dev), s (stage), p (prod). | `string` | n/a | yes |
| encryption\_type | Encryption type for images at rest: AES256 or KMS | `string` | `"AES256"` | no |
| image\_tag\_mutability | Image tag mutability setting: MUTABLE or IMMUTABLE | `string` | `"MUTABLE"` | no |
| kms\_key\_arn | ARN of the KMS key for image encryption when encryption\_type is KMS | `string` | `null` | no |
| label | Optional label to distinguish multiple instances of the same resource type (e.g., 'eu-west-3a'). | `string` | `null` | no |
| lifecycle\_policy\_max\_image\_count | Maximum number of tagged images to retain | `number` | `10` | no |
| lifecycle\_policy\_tag\_prefix\_list | List of image tag prefixes to apply the lifecycle policy to | `list(string)` | <pre>[<br/>  "v",<br/>  "release",<br/>  "dev"<br/>]</pre> | no |
| lifecycle\_policy\_untagged\_days | Number of days to retain untagged images before deletion | `number` | `7` | no |
| repository\_policy\_json | JSON-formatted ECR repository policy for custom permissions | `string` | `null` | no |
| scan\_on\_push | Enable automatic image scanning for vulnerabilities when images are pushed | `bool` | `true` | no |
| tags | Common tags applied to repository resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudwatch\_log\_group\_name | Standard CloudWatch Log Group name for ECR repository events |
| docker\_login\_command | AWS CLI command to authenticate Docker to this ECR registry |
| encryption\_type | Encryption type used for images at rest (AES256 or KMS) |
| example\_docker\_push\_command | Example docker push command for this repository |
| example\_ecs\_image\_uri | Example image URI to use in ECS task definitions |
| image\_scanning\_enabled | Whether image scanning on push is enabled |
| image\_tag\_mutability | Image tag mutability setting (MUTABLE or IMMUTABLE) |
| kms\_key | KMS key ARN used for encryption, or null if using AES256 |
| lifecycle\_policy\_text | The lifecycle policy document applied to the repository |
| repository\_arn | Full ARN of the ECR repository |
| repository\_name | Name of the ECR repository |
| repository\_registry\_id | Registry ID (AWS account ID) where the repository exists |
| repository\_url | URL of the ECR repository used for docker push and pull commands |
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
<!-- END_TF_DOCS -->
