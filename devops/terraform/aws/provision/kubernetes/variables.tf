variable "aws_region" {
  default = "ap-southeast-1"
}

variable "name" {
  default = "ros"
}

variable "tags" {
  type    = "map"
  default = {}
}

variable "route53_zone_main_name" {
  # default = "rails-on-services.org"
}

variable "route53_zone_this_name" {
  # default = "ros"
}

variable "vpc_cidr_prefix" {
  type        = "string"
  default     = "10.0"
  description = "First 2 sections of CIDR of the vpc"
}

variable "eks_clustername" {
  type        = "string"
  default     = ""
  description = "EKS cluster name, if not specified, name will be used"
}

variable "eks_cluster_version" {
  type    = "string"
  default = "1.12"
}

variable "eks_worker_ami_name_filter" {
  type    = "string"
  default = "v*"
}

variable "eks_worker_groups" {
  type = "list"

  default = [{
    instance_type         = "m5.large"
    name                  = "eks_workers_a"
    asg_max_size          = 10
    asg_min_size          = 1
    root_volume_size      = 30
    root_volume_type      = "gp2"
    autoscaling_enabled   = true
    protect_from_scale_in = true
    enable_monitoring     = false
  }]
}

variable "eks_map_users" {
  type        = "list"
  default     = []
  description = "Extra IAM users to add to the aws-auth configmap, see example here: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/eks_test_fixture/variables.tf"
}

variable "eks_map_roles" {
  type        = "list"
  default     = []
  description = "IAM roles to add to the aws-auth configmap, see example here: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/eks_test_fixture/variables.tf"
}

variable "istio_version" {
  default     = "1.1.7"
  description = "Istio version to install"
}

variable "eks_enable_cluster_logging_s3" {
  default     = false
  description = "Whether to enable kubernetes cluster level logging (using fluentd) to a S3 bucket"
}

variable "eks_cluster_logging_helm_chart" {
  default     = "../../../../helm/charts/fluentd-cluster-logging"
  description = "Path to the fluentd-cluster-logging helm chart"
}

variable "eks_cluster_logging_s3_region" {
  type        = "string"
  default     = ""
  description = "Kubernetes cluster level logging sinck bucket region, if not specified will use aws_region"
}
variable "eks_cluster_logging_s3_bucket" {
  type        = "string"
  description = "Kubernetes cluster level logging sink bucket name"
  default     = ""
}

variable "eks_create_cluster_logging_s3_bucket" {
  default     = false
  description = "Whether to create the s3 bucket specified via eks_cluster_logging_s3_bucket"
}

variable "grafana-password" {
  type        = "string"
  description = "Grafana's admin user's initial password"
}

variable "grafana-hostname" {
  type        = "string"
  default     = "grafana"
  description = "Grafana's hostname, which will be used to compose its public hostname which is of format: {grafana-hostname}.{route53_zone_this_name}.{route53_zone_main_name}"
}

variable "grafana_dashboards_configmap_label" {
  type        = "string"
  default     = "grafana_dashboard"
  description = "Label that should be used for filtering configMaps for grafana dashboard definitions"
}
