# Changelog

All notable changes to this project are documented in this file.

## [0.5.1] - 2026-07-29

### Fixed

- Documented that GitLab integrations must pass the `gitlab_instance_name` as `cluster_name` (one of `cloud`, `dedicated-prod`, `dedicated-dev`); added a GitLab registry usage example with matching rendered output.

## [0.5.0] - 2026-07-24

### Changed
- BREAKING: removed the `entity_id` input variable. The workload entity is now discovered automatically via `data "vault_identity_entity"` using the entity name derived from `cluster_name` and `workload_name`. The workload module must be applied first so the entity exists.

## [0.4.0] - 2026-07-24

### Changed
- BREAKING: removed 7 render-only input variables (`auth_role_name`, `jwt_auth_path`, `jwt_audience`, `vault_address`, `vault_namespace`, `k8s_namespace`, `k8s_service_account`), reducing the no-code form from 12 fields to 5.
- `auth_role_name` is now derived as `"${cluster_name}-${workload_name}"`, matching the workload module naming convention.
- `jwt_auth_path` is now derived as `"jwt/${cluster_name}"` (kubernetes) or `"jwt-gitlab/${cluster_name}"` (gitlab), matching the trust module mount paths.
- `jwt_audience` is hardcoded to `vault` in the GitLab CI template.
- `vault_address`, `vault_namespace`, `k8s_namespace`, and `k8s_service_account` are replaced with `<PLACEHOLDER>` tokens in rendered templates for the operator to fill in at deployment time.

## [0.3.0] - 2026-07-24

### Added
- `workload_name` negative validation test in `tests/validation_unit_test.tftest.hcl`.
- `description` argument on the `vault_mount` resource.

### Fixed
- Removed redundant `-namespace` flag from the rendered `vault kv get` command in the GitLab CI template; the `VAULT_NAMESPACE` environment variable is sufficient.

## [0.2.0] - 2026-07-07

### Changed
- BREAKING: renamed the `principal_name` input to `workload_name` to align with the "workload" onboarding terminology. Consumers must update the input name.

## [0.1.0] - 2026-07-01

### Added
- `integration_type` input (`kubernetes` default, `gitlab`) selecting the rendered consumption example, so a GitLab-based workload gets a GitLab CI/CD login snippet instead of Kubernetes-only YAML.
- `jwt_audience` input (default `vault`) for the GitLab id_token `aud` claim.
- `templates/gitlab-ci.yml.tftpl` rendering a GitLab pipeline job that logs in with a project id_token and reads the KV secret.

### Changed
- **Breaking:** replaced the `injector_yaml` and `vso_yaml` outputs with a single `consumption_examples` output whose content is tailored to `integration_type` (Kubernetes renders the injector annotations and the VSO custom resources together; GitLab renders the CI/CD job). The underlying Vault resources (mount, policy, identity group) are unchanged.

## [0.0.2] - 2026-06-29

### Changed
- Documentation and version-consistency fixes: corrected the no-code registry pin, the registry-usage version constraint, and the CHANGELOG release header.

## [0.0.1]

### Added
- Initial no-code-ready module implementation.
