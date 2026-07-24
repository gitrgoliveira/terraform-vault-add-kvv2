variable "cluster_name" {
  type        = string
  description = "Cluster identifier used in mount, policy, and group naming."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,30}[a-z0-9]$", var.cluster_name))
    error_message = "cluster_name must match ^[a-z][a-z0-9-]{0,30}[a-z0-9]$."
  }
}

variable "integration_type" {
  type        = string
  description = "Workload integration style for the rendered consumption example: kubernetes (Vault Agent Injector + Vault Secrets Operator) or gitlab (GitLab CI/CD id_token login)."
  default     = "kubernetes"

  validation {
    condition     = contains(["kubernetes", "gitlab"], var.integration_type)
    error_message = "integration_type must be one of: kubernetes, gitlab."
  }
}

variable "usecase_name" {
  type        = string
  description = "Use-case identifier used in mount, policy, and group naming."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,30}[a-z0-9]$", var.usecase_name))
    error_message = "usecase_name must match ^[a-z][a-z0-9-]{0,30}[a-z0-9]$."
  }
}

variable "workload_name" {
  type        = string
  description = "Workload identifier used in mount, policy, and group naming."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,30}[a-z0-9]$", var.workload_name))
    error_message = "workload_name must match ^[a-z][a-z0-9-]{0,30}[a-z0-9]$."
  }
}
