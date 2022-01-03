output "apigatewayv2_api" {
  value = aws_apigatewayv2_api.this
}

output "apigatewayv2_domain_name" {
  value = aws_apigatewayv2_domain_name.this
}

output "apigatewayv2_api_mapping" {
  value = aws_apigatewayv2_api_mapping.this
}

output "apigatewayv2_stage" {
  value = aws_apigatewayv2_stage.this
}

output "route53_record" {
  value = aws_route53_record.this
}
