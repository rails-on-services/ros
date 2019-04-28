# Network

data "aws_availability_zones" "available" {}

variable "ec2_tags" {
  default     = {}
  description = "[Optional] Tags for ec2 resources"
}

output "vpc_id" {
  value = "${aws_vpc.this.id}"
}

output "aws_subnets" {
  value = "${aws_subnet.this.*.id}"
}

output "aws_security_group_this_id" {
  value = "${aws_security_group.this.id}"
}

output "aws_security_group_elb_id" {
  value = "${aws_security_group.lb.id}"
}

resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  tags       = "${var.ec2_tags}"
}

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"
}

resource "aws_route" "this" {
  route_table_id         = "${aws_vpc.this.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.this.id}"
}

resource "aws_subnet" "this" {
  count      = "${length(data.aws_availability_zones.available.names)}"
  vpc_id     = "${aws_vpc.this.id}"
  cidr_block = "10.0.${count.index}.0/24"

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags = "${var.ec2_tags}"
}

resource "aws_security_group" "this" {
  name_prefix = "allow-public"
  description = "Allow access from public internet"

  vpc_id = "${aws_vpc.this.id}"

  tags = "${var.ec2_tags}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow load balancer to reach the instance
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = ["${aws_security_group.lb.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "lb" {
  name_prefix = "allow-lb-public"
  description = "Allow access load balancer from public internete"

  vpc_id = "${aws_vpc.this.id}"
  tags   = "${var.ec2_tags}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
