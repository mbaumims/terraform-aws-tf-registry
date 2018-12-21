resource "aws_api_gateway_rest_api" "root" {
  name = local.api_gateway_name
}

resource "aws_api_gateway_resource" "modules_root" {
  rest_api_id = aws_api_gateway_rest_api.root.id
  parent_id   = aws_api_gateway_rest_api.root.root_resource_id
  path_part   = "modules.v1"
}

module "modules_v1" {
  source = "./modules/modules.v1"

  rest_api_id        = aws_api_gateway_resource.modules_root.rest_api_id
  parent_resource_id = aws_api_gateway_resource.modules_root.id

  dynamodb_table_name = local.modules_table_name
}

module "disco" {
  source = "./modules/disco"

  rest_api_id = aws_api_gateway_rest_api.root.id
  services = {
    "modules.v1" = "${aws_api_gateway_resource.modules_root.path}/",
  }
}