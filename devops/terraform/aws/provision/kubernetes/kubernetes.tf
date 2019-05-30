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

data "aws_eks_cluster" "cluster" {
  depends_on = ["module.eks"]
  name = "${local.eks_cluster_name}"
}

data "aws_eks_cluster_auth" "cluster-auth" {
  depends_on = ["module.eks", "null_resource.k8s-tiller-rbac"]
  name = "${local.eks_cluster_name}"
}

provider "helm" {
  namespace = "kube-system"
  install_tiller = true
  tiller_image = "gcr.io/kubernetes-helm/tiller:v2.14.0"
  service_account = "tiller"

  kubernetes {
    host = "${data.aws_eks_cluster.cluster.endpoint}"
    cluster_ca_certificate = "${base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)}"
    token = "${data.aws_eks_cluster_auth.cluster-auth.token}"
  }
}

resource "null_resource" "helm-repository-incubator" {
  provisioner "local-exec" {
    command = "helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com"
  }
}

resource "null_resource" "helm-repository-istio" {
  provisioner "local-exec" {
    command = "helm repo add istio https://gcsweb.istio.io/gcs/istio-release/releases/${var.istio_version}/charts/"
  }
}

data "template_file" "cluster-autoscaler-value" {
  template = "${file("${path.module}/templates/helm-cluster-autoscaler.tpl")}"

  vars = {
    aws_region = "${var.aws_region}"
    cluster_name = "${local.eks_cluster_name}"
  }
}

resource "helm_release" "cluster-autoscaler" {
  depends_on = ["null_resource.k8s-tiller-rbac"]
  name = "cluster-autoscaler"
  chart = "stable/cluster-autoscaler"
  namespace = "kube-system"
  wait = true

  values = ["${data.template_file.cluster-autoscaler-value.rendered}"]
}

resource "helm_release" "metrics-server" {
  depends_on = ["null_resource.k8s-tiller-rbac"]
  name = "metrics-server"
  chart = "stable/metrics-server"
  namespace = "kube-system"
  wait = true

  values = ["${file("${path.module}/files/helm-metrics-server.yaml")}"]
}

data "template_file" "aws-alb-ingress-controller-value" {
  template = "${file("${path.module}/templates/helm-aws-alb-ingress-controller.tpl")}"

  vars = {
    cluster_name = "${local.eks_cluster_name}"
  }
}

resource "helm_release" "aws-alb-ingress-controller" {
  depends_on = ["null_resource.helm-repository-incubator", "null_resource.k8s-tiller-rbac", "aws_iam_role_policy_attachment.eks-worker-alb-ingress-controller"]
  name = "aws-alb-ingress-controller"
  repository = "incubator"
  chart = "aws-alb-ingress-controller"
  namespace = "kube-system"
  wait = true

  values = ["${data.template_file.aws-alb-ingress-controller-value.rendered}"]
}

resource "helm_release" "istio-init" {
  depends_on = ["null_resource.helm-repository-istio", "null_resource.k8s-tiller-rbac"]
  name = "istio-init"
  repository = "istio"
  chart = "istio-init"
  version = "${var.istio_version}"
  namespace = "istio-system"
  wait = true

  force_update = true
}

# need to wait for all jobs completed for istio-init
resource "null_resource" "wait-istio-init" {
  depends_on = ["helm_release.istio-init"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
for i in `seq 1 10`; do \
echo "${module.eks.kubeconfig}" > kube_config.yaml & \
kubectl --kubeconfig=kube_config.yaml -n istio-system wait --for=condition=complete --timeout=10s job --all && break || \
sleep 10; \
done; \
rm kube_config.yaml;
EOS
  }

  triggers {
    kube_config_rendered = "${module.eks.kubeconfig}"
  }
}

resource "helm_release" "istio" {
  depends_on = ["null_resource.wait-istio-init"]
  name       = "istio"
  repository = "istio"
  chart      = "istio"
  version    = "${var.istio_version}"
  namespace  = "istio-system"
  wait       = true
  values     = ["${file("${path.module}/files/helm-istio.yaml")}"]
}


data "template_file" "istio-alb-ingress-gateway-manifest" {
  template = "${file("${path.module}/templates/istio-alb-ingressgateway.tpl")}"

  vars = {
    acm_cert_arn = "${module.admin.aws_cert_arn}"
  }
}

# Currently terraform kubernetes provider doesn't support ingress resource
resource "null_resource" "istio-alb-ingress-gateway" {
  depends_on = ["helm_release.istio", "helm_release.aws-alb-ingress-controller"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
echo "${module.eks.kubeconfig}" > kube_config.yaml
cat <<EOT | kubectl apply --kubeconfig kube_config.yaml -f -
${data.template_file.istio-alb-ingress-gateway-manifest.rendered}
EOT
rm kube_config.yaml
hostname=""
while [ -z $hostname ]; do
  echo "Waiting for ingress hostname..."
  echo "${module.eks.kubeconfig}" > kube_config.yaml
  hostname=$(kubectl --kubeconfig kube_config.yaml -n istio-system get ingress istio-alb-ingressgateway --template="{{range .status.loadBalancer.ingress}}{{.hostname}}{{end}}")
  [ -z "$hostname" ] && sleep 3
done
echo 'Ingress hostname ready:' && echo $hostname
rm kube_config.yaml
EOS
  }

  provisioner "local-exec" {
    when = "destroy"
    working_dir = "${path.module}"

    command = <<EOS
echo "${module.eks.kubeconfig}" > kube_config.yaml
kubectl --kubeconfig kube_config.yaml -n istio-system delete ingress istio-alb-ingressgateway
rm kube_config.yaml
EOS
  }

  triggers {
    kube_config_rendered = "${module.eks.kubeconfig}"
    manifest_rendered    = "${data.template_file.istio-alb-ingress-gateway-manifest.rendered}"
  }
}

# Get the ingress's DNS
data "external" "istio-alb-ingress-dns" {
  depends_on = ["null_resource.istio-alb-ingress-gateway"]
  program    = ["bash", "-c", "echo \"${module.eks.kubeconfig}\" > kube_config.yaml; kubectl --kubeconfig kube_config.yaml -n istio-system get ing istio-alb-ingressgateway -o go-template='{\"hostname\":\"{{(index .status.loadBalancer.ingress 0).hostname}}\"}'"]
}

resource "null_resource" "enable-ns-default-istio-injection" {
  depends_on = ["helm_release.istio"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
echo "${module.eks.kubeconfig}" > kube_config.yaml
kubectl --kubeconfig kube_config.yaml label namespace default istio-injection=enabled --overwrite
rm kube_config.yaml
EOS
  }
}

data "template_file" "grafana-value" {
  template = "${file("${path.module}/templates/helm-grafana.tpl")}"

  vars = {
    admin_password     = "${var.grafana-password}"
    cm_dashboard_label = "${var.grafana_dashboards_configmap_label}"
  }
}

resource "helm_release" "grafana" {
  depends_on = ["null_resource.k8s-tiller-rbac"]
  name       = "grafana"
  chart      = "stable/grafana"
  version    = "3.3.10"
  namespace  = "default"
  wait       = true

  values = ["${data.template_file.grafana-value.rendered}"]
}

data "template_file" "grafana-istio-manifests" {
  template = "${file("${path.module}/templates/grafana-istio-resources.tpl")}"
  
  vars = {
    host = "${var.grafana-hostname}.${module.admin.aws_route53_record_this_fqdn}"
  }
}

resource "null_resource" "create-grafana-istio-manifests" {
  depends_on = ["helm_release.grafana"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
echo "${module.eks.kubeconfig}" > kube_config.yaml
cat <<EOT | kubectl apply --kubeconfig kube_config.yaml -f -
${data.template_file.grafana-istio-manifests.rendered}
EOT
rm kube_config.yaml
EOS
  }
}