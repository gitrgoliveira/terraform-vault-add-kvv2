mock_provider "vault" {}

run "invalid_usecase_name_fails_validation" {
  command = plan

  variables {
    cluster_name  = "dev-cluster"
    usecase_name  = "INVALID_NAME"
    workload_name = "apps"
  }

  expect_failures = [
    var.usecase_name,
  ]
}

run "invalid_workload_name_fails_validation" {
  command = plan

  variables {
    cluster_name  = "dev-cluster"
    usecase_name  = "payments"
    workload_name = "INVALID_NAME"
  }

  expect_failures = [
    var.workload_name,
  ]
}

run "invalid_cluster_name_fails_validation" {
  command = plan

  variables {
    cluster_name  = "-bad"
    usecase_name  = "payments"
    workload_name = "apps"
  }

  expect_failures = [
    var.cluster_name,
  ]
}

run "invalid_integration_type_fails_validation" {
  command = plan

  variables {
    cluster_name     = "dev-cluster"
    integration_type = "nomad"
    usecase_name     = "payments"
    workload_name    = "apps"
  }

  expect_failures = [
    var.integration_type,
  ]
}
