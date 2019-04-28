## SFTP and Lambda

variable "ec2_tags" {
  default     = {}
  description = "[Optional] Tags for ec2 resources"
}
variable "aws_route53_record_this_fqdn" {}
variable "lambda_filename" {}

variable "subnet_ids" { type = "list" }
variable "security_group_ids" { type = "list" }

resource "aws_iam_user" "sftp" {
  name = "sftp-user"
  # path = "/system/"
  tags = "${var.ec2_tags}"
}

resource "aws_iam_role" "notify-on-upload" {
  name = "notify-on-upload"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "notify-on-upload" {
  policy_arn = "${aws_iam_policy.notify-on-upload.arn}"
  role       = "${aws_iam_role.notify-on-upload.name}"
}

resource "aws_iam_policy" "notify-on-upload" {
  name = "notify-on-upload"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
   {
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
            "ec2:AttachNetworkInterface",
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeNetworkInterfaceAttribute",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DetachNetworkInterface",
            "ec2:ModifyNetworkInterfaceAttribute"
        ]
    },
    {
        "Action": [
            "logs:*"
        ],
        "Effect": "Allow",
        "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_s3_bucket" "sftp-bucket" {
  bucket = "sftp.${var.aws_route53_record_this_fqdn}"
}

resource "aws_s3_bucket_policy" "sftp-bucket" {
  #         "Principal": { "AWS": ["${var.sftp_user}"] },
  bucket = "${aws_s3_bucket.sftp-bucket.id}"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": { "AWS": ["${aws_iam_user.sftp.arn}"] },
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.sftp-bucket.bucket}/*"
        }

    ]
}
EOF
}

resource "aws_lambda_function" "notify-on-upload" {
  filename      = "${var.lambda_filename}"
  publish       = "true"
  function_name = "notify_on_upload"
  role          = "${aws_iam_role.notify-on-upload.arn}"
  handler       = "entrypoint.Handler.process"
  runtime       = "ruby2.5"
  # vpc_config    = {
  #   subnet_ids         = ["subnet-0b1c322c0287d5f78", "subnet-0ecf8f4233a3ea7e6", "subnet-070ff148ec800b2c8"]
  #   security_group_ids = ["sg-078a61107c2f01cc2"]
  # }
  vpc_config    = {
    subnet_ids         = ["${var.subnet_ids}"]
    security_group_ids = ["${var.security_group_ids}"]
    # subnet_ids         = ["${aws_subnet.this.id}"]
    # security_group_ids = ["${aws_security_group.this.id}"]
  }
  source_code_hash = "${base64sha256(file("${var.lambda_filename}"))}"
  # environment {
  #   variables = {
  #     AMQP_URL = "${var.amqp_url}",
  #     AMQP_QUEUE_NAME = "${var.amqp_queue_name_prefix}-${var.environment}",
  #     AMQP_VERSION = 2,
  #     ENVIRONMENT = "${var.environment}",
  #     TENANT_INDEX = 0
  #   }
  # }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.notify-on-upload.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.sftp-bucket.arn}"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.sftp-bucket.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.notify-on-upload.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}
