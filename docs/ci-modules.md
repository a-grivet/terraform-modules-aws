# Module CI Guide for `terraform-modules`

This document explains how CI validates shared Terraform modules in the `terraform-modules` repository.

It covers the two complementary workflows that protect module quality:

- `ci-validate.yml`
- `integration-test.yml`

The goal is to explain what each workflow checks, what it does not check, and how to interpret failures when developing or centralizing shared modules.

---

## Table of Contents

- [Purpose](#purpose)
- [CI Validation Layers](#ci-validation-layers)
- [Workflows Covered](#workflows-covered)
- [Static Validation: `ci-validate.yml`](#static-validation-ci-validateyml)
- [Integration Validation: `integration-test.yml`](#integration-validation-integration-testyml)
- [What Each Workflow Catches](#what-each-workflow-catches)
- [What CI Still Does Not Prove](#what-ci-still-does-not-prove)
- [How To Reproduce CI Locally](#how-to-reproduce-ci-locally)
- [How To Read Failures](#how-to-read-failures)
- [Typical Failure Scenarios](#typical-failure-scenarios)

---

## Purpose

The CI strategy for this repository exists to provide two validation layers:

- a fast structural quality gate for each module
- a more realistic integration gate through example root modules

Together, these workflows help ensure that centralized modules are:

- readable
- internally valid
- linted consistently
- usable in a real Terraform root with real provider initialization

This is especially important for a shared module repository, because issues caught here are cheaper to fix than issues discovered later in blueprint repositories.

---

## CI Validation Layers

The repository does not rely on a single monolithic CI job.

Instead, it uses layered validation:

1. static validation
   Checks Terraform formatting, initialization, structural correctness, and linting.

2. integration validation
   Checks example root modules with real provider setup and AWS authentication.

3. documentation validation
   Handled separately by `ci-docs.yml`, which keeps generated README content synchronized with module interfaces.

This document focuses on the first two layers because they are the main CI path for module quality.

---

## Workflows Covered

### `.github/workflows/ci-validate.yml`

This is the baseline validation workflow for shared modules.

Its role is to validate module quality without requiring AWS authentication or remote backend access.

### `.github/workflows/integration-test.yml`

This workflow validates example root modules in an AWS-backed context.

Its role is to catch integration issues that static validation cannot detect well, such as:

- provider alias wiring
- real provider initialization
- AWS identity and environment resolution

---

## Static Validation: `ci-validate.yml`

### What it does

This workflow:

1. discovers module directories dynamically
2. checks Terraform formatting across the repository
3. validates each module independently
4. runs TFLint on each module

### Why it exists

It provides the fastest and most scalable quality gate for shared modules.

It is designed to answer:

- is the code formatted correctly
- can the module initialize in isolation
- is the Terraform structure valid
- does linting detect conventions or provider-specific issues

### Main jobs

#### `discover-modules`

Builds the module list dynamically from `modules/`.

Why this matters:

- new modules enter CI automatically
- the workflow remains scalable
- bootstrap or refactoring phases do not break CI unnecessarily

#### `terraform-fmt`

Runs:

```bash
terraform fmt -check -recursive
```

This enforces canonical formatting across the repository.

#### `validate-modules`

Runs once per module with:

```bash
terraform init -backend=false -input=false
terraform validate
tflint --chdir <module>
```

Why `-backend=false` matters:

- shared modules are not root deployments
- validation should not depend on remote state
- CI stays focused on module quality, not environment wiring

#### `no-modules`

Lets the workflow exit cleanly when no modules are present.

---

## Integration Validation: `integration-test.yml`

### What it does

This workflow:

1. determines the target environment
2. authenticates to AWS through OIDC
3. discovers example root modules
4. runs `terraform init`, `terraform validate`, and `terraform plan` on those examples

### Why it exists

Some issues cannot be caught reliably with static module validation alone.

Examples:

- aliased provider requirements
- realistic provider initialization
- AWS-backed configuration assumptions
- module combinations that only make sense in a root module context

### Main jobs

#### `determine-environment`

Selects the target environment from:

- manual workflow input
- branch naming convention

It also resolves which AWS role should be assumed through OIDC.

#### `integration-test`

This job:

- checks out the repository
- installs Terraform and AWS CLI
- authenticates through GitHub OIDC
- validates and plans each example root module under `examples/`

Why it stops at `terraform plan`:

- enough to validate provider wiring and root module structure
- avoids mutating live infrastructure in this workflow

---

## What Each Workflow Catches

### `ci-validate.yml` is best at catching

- formatting drift
- syntax errors
- invalid references between variables, resources, and outputs
- missing provider constraints
- unused declarations flagged by TFLint

### `integration-test.yml` is best at catching

- provider alias issues
- missing AWS-side assumptions
- root-module integration problems
- environment or OIDC configuration mismatches
- plan-time issues that only appear when modules are composed together

### Why both matter

If the repository only had static validation:

- it could miss example-root integration issues

If it only had integration tests:

- every failure would be slower and harder to diagnose

The two workflows work better together than either would alone.

---

## What CI Still Does Not Prove

Even with both workflows in place, CI does not prove:

- that every module combination is production-safe
- that consumer repositories will have zero-drift plans
- that blueprint-specific remote backends are configured correctly
- that full apply/destroy lifecycles are safe in all accounts

Those concerns are still validated later in:

- blueprint repositories
- consumer-specific plan/apply/destroy workflows
- operational review and approval processes

---

## How To Reproduce CI Locally

### Reproduce static validation

```bash
terraform fmt -recursive
terraform -chdir=modules/<module-name> init -backend=false
terraform -chdir=modules/<module-name> validate
tflint --chdir modules/<module-name>
```

### Reproduce integration validation

For an example root module:

```bash
terraform -chdir=examples/<example-name> init
terraform -chdir=examples/<example-name> validate
terraform -chdir=examples/<example-name> plan
```

This requires the same kind of AWS authentication and provider configuration expected by the example.

---

## How To Read Failures

### If `terraform-fmt` fails

Meaning:

- formatting is inconsistent

Action:

```bash
terraform fmt -recursive
```

### If `terraform init -backend=false` fails in `ci-validate.yml`

Meaning:

- provider installation failed
- provider constraints are inconsistent
- the module structure is incomplete or invalid

Action:

- inspect `versions.tf`
- inspect provider blocks
- verify the module directory is structurally complete

### If `terraform validate` fails

Meaning:

- Terraform found an invalid reference or inconsistent configuration

Action:

- inspect variables, outputs, and resource references
- check for provider alias handling where relevant

### If `tflint` fails

Meaning:

- the code is valid Terraform but violates a linting rule or provider guidance

Action:

- read the exact rule message
- fix the code if it reflects a real issue
- change `.tflint.hcl` only deliberately and repository-wide

### If `integration-test.yml` fails during AWS setup

Meaning:

- environment resolution failed
- OIDC configuration is incorrect
- the wrong AWS role or environment mapping is being used

Action:

- inspect repository variables
- inspect workflow environment logic
- inspect AWS trust policies and OIDC setup

### If `integration-test.yml` fails during `terraform plan`

Meaning:

- the example root module is structurally wrong
- module composition is incomplete
- an AWS-backed assumption is missing or invalid

Action:

- inspect the failing example root
- inspect provider aliases and module wiring
- compare with the expected usage pattern from module READMEs

---

## Typical Failure Scenarios

Common issues in this repository include:

- missing provider constraints in `versions.tf`
- unused variables, locals, or data sources
- provider alias handling for modules such as `acm-cloudfront`
- formatting drift after manual edits
- examples needed to validate aliased-provider or root-module behavior
- environment or role mapping issues in `integration-test.yml`

When diagnosing failures, always start from:

- the failing workflow
- the failing job
- the exact Terraform or TFLint message

That is more reliable than diagnosing from the module topic alone.
