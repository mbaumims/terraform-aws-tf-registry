locals {
  friendly_hostname_base_url = "https://${var.friendly_hostname.host}"
}

resource "aws_api_gateway_domain_name" "main" {
  domain_name              = var.friendly_hostname.host
  regional_certificate_arn = var.friendly_hostname.acm_certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "main" {
  api_id      = aws_api_gateway_deployment.live.rest_api_id
  stage_name  = aws_api_gateway_deployment.live.stage_name
  domain_name = aws_api_gateway_domain_name.main.domain_name
}