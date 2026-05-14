# Terraform Modules

[![Terraform](https://img.shields.io/badge/Terraform-1.12+-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Shared%20Modules-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![Release](https://img.shields.io/badge/Release-Git%20Tags-blue)](#release-and-versioning-model)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

> **Shared Terraform module catalog providing reusable AWS infrastructure patterns.**

---

## Table of Contents

- [Available Modules](#available-modules)
- [How To Consume a Module](#how-to-consume-a-module)
- [Release And Versioning Model](#release-and-versioning-model)
- [Recommended Consumer Workflow](#recommended-consumer-workflow)
- [Repository Structure](#repository-structure)
- [Naming Convention](#naming-convention)
- [Quality And Validation](#quality-and-validation)
- [CI And Maintainer Documentation](#ci-and-maintainer-documentation)
- [Contributing And Releasing](#contributing-and-releasing)
- [License](#-license)

---

## Available Modules

The repository currently provides the following shared modules:
Click a module name to open its detailed README.

| Module | Purpose |
| --- | --- |
| [`acm-alb`](./modules/acm-alb/README.md) | ACM certificate provisioning and DNS validation for ALB use cases |
| [`acm-cloudfront`](./modules/acm-cloudfront/README.md) | ACM certificate provisioning and DNS validation for CloudFront use cases |
| [`alb`](./modules/alb/README.md) | Application Load Balancer, listeners, target groups, and alarms |
| [`asg`](./modules/asg/README.md) | Auto Scaling Group and launch template configuration |
| [`aurora`](./modules/aurora/README.md) | Aurora cluster, instances, subnet groups, and parameter groups |
| [`backend`](./modules/backend/README.md) | S3 and KMS resources used for Terraform remote state bootstrap |
| [`cloudfront`](./modules/cloudfront/README.md) | CloudFront distribution, OAC, and response headers policy |
| [`dynamodb`](./modules/dynamodb/README.md) | DynamoDB tables and related configuration |
| [`ecr`](./modules/ecr/README.md) | ECR repositories and lifecycle configuration |
| [`ecs`](./modules/ecs/README.md) | ECS cluster, services, task definitions, and IAM resources |
| [`elasticache`](./modules/elasticache/README.md) | ElastiCache resources and related configuration |
| [`iam`](./modules/iam/README.md) | Reusable IAM roles, policies, and attachments |
| [`kms`](./modules/kms/README.md) | KMS keys, aliases, and policies |
| [`logs`](./modules/logs/README.md) | S3 resources dedicated to centralized logging |
| [`monitoring`](./modules/monitoring/README.md) | CloudWatch dashboards, SNS alerting, and architecture-specific alarms |
| [`route53`](./modules/route53/README.md) | Route53 records and DNS integration resources |
| [`s3-origin`](./modules/s3-origin/README.md) | S3 origin bucket resources for CloudFront-backed websites |
| [`secrets-manager`](./modules/secrets-manager/README.md) | Secrets Manager secrets and generated secret values |
| [`security-groups`](./modules/security-groups/README.md) | Security groups and rule sets for common blueprint patterns |
| [`ssm-parameters`](./modules/ssm-parameters/README.md) | SSM Parameter Store entries for application configuration |

---

## How To Consume a Module

Blueprint repositories should reference released module versions through Git tags.

Example:

```hcl
module "ecs" {
  source = "git::ssh://git@github.com/your-org/terraform-modules.git//modules/ecs?ref=v1.0.0"

  app_id      = "myappid"
  environment = "d"
}
```

Benefits of consuming a released tag:

- reproducible deployments across consumer repositories
- controlled upgrades through explicit version changes
- clearer traceability between a blueprint and the module version it uses

---

## Release And Versioning Model

Module releases are published through semantic Git tags such as `v1.0.0`.

Each release should:

1. correspond to validated module content in this repository
2. be documented in [CHANGELOG.md](./CHANGELOG.md)
3. be consumed explicitly by blueprint repositories

When module changes need to be published, create a new version tag rather than reusing an existing one.

---

## Recommended Consumer Workflow

The recommended workflow for blueprint repositories is:

1. identify the module needed from the catalog
2. reference the required released tag in the Terraform `source`
3. update the consuming blueprint repository
4. validate `plan`, `apply`, and `destroy` in the consumer repository

---

## Repository Structure

```text
modules/              Shared Terraform modules
examples/             Validation examples and targeted usage examples
docs/                 Supporting documentation for CI, OIDC, and tooling
.github/workflows/    Validation, docs, and integration workflows
CHANGELOG.md          Release history for published module versions
README.md             Repository entry point
```

---

## Naming Convention

All AWS resources created by these modules follow the **organization naming convention**.  
Full governance reference: [Organization Naming Conventions)

---

### Generic Pattern

```
<prefix> - [np] - <app_id> - <env> - [label]
   1          2       3         4        5
```

| Segment | Mandatory | Managed by | Description |
|---|---|---|---|
| **1. prefix** | Yes | Module (internal) | AWS resource type identifier — set automatically, transparent to the caller |
| **2. np** | Non-prod only | Module (internal) | Added automatically when `environment != "p"` |
| **3. app_id** | Yes | Caller (`var.app_id`) | AppId as registered in the your application catalog |
| **4. env** | Yes | Caller (`var.environment`) | Environment code (see table below) |
| **5. label** | No | Caller (`var.label`) | Optional suffix to distinguish multiple instances of the same resource |

---

### Environment Codes

| Code | Environment |
|---|---|
| `c` | PoC |
| `t` | Test / Sandbox |
| `d` | Dev |
| `s` | Stage |
| `p` | Production |

---

### Variables to Provide

Every module that creates named AWS resources expects these three variables:

```hcl
app_id      = "myappid"   # Mandatory — AppId from the your application catalog
environment = "d"         # Mandatory — one of: c, t, d, s, p
label       = "api"       # Optional  — distinguishes multiple instances
```

> **Note:** Segments 1 (prefix) and 2 (np) are computed internally by each module.
> You do not need to pass them — the correct prefix and np flag are applied automatically.

---

### Resource Prefixes by Module

| Module | AWS Resource | Prefix | Example (prod) | Example (dev) |
|---|---|---|---|---|
| `alb` | Application Load Balancer | `alb` | `alb-myappid-p` | `alb-np-myappid-d` |
| `alb` | Target Group | `tg` | `tg-myappid-p` | `tg-np-myappid-d` |
| `asg` | Auto Scaling Group | `asg` | `asg-myappid-p` | `asg-np-myappid-d` |
| `aurora` | RDS Cluster / Instances | `rds` | `rds-myappid-p` | `rds-np-myappid-d` |
| `cloudfront` | CloudFront Distribution | `cf` | `cf-myappid-p` | `cf-np-myappid-d` |
| `dynamodb` | DynamoDB Tables | `ddb` | `ddb-myappid-p-<table>` | `ddb-np-myappid-d-<table>` |
| `ecr` | ECR Repository | `ecr` | `ecr-myappid-p` | `ecr-np-myappid-d` |
| `ecs` | ECS Cluster | `ecs` | `ecs-myappid-p` | `ecs-np-myappid-d` |
| `ecs` | ECS Service | `ecs` | `ecs-myappid-p-svc` | `ecs-np-myappid-d-svc` |
| `ecs` | IAM Roles (ECS) | `org-rol` | `org-rol-myappid-p-ecs-exec` | `org-rol-np-myappid-d-ecs-exec` |
| `elasticache` | ElastiCache | `elcch` | `elcch-myappid-p` | `elcch-np-myappid-d` |
| `iam` | IAM Roles (EC2) | `org-rol` | `org-rol-myappid-p` | `org-rol-np-myappid-d` |
| `kms` | KMS Key Alias | `kms` | `alias/kms-myappid-p-<key>` | `alias/kms-np-myappid-d-<key>` |
| `logs` | S3 Logs Bucket | `s3` | `s3-myappid-p-logs-<account_id>` | `s3-np-myappid-d-logs-<account_id>` |
| `monitoring` | SNS Topic / Alarms | `sns` | `sns-myappid-p-alerts` | `sns-np-myappid-d-alerts` |
| `s3-origin` | S3 Origin Bucket | `s3` | `s3-myappid-p-origin-<account_id>` | `s3-np-myappid-d-origin-<account_id>` |
| `secrets-manager` | Secrets Manager Secret | `sm` | `sm-myappid-p-<secret>` | `sm-np-myappid-d-<secret>` |
| `security-groups` | Security Groups | `sec-gp` | `sec-gp-myappid-p` | `sec-gp-np-myappid-d` |
| `ssm-parameters` | SSM Parameters | *(path)* | `/myappid/p/database/...` | `/myappid/d/database/...` |

> **S3 bucket names** include the AWS account ID as a suffix to guarantee global uniqueness (AWS requirement).

---

### Complete Example

```hcl
module "alb" {
  source = "git::ssh://git@github.com/your-org/terraform-modules.git//modules/alb?ref=v1.0.0"

  app_id      = "myappid"   # AppId from the your application catalog
  environment = "d"         # "np-" prefix added automatically for non-prod
  label       = "web"       # Optional

  # Other required variables...
}

# Resources created:
#   ALB          → alb-np-myappid-d-web
#   Target Group → tg-np-myappid-d-web
```

---

## Quality And Validation

This repository includes baseline quality checks to validate modules before they are consumed:

- `terraform fmt`
- `terraform init -backend=false`
- `terraform validate`
- `tflint`
- integration-oriented validation where applicable

The current workflows are designed to keep module validation fast, reproducible, and independent from blueprint-specific state management.

---

## CI And Maintainer Documentation

This repository also includes supporting documentation for contributors and maintainers who need to understand how validation and documentation generation are handled.

- [Module CI Guide](./docs/ci-modules.md)  
  explains how shared modules are validated through both static checks and integration tests

- [Terraform Docs CI](./docs/ci-docs.md)  
  explains how module README files are generated and kept aligned with Terraform code

---

## Contributing And Releasing

When contributing to this repository:

1. update or add the relevant module under `modules/`
2. validate the module through the repository workflows
3. update [CHANGELOG.md](./CHANGELOG.md) when publishing a new release
4. create and push a new semantic version tag for consumer repositories

---

## 📄 License

**This project is licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.**

---

**Built with ❤️ by Auré**
