output "group_name" {
  description = "Identity group name granting the KV read policy."
  value       = vault_identity_group.this.name
}

output "injector_yaml" {
  description = "Rendered Vault Agent Injector annotations snippet."
  value = templatefile("${path.module}/templates/injector-annotations.yaml.tftpl", {
    auth_role_name  = var.auth_role_name
    jwt_auth_path   = var.jwt_auth_path
    kv_mount_path   = local.kv_mount_path
    usecase_name    = var.usecase_name
    vault_address   = var.vault_address
    vault_namespace = var.vault_namespace
  })
}

output "kv_mount_path" {
  description = "KV-v2 mount path created by this use-case module."
  value       = vault_mount.this.path
}

output "policy_name" {
  description = "KV read policy name."
  value       = vault_policy.this.name
}

output "vso_yaml" {
  description = "Rendered Vault Secrets Operator VaultStaticSecret snippet."
  value = templatefile("${path.module}/templates/vso-cr.yaml.tftpl", {
    auth_role_name      = var.auth_role_name
    jwt_auth_path       = var.jwt_auth_path
    k8s_namespace       = var.k8s_namespace
    k8s_service_account = var.k8s_service_account
    kv_mount_path       = local.kv_mount_path
    principal_name      = var.principal_name
    usecase_name        = var.usecase_name
    vault_namespace     = var.vault_namespace
  })
}
