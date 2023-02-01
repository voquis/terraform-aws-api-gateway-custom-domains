# Terraform AWS HTTP API Gateway (v2) with custom domains and Route53 records
Terraform 0.12+ module to create an HTTP API Gateway (v2) with the associated resources for custom domain names.  This module will create:
- an API Gateway
- an API Gateway stage
- API Gateway domain names
- API Gateway mappings for each domain name
- Route53 record for each domain name

To turn off the creation of Route53 records, for example when using wildcard certificates, set `create_route53_records = false`

## Examples
### Wildcard certificate with HTTP proxy integration
Create a wildcard regional ACM certificate:
```terraform
module "acm_api" {
  source      = "voquis/acm-dns-validation/aws"
  version     = "0.0.4"
  zone_id     = "MYZONEID"
  domain_name = "*.api.example.com"
}
```

```terraform
module "api_gateway" {
  source  = "voquis/api-gateway-custom-domains/aws"
  version = "0.0.3"

  name  = "app"
  stage = "default"

  cors_allow_origins = [
    "*",
  ]
  cors_allow_methods = [
    "POST",
  ]
  cors_allow_headers = [
    "content-type",
  ]

  create_route53_records = false

  custom_domain_names = [
    {
      domain_name     = "*.api.example.com"
      certificate_arn = module.acm_api.acm_certificate.arn
      endpoint_type   = "REGIONAL"
      security_policy = "TLS_1_2"
      zone_id         = "MYZONEID"
    }
  ]
}
```

Then create a HTTP Proxy integration:
```terraform
resource "aws_apigatewayv2_route" "default" {
  api_id    = module.api_gateway.apigatewayv2_api.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.default.id}"
}

resource "aws_apigatewayv2_integration" "default" {
  api_id           = module.api_gateway.apigatewayv2_api.id
  integration_type = "HTTP_PROXY"

  integration_method = "ANY"
  integration_uri    = "https://my.example.net/{proxy}"
}
```

To generate multiple route53 records for this wildcard gateway:
```terraform
resource "aws_route53_record" "this_api" {
  for_each = toset(["subdomain1", "subdomain2", "subdomain3", "subdomain4"])

  zone_id = "MYZONEID"
  name    = "${each.value}"
  type    = "A"

  alias {
    name    = module.api_gateway.apigatewayv2_domain_name[0].domain_name_configuration[0].target_domain_name
    zone_id = module.api_gateway.apigatewayv2_domain_name[0].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
```

### HTTP API Gateway (v2) with Lambda integration

Create regional ACM certificates for two different domains (passing through a zone id):
```terraform
module "api_1" {
  source      = "voquis/acm-dns-validation/aws"
  version     = "0.0.4"
  zone_id     = "myzoneid1"
  domain_name = "api-1.example.com"
}

module "api_2" {
  source      = "voquis/acm-dns-validation/aws"
  version     = "0.0.4"
  zone_id     = "myzoneid2"
  domain_name = "api-2.example.net"
}
```

Then create a regional API Gateway that uses the two domains and certificates
```terraform
module "api_gateway" {
  source  = "voquis/api-gateway-custom-domains/aws"
  version = "0.0.3"
  stage   = "mystage"

  cors_allow_origins = [
    "https://app-1.example.com",
    "https://app-2.example.net",
  ]

  cors_allow_methods = [
    "POST"
  ]

  cors_allow_headers = [
    "content-type"
  ]

  custom_domain_names = [
    {
      domain_name     = "api-1.example.com"
      certificate_arn = module.api_1.acm_certificate.arn
      endpoint_type   = "REGIONAL"
      security_policy = "TLS_1_2"
      zone_id         = "myzoneid1"
    },
    {
      domain_name     = "api-2.example.net"
      certificate_arn = module.api_2.acm_certificate.arn
      endpoint_type   = "REGIONAL"
      security_policy = "TLS_1_2"
      zone_id         = "myzoneid2"
    }
  ]
}
```

To integrate a lambda function with the API Gateway:
```terraform
# Integration
module "api_gateway_integration" {
  source             = "voquis/lambda-http-api-integration/aws"
  version            = "0.0.1"
  api_id             = module.api_gateway.apigatewayv2_api.id
  source_arn         = module.api_gateway.apigatewayv2_api.execution_arn
  integration_method = "POST"
  function_name      = "my-lambda-function-name"
  invoke_arn         = "my-lambda-function-invoke-arn"
}

# Route for POST /test
resource "aws_apigatewayv2_route" "test" {
  api_id    = module.api_gateway.apigatewayv2_api.id
  route_key = "POST /test"
  target    = "integrations/${module.api_gateway_integration.apigatewayv2_integration.id}"
}
```
