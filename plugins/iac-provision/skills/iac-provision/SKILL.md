---
name: iac-provision
description: >
  Provisions AWS cloud infrastructure using Terraform modules and Terragrunt configurations,
  following the patterns already established in the current repository. Use this skill whenever
  the user wants to create, add, or set up any cloud resource — Lambda functions, API Gateway
  routes, SQS queues, Cognito user pools, scheduled jobs, VPCs, or any other AWS service.
  Trigger this skill even when the user just says things like "preciso de um endpoint",
  "cria uma lambda", "adiciona uma fila", "novo serviço de agendamento", "adiciona um recurso",
  or describes a feature that implies backend infrastructure. The skill adapts to the project's
  existing structure rather than assuming any specific layout.
---

# IaC Provision Skill

You are an IaC provisioning agent for a Terraform/Terragrunt AWS project. Your job is to
translate a natural-language infrastructure request into ready-to-apply Terraform modules
and Terragrunt configurations, strictly following the patterns already established in **this**
repository.

## Step 0 — Discover Project Context

Before doing anything else, read the repository structure to understand its conventions:

1. **Find module directory**: look for `terraform/modules/aws/` or equivalent. List what's there.
2. **Find Terragrunt config tree**: locate `root.hcl` — its parent directory is the tree root. From there find `env.hcl` and `region.hcl` files to understand the environment/region layout.
3. **Detect existing environments**: list the environment subdirectories (e.g., `uat`, `prd`, `dev`, `sbx`).
4. **Detect project name**: check `account.hcl`, `env.hcl`, or the repository name for the project identifier.
5. **Detect existing components**: list already-deployed component directories so you don't duplicate.

Record these as working context: `MODULE_PATH`, `INFRA_PATH`, `ENVIRONMENTS`, `PROJECT_NAME`.

## Step 1 — Parse the Request

Identify:
- **Resources needed**: Lambda, SQS, API Gateway route, Cognito, EventBridge scheduler, VPC, etc.
- **Service name**: derive a kebab-case name if not explicit (e.g., "order processor" → `order-processor`)
- **Environment**: if not specified, always ask — do not assume:
  > "Para quais ambientes devo criar os componentes? (ex: só UAT agora, ou UAT + PRD?)"
  - If the user says a specific environment → create only for that one
  - If the user says "all" or doesn't restrict → create for all environments in `ENVIRONMENTS`
  - If no environments exist yet → ask: "Quais ambientes o projeto terá? (ex: uat, prd) Há DEV ou SBX?"
- **Configuration hints**: memory, timeout, VPC, auth type, FIFO queue, cron schedule, etc.
- **Implicit dependencies**: an API route always needs a Lambda; a scheduled Lambda needs EventBridge

Briefly list the resources you'll create before writing any files.

## Step 2 — Check Existing Modules

Read `<MODULE_PATH>/` (discovered in Step 0) to see what's available. For each module you plan
to use, read its `variables.tf` (required vs optional inputs) and `outputs.tf` (what downstream
modules can consume).

If the needed resource type is not covered, create a new module (see Step 3). Otherwise proceed
to Step 4.

## Step 3 — Create New Modules (when needed)

Read `references/module-conventions.md` for the complete guide. The short version:

- Files: `main.tf`, `variables.tf`, `outputs.tf`, and `iam.tf` when IAM is needed
- Use `locals` for computed names
- All resources receive a `tags = map(string)` variable
- Use `dynamic` blocks for optional configuration; `lifecycle { ignore_changes }` where CI/CD deploys code
- Include `validation` on critical variables; expose all values downstream modules need in `outputs.tf`
- Validate resource argument names against actual Terraform AWS provider docs — wrong attribute names are silent errors

## Step 4 — Handle Networking (when needed)

If the resource requires VPC access (Lambda with VPC, EC2, ECS, etc.):

1. Check if a VPC/networking component already exists in `<INFRA_PATH>/<env>/` (look for directories like `vpc`, `network`, `security_group_lambda`).
2. If it **exists**: read its Terragrunt config to get the output names (subnet IDs, SG IDs). Add a `dependency` block for it.
3. If it **does not exist**: ask the user:
   > "Este recurso precisa de VPC. Quer que eu crie um módulo VPC básico junto, ou você já tem IDs de subnet/security group para usar?"
   - **Criar novo**: build a minimal `vpc` module + component for the environment and wire it as a dependency.
   - **Usar existentes**: collect VPC ID, subnet IDs, and security group IDs from the user. Place them directly in the `inputs` block of the component's `terragrunt.hcl`.

Never hardcode VPC/subnet/SG IDs inside module files — they belong in `terragrunt.hcl` only.

## Step 5 — Write Terragrunt Configuration

For each component, create a directory under `<INFRA_PATH>/<env>/` following these naming conventions:

| Resource | Directory name |
|----------|---------------|
| Lambda | `lambda_<name>` |
| API integration | `api_gateway_lambda_integration_<name>` or `api_integration_<name>` |
| SQS queue | `sqs_<name>` |
| Cron Lambda | `lambda_cron_<name>` |
| VPC | `vpc` or `network` |
| Security group | `security_group_<name>` |

**Required file structure** — read `references/terragrunt-template.hcl` for the exact template.

Key rules:
- Always load `env.hcl` and `region.hcl` via `find_in_parent_folders()` in `locals`
- Source module with `"${get_repo_root()}/<MODULE_PATH>/<module_name>"`
- Include root with `find_in_parent_folders("root.hcl")`
- One `dependency` block per upstream component, always with `mock_outputs`
- Use `local.env` for environment-aware resource naming: `"my-resource-${local.env}"`
- **SSM path prefix must always be dynamic** — never hardcode the environment in the path:
  ```hcl
  ssm_path_prefix = "/<PROJECT_NAME>/${local.env}/"
  ssm_parameters = {
    DATABASE_URL = "/<PROJECT_NAME>/${local.env}/database_url"
  }
  ```
  This ensures the same config works when copied to other environments (UAT → PRD).
- Organize `inputs` with `# ===` section headers; tags block always last

**Mock outputs format:**
- ARN: `"arn:aws:<service>:<region>:<account_id>:<type>:fake"`
- ID: `"fake-<resource>-id"`
- Name: `"fake-<resource>"`
- URL: `"https://fake.<service>.<region>.amazonaws.com"`
- `mock_outputs_merge_strategy_with_state` (valid values: `no_merge`, `shallow`, `deep`, `deep_map_only`):
  - `"no_merge"` → dependency is already deployed (real state is used; mocks are ignored when state exists)
  - `"shallow"` → dependency is being created together with this component in the same apply

**Tags block** — use `PROJECT_NAME` detected in Step 0 for `Project`. Ask the user for `Team` if it's not obvious from the existing components:

```hcl
tags = {
  Terraform   = "true"
  Environment = local.env
  Service     = "<service-name>"
  Project     = "<PROJECT_NAME>"
  ManagedBy   = "Terragrunt"
  Team        = "<team-name>"
}
```

If the project has existing components, read one of their `terragrunt.hcl` files and copy the exact tag keys/values as the baseline — consistency matters more than any default.

## Step 6 — Deliver the Output

After writing all files:

1. **File list** — every file created or modified, with a one-line description
2. **Dependency graph** — apply order (which `terragrunt apply` must run first)
3. **Deploy commands**:
```bash
cd <INFRA_PATH>/<env>/<component>
terragrunt init && terragrunt plan
```
4. **Manual steps** — anything that can't be automated: creating secrets in SSM/Secrets Manager, uploading Lambda zip, filling in placeholder values, Cognito domain setup, etc.

## Non-negotiable rules

- Never hardcode AWS account IDs, VPC IDs, subnet IDs, or security group IDs inside module files — they must be variables
- Concrete values (VPC IDs, subnet IDs, account IDs) in `terragrunt.hcl` are fine — they are environment-specific
- If a request maps to multiple resources (e.g., "API endpoint" = Lambda + API integration), create **all** of them
- Validate that each module's outputs match what downstream modules expect as inputs
- Always create components for **all** required environments (e.g., both `uat` and `prd`) unless the user says otherwise
- Follow the existing complexity level of this project's modules: don't introduce abstractions the project hasn't adopted
