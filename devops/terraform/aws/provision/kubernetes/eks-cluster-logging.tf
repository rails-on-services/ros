locals {
  eks_cluster_logging_bucket_region = "${var.eks_cluster_logging_s3_region != "" ? var.eks_cluster_logging_s3_region : var.aws_region}"
  eks_cluster_logging_config = {
    type                     = "s3"
    s3_region                = "${local.eks_cluster_logging_bucket_region}"
    s3_bucket                = "${var.eks_cluster_logging_s3_bucket}"
    use_ec2_instance_profile = true
  }
}

resource "aws_s3_bucket" "fluentd-cluster-logging-bucket" {
  count  = "${var.eks_enable_cluster_logging_s3 * var.eks_create_cluster_logging_s3_bucket}"
  bucket = "${var.eks_cluster_logging_s3_bucket}"
  acl    = "private"
  region = "${local.eks_cluster_logging_bucket_region}"
  tags   = "${var.tags}"
}

data "template_file" "access-logging-bucket-iam-policy" {
  count    = "${var.eks_enable_cluster_logging_s3 ? 1 : 0}"
  template = "${file("${path.module}/templates/access-s3-bucket-iam-policy.tpl")}"

  vars = {
    s3_bucket = "${var.eks_cluster_logging_s3_bucket}"
  }
}

resource "aws_iam_policy" "eks-worker-access-logging-bucket" {
  count       = "${var.eks_enable_cluster_logging_s3 ? 1 : 0}"
  name_prefix = "eks-worker-access-logging-bucket-${local.eks_cluster_name}"
  description = "Allow EKS worker to access logging bucket"

  policy = "${data.template_file.access-logging-bucket-iam-policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "eks-worker-access-logging-bucket" {
  count      = "${var.eks_enable_cluster_logging_s3 ? 1 : 0}"
  policy_arn = "${aws_iam_policy.eks-worker-access-logging-bucket.*.arn[0]}"
  role       = "${module.eks.worker_iam_role_name}"
}

data "template_file" "fluentd-cluster-logging-value" {
  count    = "${var.eks_enable_cluster_logging_s3 ? 1 : 0}"
  template = "${file("${path.module}/templates/helm-fluentd-cluster-logging.tpl")}"

  vars = {
    aws_region   = "${var.aws_region}"
    cluster_name = "${local.eks_cluster_name}"
    log_config   = "${jsonencode(local.eks_cluster_logging_config)}"
  }
}

# tf helm_release resource will do a destroy re-create if chart path changes
# since fluentd-cluster-logging chart is specified as local path it will be different for different users
# so we are using null_resource to run helm
# since we depends on tiller initialized in the cluster, let's depends on a helm_release
resource "null_resource" "deploy-fluentd-cluster-logging" {
  count      = "${var.eks_enable_cluster_logging_s3 ? 1 : 0}"
  depends_on = ["module.eks", "helm_release.istio"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
for i in `seq 1 3`
do
cat <<EOT > kube_config.yaml
${module.eks.kubeconfig}
EOT
cat <<EOT > fluentd-cluster-logging-values.yaml
${data.template_file.fluentd-cluster-logging-value.rendered}
EOT
helm --kubeconfig kube_config.yaml upgrade --install --namespace kube-system fluentd-cluster-logging -f fluentd-cluster-logging-values.yaml ${var.eks_cluster_logging_helm_chart} && break || \
sleep 10
done
rm kube_config.yaml fluentd-cluster-logging-values.yaml;
EOS
  }

  triggers {
    helm_values = "${data.template_file.fluentd-cluster-logging-value.rendered}"
  }
}
