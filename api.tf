resource "aws_api_gateway_rest_api" "root" {
  name = local.api_gateway_name
}

resource "aws_api_gateway_resource" "modules_root" {
  rest_api_id = aws_api_gateway_rest_api.root.id
  parent_id   = aws_api_gateway_rest_api.root.root_resource_id
  path_part   = "modules.v1"
}

resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_iam_role" "cloudwatch" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "default"
  role = aws_iam_role.cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

module "modules_v1" {
  source = "./modules/modules.v1"

  rest_api_id        = aws_api_gateway_resource.modules_root.rest_api_id
  parent_resource_id = aws_api_gateway_resource.modules_root.id

  dynamodb_table_name     = local.modules_table_name
  dynamodb_query_role_arn = aws_iam_role.modules.arn

  custom_authorizer_id = (
    length(aws_api_gateway_authorizer.main) > 0 ? aws_api_gateway_authorizer.main[0].id : null
  )
}

module "disco" {
  source = "./modules/disco"

  rest_api_id = aws_api_gateway_rest_api.root.id
  services = {
    "modules.v1" = "${aws_api_gateway_resource.modules_root.path}/",
  }
}

resource "aws_api_gateway_deployment" "live" {
  depends_on = [
    module.modules_v1,
    module.disco,
  ]

  rest_api_id = aws_api_gateway_rest_api.root.id
  stage_name  = "live"
}
