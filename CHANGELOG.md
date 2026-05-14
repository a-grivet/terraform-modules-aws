# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-14

### Added
- Initial versioned release of the centralized Terraform module catalog
- Shared Terraform modules for your blueprint repositories:
  - `acm-alb`
  - `acm-cloudfront`
  - `alb`
  - `asg`
  - `aurora`
  - `backend`
  - `cloudfront`
  - `dynamodb`
  - `ecr`
  - `ecs`
  - `elasticache`
  - `iam`
  - `kms`
  - `logs`
  - `route53`
  - `s3-origin`
  - `secrets-manager`
  - `security-groups`
  - `ssm-parameters`
- Repository-level validation workflows:
  - `ci-validate.yml`
  - `ci-docs.yml`
  - `integration-test.yml`
- Repository documentation and support files:
  - `README.md`
  - `docs/github-oidc-setup.md`
  - `docs/ci-validation.md`
  - `docs/ci-docs.md`
  - `examples/README.md`

### Changed
- Module consumption model aligned on Git tag versioning for blueprint repositories

### Security
- OIDC-based AWS access model documented for workflows requiring cloud authentication

---

## Template for Future Releases

## [Unreleased]

### Added
- New modules or new capabilities
- Centralized `monitoring` module covering:
  - `basic-iaas`
  - `ecs-standalone`
  - `static-website`

### Changed
- Updates to existing modules or repository workflows

### Deprecated
- Soon-to-be removed behaviors or module interfaces

### Removed
- Removed modules, inputs, outputs, or workflows

### Fixed
- Bug fixes and validation corrections

### Security
- Security improvements and fixes
