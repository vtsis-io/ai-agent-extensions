# Terragrunt configuration template
# Copy and adapt this for each new component

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  env              = local.environment_vars.locals.environment

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  aws_region  = local.region_vars.locals.aws_region
}

terraform {
  source = "${get_repo_root()}/<MODULE_PATH>/<module_name>"
}

include {
  path = find_in_parent_folders("root.hcl")
}

# ─── Dependencies ─────────────────────────────────────────────────────────────
# One block per upstream component. Always provide mock_outputs.
# mock_outputs_merge_strategy_with_state valid values: no_merge, shallow, deep, deep_map_only
#   "no_merge"  → dependency already deployed; mocks ignored when real state exists
#   "shallow"   → dependency being created together with this component

dependency "example_dep" {
  config_path = "../example_dep_dir"

  mock_outputs = {
    output_key = "fake-value"
    # ARN example:  "arn:aws:lambda:<region>:<account_id>:function:fake"
    # ID example:   "fake-resource-id"
    # URL example:  "https://fake.execute-api.<region>.amazonaws.com"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "init", "plan", "plan-all"]
  mock_outputs_merge_strategy_with_state  = "no_merge"
}

# ─── Inputs ───────────────────────────────────────────────────────────────────
inputs = {
  # ============================================================================
  # CONFIGURAÇÃO BÁSICA
  # ============================================================================
  resource_name = "my-resource-${local.env}"   # always suffix with env

  # Cross-resource references via dependency outputs:
  # api_id        = dependency.api_gateway.outputs.api_id
  # execution_arn = dependency.api_gateway.outputs.execution_arn
  # lambda_arn    = dependency.my_lambda.outputs.lambda_arn
  # lambda_name   = dependency.my_lambda.outputs.lambda_name

  # SSM secrets — always use local.env, never hardcode the environment name:
  # ssm_path_prefix = "/<project-name>/${local.env}/"
  # ssm_parameters = {
  #   DATABASE_URL = "/<project-name>/${local.env}/database_url"
  # }

  # ============================================================================
  # TAGS — copy exact keys/values from existing components in this project
  # ============================================================================
  tags = {
    Terraform   = "true"
    Environment = local.env
    Service     = "<service-name>"
    Project     = "<project-name>"     # derive from account.hcl or repo name
    ManagedBy   = "Terragrunt"
    Team        = "<team-name>"
  }
}
