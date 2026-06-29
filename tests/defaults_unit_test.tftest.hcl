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
    condition     = strcontains(output.injector_yaml, "jwt/dev-cluster")
    error_message = "injector_yaml should include jwt_auth_path."
  }

  assert {
    condition     = strcontains(output.vso_yaml, "namespace: apps")
    error_message = "vso_yaml should include the configured k8s_namespace."
  }
}
