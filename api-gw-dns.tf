
# Use A record
# Takes 40 minutes for CloudFront to propagate domain but is distrubuted.
resource "aws_route53_record" "mitm_dns" {
  zone_id = "${var.route53_zoneid}"
  name    = "${var.route53_domain}"
  type    = "A"

  alias = {
    name                   = "${aws_api_gateway_domain_name.demo_domain.cloudfront_domain_name}"
    zone_id                = "${aws_api_gateway_domain_name.demo_domain.cloudfront_zone_id}"
    evaluate_target_health = "true"
  }
}

# Use CNAME record
# Takes a minute to propagate but is NOT distrubuted.
#resource "aws_route53_record" "mitm_dns" {
#  zone_id = "${var.route53_zoneid}"
#  name    = "${var.route53_domain}"
#  type    = "CNAME"
#  ttl     = "300"
#  records = ["${aws_api_gateway_deployment.demo_deploy.rest_api_id}.execute-api.${var.aws_region}.amazonaws.com"]
#}
