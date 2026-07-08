variable "auth_role_name" {
  type        = string
  description = "JWT auth role name used by workloads for login."
}

variable "cluster_name" {
  type        = string
  description = "Cluster identifier used in mount, policy, and group naming."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,30}[a-z0-9]$", var.cluster_name))
    error_message = "cluster_name must match ^[a-z][a-z0-9-]{0,30}[a-z0-9]$."
  }
}

variable "entity_id" {
  type        = string
  description = "Vault entity ID that receives this use-case policy via identity group membership."
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

variable "jwt_audience" {
  type        = string
  description = "Render-only audience (aud) claim for the GitLab id_token in the rendered CI example. Must match the trust's bound_audiences; defaults to vault."
  default     = "vault"
}

variable "jwt_auth_path" {
  type        = string
  description = "JWT auth path used for rendered workload integration snippets."
}

variable "k8s_namespace" {
  type        = string
  description = "Kubernetes namespace used in rendered YAML snippets."
  default     = ""
}

variable "k8s_service_account" {
  type        = string
  description = "Workload Kubernetes ServiceAccount referenced by the rendered VaultAuth CR; VSO mints its projected JWT for Vault login."
  default     = "default"
}

variable "usecase_name" {
  type        = string
  description = "Use-case identifier used in mount, policy, and group naming."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,30}[a-z0-9]$", var.usecase_name))
    error_message = "usecase_name must match ^[a-z][a-z0-9-]{0,30}[a-z0-9]$."
  }
}

variable "vault_address" {
  type        = string
  description = "Render-only Vault address value supplied via TF_VAR_vault_address."
  default     = ""
}

variable "vault_namespace" {
  type        = string
  description = "Render-only Vault namespace value supplied via TF_VAR_vault_namespace."
  default     = ""
}

variable "workload_name" {
  type        = string
  description = "Workload identifier used in mount, policy, and group naming."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,30}[a-z0-9]$", var.workload_name))
    error_message = "workload_name must match ^[a-z][a-z0-9-]{0,30}[a-z0-9]$."
  }
}
