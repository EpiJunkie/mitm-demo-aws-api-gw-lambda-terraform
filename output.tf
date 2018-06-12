
output "aws_api_gw_invoke_url" {
  value = "${aws_api_gateway_deployment.demo_deploy.invoke_url}"
}

output "aws_cloudfront_gw_deploy_zone_id" {
  value = "${aws_api_gateway_domain_name.demo_domain.cloudfront_zone_id}"
}

output "aws_cloudfront_gw_deploy_domain" {
  value = "${aws_api_gateway_domain_name.demo_domain.cloudfront_domain_name}"
}
