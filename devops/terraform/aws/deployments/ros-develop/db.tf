resource "kubernetes_persistent_volume_claim" "postgresql" {
  metadata {
    name      = "postgresql"
    namespace = "${var.k8s_namespace}"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests {
        storage = "${var.postgresql_data_volume_size}"
      }
    }
  }
}

data "template_file" "postgresql-value" {
  template = "${file("${path.module}/templates/helm-postgresql.tpl")}"

  vars = {
    postgres_user     = "${var.postgres_user}"
    postgres_password = "${random_string.postgres-password.result}"
    postgres_db       = "postgres"
    pvc               = "postgresql"
    resources         = "${jsonencode(var.postgresql_resources)}"
  }
}

resource "helm_release" "postgresql" {
  depends_on = ["kubernetes_persistent_volume_claim.postgresql"]
  name       = "postgresql"
  namespace  = "${var.k8s_namespace}"
  chart      = "stable/postgresql"
  wait       = true
  timeout    = 1800

  values = ["${data.template_file.postgresql-value.rendered}"]
}
