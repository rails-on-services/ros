# Admin

variable "route53_zone_main_name" {
  default = "rails-on-services.org"
}

variable "route53_zone_this_name" {
  default = "ros"
}

variable "ec2_tags" {
  default     = {}
  description = "[Optional] Tags for ec2 resources"
}
