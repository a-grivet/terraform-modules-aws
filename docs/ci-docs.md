# Terraform Docs CI

## Table of Contents

- [Purpose](#purpose)
- [Scope](#scope)
- [Documentation Strategy](#documentation-strategy)
- [How The Workflow Works](#how-the-workflow-works)
- [Why Repository-Wide Rendering Is Used](#why-repository-wide-rendering-is-used)
- [Files Involved](#files-involved)
- [Generated Sections](#generated-sections)
- [Local Usage](#local-usage)
- [How To Fix A Failing Docs Workflow](#how-to-fix-a-failing-docs-workflow)
- [Maintainer Expectations](#maintainer-expectations)

## Purpose

This document explains how the `ci-docs.yml` workflow keeps module documentation up to date in the `terraform-modules` repository.

Its role is to make sure each shared module README exposes:

- hand-written usage and design guidance
- generated Terraform reference data
- a stable and readable contract for consumers

This workflow complements `ci-validate.yml`.

- `ci-validate.yml` checks module quality and linting
- `ci-docs.yml` checks and refreshes generated module documentation

## Scope

The documentation workflow is responsible for:

- rendering Terraform reference sections in module READMEs
- detecting outdated generated documentation in pull requests
- refreshing README files automatically on pushes when needed

## Documentation Strategy

The repository uses `terraform-docs` in `inject` mode.

Each module README therefore contains two distinct layers of documentation:

1. hand-written content
   Purpose, usage guidance, notes, constraints, and enterprise context.

2. generated content
   Terraform reference information inserted between:

   - `<!-- BEGIN_TF_DOCS -->`
   - `<!-- END_TF_DOCS -->`

This model is intentional. The generated section documents the module contract, while the manual section explains how and why the module should be used.

## How The Workflow Works

### 1. Module discovery

The workflow first discovers first-level directories under `modules/`.

Why this matters:

- new modules are picked up automatically
- no workflow update is required when a new module is added
- the workflow can exit cleanly when no modules exist yet

### 2. Pull request behavior

On pull requests, the workflow:

- installs `terraform-docs`
- renders documentation for all modules
- checks whether the rendered output differs from committed README files

If a README would change, the workflow fails.

This gives reviewers a clear signal that the module contract changed but the generated documentation was not refreshed in the same pull request.

### 3. Push behavior

On pushes to `dev` or `main`, and on manual dispatch, the workflow:

- installs `terraform-docs`
- renders documentation for all modules
- commits refreshed README files back to the branch when changes are detected

This keeps generated documentation synchronized over time without requiring manual refreshes on every branch update.

## Why Repository-Wide Rendering Is Used

The workflow renders all module READMEs in one controlled pass.

This approach helps because:

- one documentation update produces one coherent commit
- it avoids multiple parallel jobs trying to push to the same branch
- documentation stays synchronized across the repository
- maintainers keep a predictable update mechanism as the module catalog grows

## Files Involved

### Workflow file

- `.github/workflows/ci-docs.yml`

### Terraform Docs configuration

- `.terraform-docs.yml`

This file controls:

- rendering mode
- injected sections
- formatting options
- section ordering

### Module READMEs

- `modules/<module-name>/README.md`

Each module README keeps its hand-written content at the top and receives generated reference sections in the marked block.

## Generated Sections

The generated portion currently renders:

- requirements
- providers
- resources
- inputs
- outputs

This is a good balance for shared enterprise modules: enough contract visibility for consumers without turning the README into a raw dump.

## Local Usage

Developers can refresh module documentation locally before pushing changes.

Example:

```bash
terraform-docs --config .terraform-docs.yml ./modules/acm-alb
```

Run the same command for each modified module.

## How To Fix A Failing Docs Workflow

If `ci-docs.yml` fails in a pull request, the usual fix is:

1. identify which module changed
2. refresh its README with `terraform-docs`
3. review the generated section
4. commit the updated README

Typical command:

```bash
terraform-docs --config .terraform-docs.yml ./modules/<module-name>
```

Then:

```bash
git add modules/<module-name>/README.md
git commit -m "docs(terraform): refresh module README"
```

If several modules changed, repeat the refresh for each one.

## Maintainer Expectations

When a module changes, maintainers are expected to:

1. update the Terraform code
2. refresh the module README
3. review the generated interface carefully
4. keep hand-written sections focused on usage and design intent

This separation is deliberate:

- source code explains implementation
- manual README content explains usage
- generated docs explain the exact module interface
