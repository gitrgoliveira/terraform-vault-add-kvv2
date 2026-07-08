mock_provider "vault" {}

run "invalid_usecase_name_fails_validation" {
  command = plan

  variables {
    auth_role_name = "dev-cluster-apps"
    cluster_name   = "dev-cluster"
    entity_id      = "entity-123"
    jwt_auth_path  = "jwt/dev-cluster"
    usecase_name   = "INVALID_NAME"
    workload_name  = "apps"
  }

  expect_failures = [
    var.usecase_name,
  ]
}

run "invalid_cluster_name_fails_validation" {
  command = plan

  variables {
    auth_role_name = "dev-cluster-apps"
    cluster_name   = "-bad"
    entity_id      = "entity-123"
    jwt_auth_path  = "jwt/dev-cluster"
    usecase_name   = "payments"
    workload_name  = "apps"
  }

  expect_failures = [
    var.cluster_name,
  ]
}

run "invalid_integration_type_fails_validation" {
  command = plan

  variables {
    auth_role_name   = "dev-cluster-apps"
    cluster_name     = "dev-cluster"
    entity_id        = "entity-123"
    integration_type = "nomad"
    jwt_auth_path    = "jwt/dev-cluster"
    usecase_name     = "payments"
    workload_name    = "apps"
  }

  expect_failures = [
    var.integration_type,
  ]
}
