resource "aws_security_group" "eks-cluster" {
  name_prefix = "${var.name}-eks-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${module.vpc.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${var.tags}"
}

## Allow inbound traffic from internet to the Kubernetes.
resource "aws_security_group_rule" "eks-cluster-ingress-internet-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstations to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks-cluster.id}"
  to_port           = 443
  type              = "ingress"
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 2.3.0"
  cluster_version = "${var.eks_cluster_version}"
  cluster_name    = "${local.eks_cluster_name}"
  subnets         = ["${concat(module.vpc.public_subnets, module.vpc.private_subnets)}"]
  vpc_id          = "${module.vpc.vpc_id}"

  cluster_create_security_group   = "false"
  cluster_endpoint_private_access = "true"
  cluster_endpoint_public_access  = "true"
  cluster_security_group_id       = "${aws_security_group.eks-cluster.id}"
  worker_ami_name_filter          = "${var.eks_worker_ami_name_filter}"

  manage_aws_auth    = "true"
  write_kubeconfig   = "true"
  config_output_path = "./"

  workers_group_defaults = {
    subnets                       = "${join(",", module.vpc.private_subnets)}"
    additional_security_group_ids = "${module.vpc.default_security_group_id}"
  }

  # using launch configuration
  worker_groups      = "${var.eks_worker_groups}"
  worker_group_count = "${length(var.eks_worker_groups)}"

  # not using launch template
  worker_group_launch_template_count = "0"

  map_users       = "${var.eks_map_users}"
  map_users_count = "${length(var.eks_map_users)}"
  map_roles       = "${var.eks_map_roles}"
  map_roles_count = "${length(var.eks_map_roles)}"

  tags = "${var.tags}"
}

## attach iam policy to allow aws alb ingress controller
resource "aws_iam_policy" "eks-worker-alb-ingress-controller" {
  name_prefix = "eks-worker-ingress-controller-${local.eks_cluster_name}"
  description = "EKS worker node alb ingress controller policy for cluster ${local.eks_cluster_name}"
  policy      = "${file("${path.module}/files/aws-alb-ingress-controller-iam-policy.json")}"
}

resource "aws_iam_role_policy_attachment" "eks-worker-alb-ingress-controller" {
  policy_arn = "${aws_iam_policy.eks-worker-alb-ingress-controller.arn}"
  role       = "${module.eks.worker_iam_role_name}"
}
