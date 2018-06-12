#
# https://www.terraform.io/docs/providers/aws/guides/serverless-with-aws-lambda-and-api-gateway.html
#

resource "aws_api_gateway_rest_api" "mitm_api" {
  name        = "APIGatewayMITM"
  description = "Terraform API Gateway MITM Application Example"
}

resource "aws_api_gateway_resource" "mitm_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.mitm_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.mitm_api.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "mitm_method_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.mitm_api.id}"
  resource_id   = "${aws_api_gateway_rest_api.mitm_api.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "mitm_method_star" {
  rest_api_id   = "${aws_api_gateway_rest_api.mitm_api.id}"
  resource_id   = "${aws_api_gateway_resource.mitm_resource.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "mitm_integration_root" {
  rest_api_id = "${aws_api_gateway_rest_api.mitm_api.id}"
  resource_id = "${aws_api_gateway_method.mitm_method_root.resource_id}"
  http_method = "${aws_api_gateway_method.mitm_method_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.mitm_function.invoke_arn}"
}

resource "aws_api_gateway_integration" "mitm_integration_star" {
  rest_api_id = "${aws_api_gateway_rest_api.mitm_api.id}"
  resource_id = "${aws_api_gateway_method.mitm_method_star.resource_id}"
  http_method = "${aws_api_gateway_method.mitm_method_star.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.mitm_function.invoke_arn}"
}

resource "aws_api_gateway_deployment" "demo_deploy" {
  depends_on = [
    "aws_api_gateway_integration.mitm_integration_star",
    "aws_api_gateway_integration.mitm_integration_root",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.mitm_api.id}"
  stage_name  = "demo"
}

resource "aws_api_gateway_domain_name" "demo_domain" {
  domain_name             = "${var.route53_domain}"
  certificate_name        = "mitm-demo-cert"
  certificate_body        = "${file("${var.domain_public_cert_file}")}"
  certificate_chain       = "${file("${var.domain_ca_cert_file}")}"
  certificate_private_key = "${file("${var.domain_private_key_file}")}"
}

resource "aws_api_gateway_base_path_mapping" "demo_path_map" {
  api_id      = "${aws_api_gateway_rest_api.mitm_api.id}"
  stage_name  = "${aws_api_gateway_deployment.demo_deploy.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.demo_domain.domain_name}"
  base_path   = ""
}
