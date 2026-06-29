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

variable "principal_name" {
  type        = string
  description = "Principal identifier used in mount, policy, and group naming."

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,30}[a-z0-9]$", var.principal_name))
    error_message = "principal_name must match ^[a-z][a-z0-9-]{0,30}[a-z0-9]$."
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
