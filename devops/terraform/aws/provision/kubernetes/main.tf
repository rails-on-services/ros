module "admin" {
  source                 = "../../modules/admin"
  route53_zone_main_name = "${var.route53_zone_main_name}"
  route53_zone_this_name = "${var.route53_zone_this_name}"
  ec2_tags               = "${var.tags}"
}

data "template_file" "istio-alb-ingress-gateway-manifest" {
  template = "${file("${path.module}/templates/istio-alb-ingressgateway.tpl")}"

  vars = {
    acm_cert_arn = "${module.admin.aws_cert_arn}"
  }
}

# Currently terraform kubernetes provider doesn't support ingress resource
resource "null_resource" "istio-alb-ingress-gateway" {
  depends_on = ["helm_release.istio"]

  provisioner "local-exec" {
    working_dir = "${path.module}"

    command = <<EOS
echo "${module.eks.kubeconfig}" > kube_config.yaml
cat <<EOT | kubectl apply --kubeconfig kube_config.yaml -f -
${data.template_file.istio-alb-ingress-gateway-manifest.rendered}
EOT
hostname=""
while [ -z $hostname ]; do
  echo "Waiting for ingress hostname..."
  hostname=$(kubectl --kubeconfig kube_config.yaml -n istio-system get ingress istio-alb-ingressgateway --template="{{range .status.loadBalancer.ingress}}{{.hostname}}{{end}}")
  [ -z "$hostname" ] && sleep 3
done
echo 'Ingress hostname ready:' && echo $hostname
rm kube_config.yaml
EOS
  }

  provisioner "local-exec" {
    when=  "destroy"
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

resource "aws_route53_record" "wildcard" {
  zone_id = "${module.admin.aws_route53_zone_this_zone_id}"
  name    = "*.${module.admin.aws_route53_record_this_fqdn}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${lookup(data.external.istio-alb-ingress-dns.result, "hostname")}"]
}
