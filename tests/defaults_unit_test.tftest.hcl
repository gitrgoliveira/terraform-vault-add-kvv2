mock_provider "vault" {}

run "defaults_plan_succeeds" {
  command = plan

  variables {
    auth_role_name = "dev-cluster-apps"
    cluster_name   = "dev-cluster"
    entity_id      = "entity-123"
    jwt_auth_path  = "jwt/dev-cluster"
    k8s_namespace  = "apps"
    principal_name = "apps"
    usecase_name   = "payments"
  }

  assert {
    condition     = output.kv_mount_path == "kv/dev-cluster/apps/payments"
    error_message = "kv_mount_path should be derived from cluster, principal, and use case."
  }

  assert {
    condition     = output.policy_name == "dev-cluster-apps-payments-kv-read"
    error_message = "policy_name should match naming convention."
  }

  assert {
    condition     = output.group_name == "dev-cluster-apps-payments-kv"
    error_message = "group_name should match naming convention."
  }

  assert {
    condition     = strcontains(output.consumption_examples, "jwt/dev-cluster")
    error_message = "kubernetes consumption_examples should include jwt_auth_path."
  }

  assert {
    condition     = strcontains(output.consumption_examples, "namespace: apps")
    error_message = "kubernetes consumption_examples should include the configured k8s_namespace (VSO snippet)."
  }

  assert {
    condition     = strcontains(output.consumption_examples, "agent-inject")
    error_message = "kubernetes consumption_examples should include the Vault Agent Injector snippet."
  }
}

run "gitlab_plan_succeeds" {
  command = plan

  variables {
    auth_role_name   = "dev-cluster-apps"
    cluster_name     = "dev-cluster"
    entity_id        = "entity-123"
    integration_type = "gitlab"
    jwt_auth_path    = "jwt/dev-cluster"
    principal_name   = "apps"
    usecase_name     = "payments"
  }

  assert {
    condition     = strcontains(output.consumption_examples, "VAULT_ID_TOKEN")
    error_message = "gitlab consumption_examples should render a GitLab CI id_token snippet."
  }

  assert {
    condition     = strcontains(output.consumption_examples, "auth/jwt/dev-cluster/login")
    error_message = "gitlab consumption_examples should log in against the JWT auth path."
  }

  assert {
    condition     = strcontains(output.consumption_examples, "aud: vault")
    error_message = "gitlab consumption_examples should default the id_token audience to vault."
  }

  assert {
    condition     = !strcontains(output.consumption_examples, "VaultStaticSecret")
    error_message = "gitlab consumption_examples should not include the Kubernetes VSO snippet."
  }
}
