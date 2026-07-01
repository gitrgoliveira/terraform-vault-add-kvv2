provider "vault" {
  skip_child_token = true
}

locals {
  group_name    = "${var.cluster_name}-${var.principal_name}-${var.usecase_name}-kv"
  kv_mount_path = "kv/${var.cluster_name}/${var.principal_name}/${var.usecase_name}"
  policy_name   = "${var.cluster_name}-${var.principal_name}-${var.usecase_name}-kv-read"

  # Kubernetes workloads consume the secret through the Vault Agent Injector
  # and/or the Vault Secrets Operator, so both snippets are rendered together.
  k8s_examples = join("\n", [
    "# --- Vault Agent Injector pod annotations ---",
    templatefile("${path.module}/templates/injector-annotations.yaml.tftpl", {
      auth_role_name  = var.auth_role_name
      jwt_auth_path   = var.jwt_auth_path
      kv_mount_path   = local.kv_mount_path
      usecase_name    = var.usecase_name
      vault_address   = var.vault_address
      vault_namespace = var.vault_namespace
    }),
    "",
    "# --- Vault Secrets Operator (VSO) custom resources ---",
    templatefile("${path.module}/templates/vso-cr.yaml.tftpl", {
      auth_role_name      = var.auth_role_name
      jwt_auth_path       = var.jwt_auth_path
      k8s_namespace       = var.k8s_namespace
      k8s_service_account = var.k8s_service_account
      kv_mount_path       = local.kv_mount_path
      principal_name      = var.principal_name
      usecase_name        = var.usecase_name
      vault_namespace     = var.vault_namespace
    }),
  ])

  # GitLab pipelines log in with a project id_token bound to the JWT auth role.
  gitlab_examples = templatefile("${path.module}/templates/gitlab-ci.yml.tftpl", {
    auth_role_name  = var.auth_role_name
    jwt_audience    = var.jwt_audience
    jwt_auth_path   = var.jwt_auth_path
    kv_mount_path   = local.kv_mount_path
    vault_address   = var.vault_address
    vault_namespace = var.vault_namespace
  })

  consumption_examples = var.integration_type == "gitlab" ? local.gitlab_examples : local.k8s_examples
}

resource "vault_mount" "this" {
  path = local.kv_mount_path
  type = "kv-v2"
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

resource "vault_identity_group" "this" {
  name              = local.group_name
  type              = "internal"
  policies          = [vault_policy.this.name]
  member_entity_ids = [var.entity_id]
}
