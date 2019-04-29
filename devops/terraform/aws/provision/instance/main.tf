provider "aws" {
  region = "${var.aws_region}"
}

module "admin" {
  source                 = "../../modules/admin"
  route53_zone_main_name = "${var.route53_zone_main_name}"
  route53_zone_this_name = "${var.route53_zone_this_name}"
  ec2_tags               = "${var.ec2_tags}"
}

module "app" {
  source                        = "./modules/app"
  aws_route53_zone_this_zone_id = "${module.admin.aws_route53_zone_this_zone_id}"
  aws_route53_record_this_fqdn  = "${module.admin.aws_route53_record_this_fqdn}"
}

module "network" {
  source = "./modules/network"
}

module "server" {
  source                        = "./modules/server"
  ec2_instance_type             = "${var.ec2_instance_type}"
  ec2_ami_distro                = "${var.ec2_ami_distro}"
  ec2_key_pair                  = "${var.ec2_key_pair}"
  vpc_id                        = "${module.network.vpc_id}"
  subnet_ids                    = ["${module.network.aws_subnets}"]
  vpc_security_group_ids        = ["${list(module.network.aws_security_group_this_id)}"]
  vpc_lb_security_group_ids     = ["${list(module.network.aws_security_group_elb_id)}"]
  ec2_tags                      = "${var.ec2_tags}"
  aws_route53_zone_this_zone_id = "${module.admin.aws_route53_zone_this_zone_id}"
  aws_route53_record_this_fqdn  = "${module.admin.aws_route53_record_this_fqdn}"
  aws_cert_arn                  = "${module.admin.aws_cert_arn}"
}

# module "sftp" {
#   source                        = "./modules/sftp"
#   ec2_tags                      = "${var.ec2_tags}"
#   aws_route53_record_this_fqdn  = "${module.admin.aws_route53_record_this_fqdn}"
#   lambda_filename               = "${var.lambda_filename}"
#   subnet_ids                    = ["${module.network.aws_subnet_this_id}"]
#   security_group_ids            = ["${module.network.aws_security_group_this_id}"]
# }
