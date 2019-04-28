# App

variable "aws_route53_zone_this_zone_id" {}
variable "aws_route53_record_this_fqdn" {}

# console.domain.com for the FE app; The Angular app’s S3 bucket maps to this
resource "aws_route53_record" "console" {
  zone_id = "${var.aws_route53_zone_this_zone_id}"
  name    = "console.${var.aws_route53_record_this_fqdn}"
  type    = "A"

  alias {
    name                   = "${aws_s3_bucket.console.website_domain}"
    zone_id                = "${aws_s3_bucket.console.hosted_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_s3_bucket" "console" {
  bucket        = "console.${var.aws_route53_record_this_fqdn}"
  acl           = "public-read"
  force_destroy = true
  policy        = <<EOF
{
  "Id": "bucket_policy_site",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "bucket_policy_site_main",
      "Action": [
        "s3:GetObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::console.${var.aws_route53_record_this_fqdn}/*",
      "Principal": "*"
    }
  ]
}
EOF

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

