resource "random_string" "postgres-password" {
  length  = 15
  special = false
}

resource "random_string" "secret-key-base" {
  length  = 128
  special = false
}

resource "random_string" "rails-master-key" {
  length  = 32
  special = false
}

resource "random_string" "platform-jwt-encryption-key" {
  length  = 32
  special = false
}

resource "random_string" "platform-credential-salt" {
  length  = 9
  special = false
  upper   = false
  lower   = false
  number  = true
}

resource "random_string" "platform-encryption-key" {
  length  = 32
  special = false
}

resource "kubernetes_secret" "ros-common" {
  metadata {
    name      = "ros-common"
    namespace = "${var.k8s_namespace}"
  }

  data {
    SECRET_KEY_BASE                            = "${random_string.secret-key-base.result}"
    RAILS_MASTER_KEY                           = "${random_string.rails-master-key.result}"
    PLATFORM__SERVICE__PARTITION_NAME          = "${var.platform_service_partition_name}"
    PLATFORM__JWT__ENCRYPTION_KEY              = "${random_string.platform-jwt-encryption-key.result}"
    PLATFORM__JWT__ISS                         = "https://iam.rails-on-services.org"
    PLATFORM__JWT__AUD                         = "https://rails-on-services.org"
    PLATFORM__SERVICES__CONNECTION__TYPE       = "host"
    PLATFORM__SERVICES__CONNECTION__HOST__PORT = "80"
    PLATFORM__EXTERNAL_CONNECTION_TYPE         = "path"
  }
}

resource "kubernetes_secret" "ros-comm" {
  metadata {
    name      = "ros-comm"
    namespace = "${var.k8s_namespace}"
  }

  data {
    RAILS_DATABASE_HOST      = "postgres"
    RAILS_DATABASE_USER      = "${var.postgres_user}"
    RAILS_DATABASE_PASSWORD  = "${random_string.postgres-password.result}"
    PLATFORM__ENCRYPTION_KEY = "${random_string.platform-encryption-key.result}"
  }
}

resource "kubernetes_secret" "ros-iam" {
  metadata {
    name      = "ros-iam"
    namespace = "${var.k8s_namespace}"
  }

  data {
    RAILS_DATABASE_HOST        = "postgres"
    RAILS_DATABASE_USER        = "${var.postgres_user}"
    RAILS_DATABASE_PASSWORD    = "${random_string.postgres-password.result}"
    PLATFORM__CREDENTIAL__SALT = "${random_string.platform-credential-salt.result}"
  }
}

resource "kubernetes_secret" "ros-cognito" {
  metadata {
    name      = "ros-cognito"
    namespace = "${var.k8s_namespace}"
  }

  data {
    RAILS_DATABASE_HOST     = "postgres"
    RAILS_DATABASE_USER     = "${var.postgres_user}"
    RAILS_DATABASE_PASSWORD = "${random_string.postgres-password.result}"
  }
}
