# -------------------------------------------------------------------------------------------------
# HTTP API Gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api
# -------------------------------------------------------------------------------------------------

resource "aws_apigatewayv2_api" "this" {
  name          = var.name
  protocol_type = var.protocol_type
  cors_configuration {
    allow_origins     = var.cors_allow_origins
    allow_methods     = var.cors_allow_methods
    allow_headers     = var.cors_allow_headers
    expose_headers    = var.cors_expose_headers
    allow_credentials = var.cors_allow_cedentials
    max_age           = var.cors_max_age
  }
}

# -------------------------------------------------------------------------------------------------
# API Gateway Domain Name
# Creates a resource for each input list item
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api
# -------------------------------------------------------------------------------------------------

resource "aws_apigatewayv2_domain_name" "this" {
  for_each = { for i, v in var.custom_domain_names : i => v }

  domain_name = each.value.domain_name

  domain_name_configuration {
    certificate_arn = each.value.certificate_arn
    endpoint_type   = each.value.endpoint_type
    security_policy = each.value.security_policy
  }
}

# -------------------------------------------------------------------------------------------------
# API Gateway Mapping
# Maps each custom domain to the API
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api_mapping
# -------------------------------------------------------------------------------------------------

resource "aws_apigatewayv2_api_mapping" "this" {
  for_each = aws_apigatewayv2_domain_name.this

  api_id      = aws_apigatewayv2_api.this.id
  domain_name = each.value.id
  stage       = aws_apigatewayv2_stage.this.id
}

# -------------------------------------------------------------------------------------------------
# Stage for API
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage
# -------------------------------------------------------------------------------------------------

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = var.stage
  auto_deploy = var.stage_auto_deploy
}


# -------------------------------------------------------------------------------------------------
# Route53 alias record for each custom domain name
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
# -------------------------------------------------------------------------------------------------

resource "aws_route53_record" "this" {
  for_each = { for i, v in(var.create_route53_records ? var.custom_domain_names : []) : i => v }

  name    = each.value.domain_name
  type    = "A"
  zone_id = each.value.zone_id
  alias {
    name                   = aws_apigatewayv2_domain_name.this[each.key].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.this[each.key].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
