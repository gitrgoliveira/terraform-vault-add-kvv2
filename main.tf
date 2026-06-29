provider "vault" {
  skip_child_token = true
}

locals {
  group_name    = "${var.cluster_name}-${var.principal_name}-${var.usecase_name}-kv"
  kv_mount_path = "kv/${var.cluster_name}/${var.principal_name}/${var.usecase_name}"
  policy_name   = "${var.cluster_name}-${var.principal_name}-${var.usecase_name}-kv-read"
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
