resource "null_resource" "k8s-tiller-rbac" {
  depends_on = ["module.eks"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
for i in `seq 1 10`; do \
echo "${module.eks.kubeconfig}" > kube_config.yaml & \
kubectl apply -f files/tiller-rbac.yaml --kubeconfig kube_config.yaml && break || \
sleep 10; \
done; \
rm kube_config.yaml;
EOS
  }

  triggers {
    kube_config_rendered = "${module.eks.kubeconfig}"
  }
}

data "aws_eks_cluster_auth" "cluster-auth" {
  depends_on = ["module.eks", "null_resource.k8s-tiller-rbac"]
  name       = "${local.eks_cluster_name}"
}

provider "helm" {
  namespace       = "kube-system"
  install_tiller  = true
  tiller_image    = "gcr.io/kubernetes-helm/tiller:v2.13.1"
  service_account = "tiller"

  kubernetes {
    host                   = "${module.eks.cluster_endpoint}"
    cluster_ca_certificate = "${base64decode(module.eks.cluster_certificate_authority_data)}"
    token                  = "${data.aws_eks_cluster_auth.cluster-auth.token}"
  }
}

# resource "null_resource" "helm-repository-incubator" {
#   provisioner "local-exec" {
#     command = "helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com"
#   }
# }

# resource "null_resource" "helm-repository-istio" {
#   provisioner "local-exec" {
#     command = "helm repo add istio https://gcsweb.istio.io/gcs/istio-release/releases/${var.istio_version}/charts/"
#   }
# }

data "template_file" "cluster-autoscaler-value" {
  template = "${file("${path.module}/templates/helm-cluster-autoscaler.tpl")}"

  vars = {
    aws_region   = "${var.aws_region}"
    cluster_name = "${local.eks_cluster_name}"
  }
}

resource "helm_release" "cluster-autoscaler" {
  name      = "cluster-autoscaler"
  chart     = "stable/cluster-autoscaler"
  namespace = "kube-system"
  wait      = true

  values = ["${data.template_file.cluster-autoscaler-value.rendered}"]
}

resource "helm_release" "metrics-server" {
  name      = "metrics-server"
  chart     = "stable/metrics-server"
  namespace = "kube-system"
  wait      = true

  values = ["${file("${path.module}/files/helm-metrics-server.yaml")}"]
}
