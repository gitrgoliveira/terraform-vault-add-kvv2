provider "vault" {
  skip_child_token = true
}

locals {
  auth_role_name = "${var.cluster_name}-${var.workload_name}"
  group_name     = "${var.cluster_name}-${var.workload_name}-${var.usecase_name}-kv"
  jwt_auth_path  = var.integration_type == "gitlab" ? "jwt-gitlab/${var.cluster_name}" : "jwt/${var.cluster_name}"
  kv_mount_path  = "kv/${var.cluster_name}/${var.workload_name}/${var.usecase_name}"
  policy_name    = "${var.cluster_name}-${var.workload_name}-${var.usecase_name}-kv-read"

  # Kubernetes workloads consume the secret through the Vault Agent Injector
  # and/or the Vault Secrets Operator, so both snippets are rendered together.
  k8s_examples = join("\n", [
    "# --- Vault Agent Injector pod annotations ---",
    templatefile("${path.module}/templates/injector-annotations.yaml.tftpl", {
      auth_role_name = local.auth_role_name
      jwt_auth_path  = local.jwt_auth_path
      kv_mount_path  = local.kv_mount_path
      usecase_name   = var.usecase_name
    }),
    "",
    "# --- Vault Secrets Operator (VSO) custom resources ---",
    templatefile("${path.module}/templates/vso-cr.yaml.tftpl", {
      auth_role_name = local.auth_role_name
      jwt_auth_path  = local.jwt_auth_path
      kv_mount_path  = local.kv_mount_path
      usecase_name   = var.usecase_name
      workload_name  = var.workload_name
    }),
  ])

  # GitLab pipelines log in with a project id_token bound to the JWT auth role.
  gitlab_examples = templatefile("${path.module}/templates/gitlab-ci.yml.tftpl", {
    auth_role_name = local.auth_role_name
    jwt_auth_path  = local.jwt_auth_path
    kv_mount_path  = local.kv_mount_path
  })

  consumption_examples = var.integration_type == "gitlab" ? local.gitlab_examples : local.k8s_examples
}

resource "vault_mount" "this" {
  description = "KV-v2 store for ${var.workload_name}/${var.usecase_name}"
  path        = local.kv_mount_path
  type        = "kv-v2"
}

resource "vault_policy" "this" {
  name = local.policy_name

  policy = <<-EOT
path "${local.kv_mount_path}/data/*" {
  capabilities = ["read"]
}

path "${local.kv_mount_path}/metadata/*" {
  capabilities = ["list"]
}
EOT
}

data "vault_identity_entity" "workload" {
  entity_name = local.auth_role_name
}

resource "vault_identity_group" "this" {
  name              = local.group_name
  type              = "internal"
  policies          = [vault_policy.this.name]
  member_entity_ids = [data.vault_identity_entity.workload.id]
}
