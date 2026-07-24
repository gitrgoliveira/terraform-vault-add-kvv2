terraform {
  required_version = ">= 1.9"
}

locals {
  workload_cluster_name = "ocp-prod-eu"
  workload_name         = "payments"
}

module "add_kvv2" {
  source = "../../"

  cluster_name     = local.workload_cluster_name
  integration_type = var.integration_type
  usecase_name     = var.usecase_name
  workload_name    = local.workload_name
}

variable "integration_type" {
  type        = string
  description = "Workload integration style for the rendered consumption example: kubernetes or gitlab."
  default     = "kubernetes"
}

variable "usecase_name" {
  type        = string
  description = "Use-case identifier."
}
