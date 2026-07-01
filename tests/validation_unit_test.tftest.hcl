mock_provider "vault" {}

run "invalid_usecase_name_fails_validation" {
  command = plan

  variables {
    auth_role_name = "dev-cluster-apps"
    cluster_name   = "dev-cluster"
    entity_id      = "entity-123"
    jwt_auth_path  = "jwt/dev-cluster"
    principal_name = "apps"
    usecase_name   = "INVALID_NAME"
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
    principal_name = "apps"
    usecase_name   = "payments"
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
    principal_name   = "apps"
    usecase_name     = "payments"
  }

  expect_failures = [
    var.integration_type,
  ]
}
