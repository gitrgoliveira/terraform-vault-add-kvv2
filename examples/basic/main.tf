terraform {
  required_version = ">= 1.9"
}

locals {
  principal_auth_role_name = "ocp-prod-eu-payments"
  principal_cluster_name   = "ocp-prod-eu"
  principal_entity_id      = "11111111-2222-3333-4444-555555555555"
  principal_name           = "payments"
  trust_jwt_auth_path      = "jwt/ocp-prod-eu"
}

module "add_kvv2" {
  source = "../../"

  auth_role_name   = local.principal_auth_role_name
  cluster_name     = local.principal_cluster_name
  entity_id        = local.principal_entity_id
  integration_type = var.integration_type
  jwt_auth_path    = local.trust_jwt_auth_path
  k8s_namespace    = var.k8s_namespace
  principal_name   = local.principal_name
  usecase_name     = var.usecase_name
}

variable "integration_type" {
  type        = string
  description = "Workload integration style for the rendered consumption example: kubernetes or gitlab."
  default     = "kubernetes"
}

variable "k8s_namespace" {
  type        = string
  description = "Namespace for rendered Kubernetes YAML snippets (used when integration_type = kubernetes)."
  default     = ""
}

variable "usecase_name" {
  type        = string
  description = "Use-case identifier."
}
