# Changelog

All notable changes to this project are documented in this file.

## [0.1.0] - 2026-07-01

### Added
- `integration_type` input (`kubernetes` default, `gitlab`) selecting the rendered consumption example, so a GitLab-based principal gets a GitLab CI/CD login snippet instead of Kubernetes-only YAML.
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
