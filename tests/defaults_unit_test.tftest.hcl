mock_provider "vault" {}

run "defaults_plan_succeeds" {
  command = plan

  variables {
    cluster_name  = "dev-cluster"
    usecase_name  = "payments"
    workload_name = "apps"
  }

  assert {
    condition     = output.kv_mount_path == "kv/dev-cluster/apps/payments"
    error_message = "kv_mount_path should be derived from cluster, workload, and use case."
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
    error_message = "kubernetes consumption_examples should include the derived jwt_auth_path."
  }

  assert {
    condition     = strcontains(output.consumption_examples, "<K8S_NAMESPACE>")
    error_message = "kubernetes consumption_examples should include the K8S_NAMESPACE placeholder."
  }

  assert {
    condition     = strcontains(output.consumption_examples, "agent-inject")
    error_message = "kubernetes consumption_examples should include the Vault Agent Injector snippet."
  }

  assert {
    condition     = strcontains(output.consumption_examples, "role: dev-cluster-apps")
    error_message = "kubernetes consumption_examples should include the derived auth_role_name."
  }

  assert {
    condition     = strcontains(output.consumption_examples, "auth-config-path: \"/var/run/secrets/vault.hashicorp.com/serviceaccount/token\"")
    error_message = "the injector snippet must point Vault Agent's JWT method at the projected token (it fails without 'path')."
  }

  assert {
    condition     = strcontains(output.consumption_examples, "agent-service-account-token-volume-name: \"vault-token\"")
    error_message = "the injector must mount the projected token volume, or auth-config-path points at nothing."
  }

  assert {
    condition     = strcontains(output.consumption_examples, "audiences:\n      - vault")
    error_message = "the VaultAuth must request a token with the workload role's bound audience."
  }
}

run "gitlab_plan_succeeds" {
  command = plan

  variables {
    cluster_name     = "dev-cluster"
    integration_type = "gitlab"
    usecase_name     = "payments"
    workload_name    = "apps"
  }

  assert {
    condition     = strcontains(output.consumption_examples, "VAULT_ID_TOKEN")
    error_message = "gitlab consumption_examples should render a GitLab CI id_token snippet."
  }

  assert {
    condition     = strcontains(output.consumption_examples, "auth/jwt-gitlab/dev-cluster/login")
    error_message = "gitlab consumption_examples should log in against the derived JWT auth path."
  }

  assert {
    condition     = strcontains(output.consumption_examples, "aud: vault")
    error_message = "gitlab consumption_examples should use the hardcoded audience vault."
  }

  assert {
    condition     = !strcontains(output.consumption_examples, "VaultStaticSecret")
    error_message = "gitlab consumption_examples should not include the Kubernetes VSO snippet."
  }

  assert {
    condition     = strcontains(output.consumption_examples, "role=dev-cluster-apps")
    error_message = "gitlab consumption_examples should include the derived auth_role_name."
  }
}
