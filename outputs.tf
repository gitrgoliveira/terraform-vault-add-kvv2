output "consumption_examples" {
  description = "Rendered example(s) showing how the target workload consumes the KV secret, tailored to integration_type (Kubernetes injector + VSO, or GitLab CI/CD)."
  value       = local.consumption_examples
}

output "group_name" {
  description = "Identity group name granting the KV read policy."
  value       = vault_identity_group.this.name
}

output "kv_mount_path" {
  description = "KV-v2 mount path created by this use-case module."
  value       = vault_mount.this.path
}

output "policy_name" {
  description = "KV read policy name."
  value       = vault_policy.this.name
}
