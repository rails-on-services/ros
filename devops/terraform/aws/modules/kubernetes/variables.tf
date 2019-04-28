variable "helm_repository" {
  description = "The helm repository for helm charts"
}

variable "namespace" {
  default     = "default"
  description = "Kubernetes namespace for helm releases"
}

variable "cognito_version" {
  description = "Docker image tag for cognito"
}

variable "iam_version" {
  description = "Docker image tag for iam"
}

variable "comm_version" {
  description = "Docker image tag for comm"
}

variable "cognito_replicas" {
  default     = 1
  description = "Replica number of cognito"
}

variable "iam_replicas" {
  default     = 1
  description = "Replica number of iam"
}

variable "comm_replicas" {
  default     = 1
  description = "Replica number of comm"
}

variable "cognito_resources" {
  type        = "map"
  description = "Kubernetes resources for cognito"

  default = {
    requests = {
      cpu    = 0.5
      memory = "2Gi"
    }
  }
}

variable "iam_resources" {
  type        = "map"
  description = "Kubernetes resources for iam"

  default = {
    requests = {
      cpu    = 0.5
      memory = "2Gi"
    }
  }
}

variable "comm_resources" {
  type        = "map"
  description = "Kubernetes resources for comm"

  default = {
    requests = {
      cpu    = 0.5
      memory = "2Gi"
    }
  }
}

variable "cognito_extra_values" {
  default     = []
  description = "Extra list of json/yaml values to pass to congnito helm release"
}

variable "iam_extra_values" {
  default     = []
  description = "Extra list of json/yaml values to pass to iam helm release"
}

variable "comm_extra_values" {
  default     = []
  description = "Extra list of json/yaml values to pass to comm helm release"
}

variable "enable_istio_ingress" {
  default     = false
  description = "Whether to create istio Gateway and VirtualService, must also specify external_dns"
}

variable "external_dns" {
  default     = ""
  description = "External DNS for the service"
}
