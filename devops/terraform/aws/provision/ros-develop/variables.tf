variable "tiller_namespace" {
  default     = "kube-system"
  description = "Tiller namespace"
}

variable "k8s_namespace" {
  default     = "default"
  description = "Kubernetes namespace for the workload"
}

variable "postgresql_data_volume_size" {
  type    = "string"
  default = "10Gi"
}

variable "postgresql_resources" {
  type = "map"

  default = {
    requests = {
      cpu    = 0.5
      memory = "2Gi"
    }
  }
}

variable "postgres_user" {
  default = "postgres"
}

variable "platform_service_partition_name" {
  default = "ros"
}

variable "cognito_version" {
  description = "Docker image tag for ros-cognito"
}

variable "iam_version" {
  description = "Docker image tag for ros-iam"
}

variable "comm_version" {
  description = "Docker image tag for ros-comm"
}

variable "cognito_extra_envs" {
  type        = "map"
  default     = {}
  description = "Extra environment variables set to cognito service"
}

variable "comm_extra_envs" {
  type        = "map"
  default     = {}
  description = "Extra environment variables set to cognito service"
}

variable "iam_extra_envs" {
  type        = "map"
  default     = {}
  description = "Extra environment variables set to cognito service"
}

variable "istio_gateway_external_dns" {
  default     = ""
  description = "External DNS for the service"
}
