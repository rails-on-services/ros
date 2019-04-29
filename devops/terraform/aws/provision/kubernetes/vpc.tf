data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 1.53.0"

  name = "${var.name}"
  cidr = "${var.vpc_cidr_prefix}.0.0/16"

  enable_nat_gateway           = true
  enable_dns_hostnames         = true
  enable_dns_support           = true

  azs                 = ["${data.aws_availability_zones.available.names[0]}", "${data.aws_availability_zones.available.names[1]}", "${data.aws_availability_zones.available.names[2]}"]
  public_subnets      = ["${var.vpc_cidr_prefix}.16.0/20", "${var.vpc_cidr_prefix}.32.0/20", "${var.vpc_cidr_prefix}.48.0/20"]
  private_subnets     = ["${var.vpc_cidr_prefix}.64.0/20", "${var.vpc_cidr_prefix}.80.0/20", "${var.vpc_cidr_prefix}.96.0/20"]

  tags     = "${var.tags}"
  vpc_tags = "${map("kubernetes.io/cluster/${local.eks_cluster_name}", "shared")}"

  public_subnet_tags = "${map(
    "kubernetes.io/cluster/${local.eks_cluster_name}", "shared",
    "kubernetes.io/role/elb", "1"
  )}"

  private_subnet_tags = "${map(
    "kubernetes.io/cluster/${local.eks_cluster_name}", "shared",
    "kubernetes.io/role/internal-elb", "1"
  )}"
}
