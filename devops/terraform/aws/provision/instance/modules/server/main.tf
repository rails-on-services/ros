# Server

variable "ec2_tags" {
  default     = {}
  description = "[Optional] Tags for ec2 resources"
}

variable "ec2_instance_type" {
  default = "t3.large"
}

variable "ec2_ami_distro" {
  default     = "debian"
  description = "The EC2 ami linux distro to use, can be debian or ubuntu"
}

variable "ec2_key_pair" {
  description = "EC2 ssh key pair name to use"
}

variable "vpc_id" {}

variable "subnet_ids" {
  type    = "list"
  default = []
}

variable "vpc_security_group_ids" {
  type    = "list"
  default = []
}

variable "vpc_lb_security_group_ids" {
  type    = "list"
  default = []
}

variable "aws_route53_zone_this_zone_id" {}
variable "aws_route53_record_this_fqdn" {}

variable "aws_cert_arn" {}

data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${local.ami_filter_name_map[var.ec2_ami_distro]}"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["${local.ami_owner_map[var.ec2_ami_distro]}"]
}

resource "aws_instance" "this" {
  ami                    = "${data.aws_ami.this.id}"
  instance_type          = "${var.ec2_instance_type}"
  subnet_id              = "${element(var.subnet_ids, 1)}"
  key_name               = "${var.ec2_key_pair}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]

  root_block_device = {
    volume_type = "gp2"
    volume_size = 50
  }

  # user_data = "${data.template_file.user-data.rendered}"

  tags = "${var.ec2_tags}"
}

resource "aws_eip" "this" {
  vpc = true

  # depends_on = ["aws_internet_gateway.this"]
  tags = "${var.ec2_tags}"
}

resource "aws_eip_association" "this" {
  instance_id   = "${aws_instance.this.id}"
  allocation_id = "${aws_eip.this.id}"
}

resource "aws_lb_target_group" "this" {
  name_prefix = "ros"
  protocol    = "HTTP"
  vpc_id      = "${var.vpc_id}"

  # the nginx listens on port 3000
  port = 3000

  health_check = {
    path              = "/healthz"
    matcher           = "200"
    interval          = 10
    healthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = "${aws_lb_target_group.this.arn}"
  target_id        = "${aws_instance.this.id}"
}

resource "aws_lb" "this" {
  name_prefix        = "ros"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${var.vpc_lb_security_group_ids}"]
  subnets            = ["${var.subnet_ids}"]

  tags = "${var.ec2_tags}"
}

resource "aws_lb_listener" "this-http" {
  load_balancer_arn = "${aws_lb.this.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "this-https" {
  load_balancer_arn = "${aws_lb.this.arn}"
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = "${var.aws_cert_arn}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.this.arn}"
  }
}

# api.domain.com for the platform. The ELB maps to this
# TODO developers.domain.com for the business partner developers. The ELB maps to this
# TODO blog.domain.com for the project’s blog. The ELB maps to this
resource "aws_route53_record" "api" {
  zone_id = "${var.aws_route53_zone_this_zone_id}"
  name    = "api.${var.aws_route53_record_this_fqdn}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_lb.this.dns_name}"]
}

# sftp.domain.com for the SFTP server; The EC2 maps to this
# TODO: Bring over the SFTP TF code
# resource "aws_route53_record" "sftp" {
#   zone_id = "${aws_route53_zone.this.zone_id}"
#   name    = "sftp.${aws_route53_record.this.fqdn}"
#   type    = "A"
#   ttl     = "300"
#   records = ["${aws_eip.this.public_ip}"]
# }


# TODO: Create an nginx and compose that serves guides, developers and blog
# TODO: Map hostnames from ELB/ALB to the nginx running on EC2; api on 80, guides, etc on 8080 or so
# guides.domain.com for the project’s guides. The ELB maps to this
# resource "aws_route53_record" "guides" {
#   zone_id = "${aws_route53_zone.this.zone_id}"
#   name    = "guides.${aws_route53_record.this.fqdn}"
#   type    = "A"
#   ttl     = "300"
#   records = ["${aws_eip.this.public_ip}"]
# }

