provider "aws" {
  region = "${var.aws_region}"
}
module "admin" {
  source                 = "../../modules/admin"
  route53_zone_main_name = "${var.route53_zone_main_name}"
  route53_zone_this_name = "${var.route53_zone_this_name}"
  ec2_tags               = "${var.tags}"
}


resource "aws_route53_record" "wildcard" {
  zone_id = "${module.admin.aws_route53_zone_this_zone_id}"
  name    = "*.${module.admin.aws_route53_record_this_fqdn}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${lookup(data.external.istio-alb-ingress-dns.result, "hostname")}"]
}
