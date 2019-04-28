data "template_file" "cognito-value" {
  template = "${file("${path.module}/templates/helm-values-cognito.tpl")}"

  vars = {
    name      = "cognito"
    image_tag = "${var.cognito_version}"
    replica   = "${var.cognito_replicas}"
    resources = "${jsonencode(var.cognito_resources)}"
  }
}

data "template_file" "comm-value" {
  template = "${file("${path.module}/templates/helm-values-comm.tpl")}"

  vars = {
    name      = "comm"
    image_tag = "${var.comm_version}"
    replica   = "${var.comm_replicas}"
    resources = "${jsonencode(var.comm_resources)}"
  }
}

data "template_file" "iam-value" {
  template = "${file("${path.module}/templates/helm-values-iam.tpl")}"

  vars = {
    name      = "iam"
    image_tag = "${var.iam_version}"
    replica   = "${var.iam_replicas}"
    resources = "${jsonencode(var.iam_resources)}"
  }
}

resource "helm_release" "cognito" {
  name      = "cognito"
  chart     = "${var.helm_repository}/cognito"
  namespace = "${var.namespace}"

  values = ["${concat(list(data.template_file.cognito-value.rendered), var.cognito_extra_values)}"]
}

resource "helm_release" "comm" {
  name      = "comm"
  chart     = "${var.helm_repository}/comm"
  namespace = "${var.namespace}"

  values = ["${concat(list(data.template_file.comm-value.rendered), var.comm_extra_values)}"]
}

resource "helm_release" "iam" {
  name      = "iam"
  chart     = "${var.helm_repository}/iam"
  namespace = "${var.namespace}"

  values = ["${concat(list(data.template_file.iam-value.rendered), var.iam_extra_values)}"]
}

data "template_file" "ingress-value" {
  count    = "${var.enable_istio_ingress ? 1 : 0}"
  template = "${file("${path.module}/templates/helm-values-ingress.tpl")}"

  vars = {
    host = "${var.external_dns}"
  }
}

resource "helm_release" "ingress" {
  count      = "${var.enable_istio_ingress ? 1 : 0}"
  depends_on = ["helm_release.cognito", "helm_release.comm", "helm_release.iam"]
  name       = "ingress"
  chart      = "${var.helm_repository}/ingress"
  namespace  = "${var.namespace}"
  values     = ["${data.template_file.ingress-value.rendered}"]
}
