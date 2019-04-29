provider "kubernetes" {
  version = "~> 1.5"
}

provider "helm" {
  version        = "~> 0.9"
  namespace      = "${var.tiller_namespace}"
  install_tiller = false
}

provider "random" {
  version = "~> 2.1"
}

locals {
  cognito_extra_value = {
    bootstrap = {
      enabled = true
    }

    app = {
      envFromSecrets = ["ros-common", "ros-cognito"]

      env = "${merge(map("RAILS_ENV", "development",
                         "PLATFORM__CONFIG__HOSTS", join(",", compact(list("ros-cognito", var.istio_gateway_external_dns)))),
                        var.cognito_extra_envs)}"
    }
  }

  iam_extra_value = {
    bootstrap = {
      enabled = true
    }

    app = {
      envFromSecrets = ["ros-common", "ros-iam"]

      env = "${merge(map("RAILS_ENV", "development",
                         "PLATFORM__CONFIG__HOSTS", join(",", compact(list("ros-iam", var.istio_gateway_external_dns)))),
                         var.iam_extra_envs)}"
    }
  }

  comm_extra_value = {
    bootstrap = {
      enabled = true
    }

    app = {
      envFromSecrets = ["ros-common", "ros-comm"]

      env = "${merge(map("RAILS_ENV", "development",
                         "PLATFORM__CONFIG__HOSTS", join(",", compact(list("ros-cognito", var.istio_gateway_external_dns)))),
                         var.comm_extra_envs)}"
    }
  }
}

module "k8s-ros" {
  source               = "../../modules/k8s-ros"
  helm_repository      = "${path.module}/../../../helm/charts"
  namespace            = "${var.k8s_namespace}"
  cognito_version      = "${var.cognito_version}"
  iam_version          = "${var.iam_version}"
  comm_version         = "${var.comm_version}"
  enable_istio_ingress = "${var.istio_gateway_external_dns == "" ? false : true}"
  external_dns         = "${var.istio_gateway_external_dns}"

  cognito_extra_values = ["${jsonencode(local.cognito_extra_value)}"]
  iam_extra_values     = ["${jsonencode(local.iam_extra_value)}"]
  comm_extra_values    = ["${jsonencode(local.comm_extra_value)}"]
}
