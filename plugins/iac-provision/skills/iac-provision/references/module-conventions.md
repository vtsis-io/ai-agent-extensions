# Module Conventions

## File structure

```
terraform/modules/aws/<module_name>/
├── main.tf        # Resource definitions
├── variables.tf   # Input variables
├── outputs.tf     # Outputs
└── iam.tf         # IAM roles/policies (only when needed)
```

## main.tf patterns

Always open with `locals` for computed names:
```hcl
locals {
  resource_name = var.name
}
```

Use `dynamic` blocks for optional configuration:
```hcl
dynamic "vpc_config" {
  for_each = length(var.subnet_ids) > 0 ? [1] : []
  content {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
}
```

Use `lifecycle` where CI/CD deploys code (never let Terraform redeploy on zip hash change):
```hcl
lifecycle {
  ignore_changes = [source_code_hash, filename, s3_key, s3_bucket, image_uri]
}
```

Use count for optional resources:
```hcl
resource "aws_lambda_function_url" "url" {
  count         = var.create_lambda_url ? 1 : 0
  function_name = aws_lambda_function.lambda.function_name
  ...
}
```

## variables.tf patterns

Always include type and description. Use the language already adopted by the project (check existing variables.tf files). Use `default` for optional vars:

```hcl
variable "lambda_name" {
  type        = string
  description = "Nome da função lambda. Ex: order-processor"
}

variable "lambda_timeout" {
  type        = number
  default     = 30
  description = "Timeout em segundos da função Lambda (max 900)"
}

variable "tags" {
  type    = map(string)
  default = {}
}
```

Add `validation` blocks on critical variables:
```hcl
variable "queue_name" {
  type        = string
  description = "Nome da fila SQS"
  validation {
    condition     = length(var.queue_name) >= 1 && length(var.queue_name) <= 80
    error_message = "queue_name deve ter entre 1 e 80 caracteres."
  }
}
```

## outputs.tf patterns

Always expose: the resource's ARN, its name/ID, and anything a downstream module needs.

```hcl
output "lambda_arn" {
  value       = aws_lambda_function.lambda.arn
  description = "ARN da função Lambda"
}

output "lambda_name" {
  value       = aws_lambda_function.lambda.function_name
  description = "Nome da função Lambda"
}
```

For optional resources, guard with ternary:
```hcl
output "lambda_url" {
  value       = var.create_lambda_url ? aws_lambda_function_url.url[0].function_url : null
  description = "URL pública da Lambda (se criada)"
}
```

## iam.tf patterns

Create an IAM role + policy attachment. Attach a basic execution policy, extend with `inline_policies`:

```hcl
resource "aws_iam_role" "role" {
  name = "${var.resource_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies
  name     = each.key
  role     = aws_iam_role.role.id
  policy   = each.value
}
```

## Terraform AWS provider — common resource attributes

Verify attribute names before writing. Common pitfalls:

| Resource | Wrong | Correct |
|---------|-------|---------|
| `aws_sqs_queue` | `queue_arn` | `.arn` |
| `aws_lambda_function` | `function_arn` | `.arn` |
| `aws_apigatewayv2_api` | `api_endpoint_url` | `.api_endpoint` |
| `aws_cognito_user_pool` | `pool_id` | `.id` |
| `aws_cloudwatch_log_group` | `log_group_name` | `.name` |
