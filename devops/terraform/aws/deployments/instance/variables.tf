variable "aws_region" {
  default = "ap-southeast-1"
}

variable "route53_zone_main_name" {
  # default = "rails-on-services.org"
}

variable "route53_zone_this_name" {
  # default = "ros"
}

variable "ec2_tags" {
  default     = {}
  description = "[Optional] Tags for ec2 resources"
}

variable "ec2_instance_type" {
  default = "t3.large"
}

variable "ec2_ami_distro" {
  default = "debian"
  description = "The EC2 ami linux distro to use, can be debian or ubuntu"
}

variable "ec2_key_pair" {
  description = "EC2 ssh key pair name to use"
}

variable "lambda_filename" {
  type    = "string"
}

# variable "sftp_user" {
#   type    = "string"
# }

# variable "extra_envs" {
#   type        = "map"
#   default     = {}
#   description = "Extra environment variables for the applications"
# }
