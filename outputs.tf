locals {
  service_base_url = (
    local.friendly_hostname_base_url != "" ? local.friendly_hostname_base_url : aws_api_gateway_deployment.live.invoke_url
  )
}

output "services" {
  description = "A service discovery configuration map for the deployed services. A JSON-serialized version of this should be published at /.well-known/terraform.json on an HTTPS server running at the friendly hostname for this registry."
  value = {
    # We have to do some replacement shenanigans here to ensure we don't
    # double up slashes if the root path also starts with a slash.
    "modules.v1" = replace("${local.service_base_url}//${aws_api_gateway_resource.modules_root.path}/", "/\\/\\/\\//", "/")
  }
}

output "rest_api_id" {
  description = "The id of the API Gateway REST API managed by this module."
  value       = aws_api_gateway_rest_api.root.id
}

output "rest_api_stage_name" {
  description = "The id of the API Gateway deployment stage managed by this module."
  value       = aws_api_gateway_deployment.live.stage_name
}
