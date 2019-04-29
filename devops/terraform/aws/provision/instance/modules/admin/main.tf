# Admin

output "aws_route53_zone_this_zone_id" {
  value = "${aws_route53_zone.this.zone_id}"
}

output "aws_route53_record_this_fqdn" {
  value = "${aws_route53_record.this.fqdn}"
}

output "aws_cert_arn" {
  value = "${aws_acm_certificate.this.arn}"
}

# Get the domain into which a subdomain will be created to hold the hostnames
data "aws_route53_zone" "main" {
  name = "${var.route53_zone_main_name}."
}

# Create the subdomain
resource "aws_route53_zone" "this" {
  name = "${var.route53_zone_this_name}.${data.aws_route53_zone.main.name}"
  tags = "${var.ec2_tags}"
}

# Create NS records in the main zone for the subdomain
resource "aws_route53_record" "this" {
  zone_id = "${data.aws_route53_zone.main.zone_id}"
  name    = "${aws_route53_zone.this.name}"
  type    = "NS"
  ttl     = "30"

  records = [
    "${aws_route53_zone.this.name_servers.0}",
    "${aws_route53_zone.this.name_servers.1}",
    "${aws_route53_zone.this.name_servers.2}",
    "${aws_route53_zone.this.name_servers.3}",
  ]
}

# Create a wildcard SSL certifiate for the newly created subdomain
resource "aws_acm_certificate" "this" {
  domain_name       = "${aws_route53_record.this.fqdn}"
  validation_method = "DNS"
  tags              = "${var.ec2_tags}"

  subject_alternative_names = ["*.${aws_route53_record.this.fqdn}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.this.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.this.domain_validation_options.0.resource_record_type}"
  zone_id = "${aws_route53_zone.this.id}"
  records = ["${aws_acm_certificate.this.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = "${aws_acm_certificate.this.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}
