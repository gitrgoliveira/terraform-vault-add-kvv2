# terraform-vault-add-kvv2

Use-case module that creates a KV-v2 mount, read-only policy, and identity group binding for one workload entity.

## Layer

Use-case.

## Prerequisites

- The workload module (`add-k8s-namespace-access` or `add-gitlab-project-access`) must be applied first so the identity entity exists in Vault.

## Inputs

| Name | Type | Description |
|---|---|---|
| `cluster_name` | `string` | Cluster/scope identifier, regex validated |
| `integration_type` | `string` | Consumption example style: `kubernetes` (default) or `gitlab` |
| `usecase_name` | `string` | Use-case identifier, regex validated |
| `workload_name` | `string` | Workload identifier, regex validated |

## Outputs

| Name | Description |
|---|---|
| `consumption_examples` | Rendered example(s) for consuming the secret, tailored to `integration_type` (Kubernetes injector + VSO, or GitLab CI/CD) |
| `group_name` | Identity group name |
| `kv_mount_path` | KV-v2 mount path |
| `policy_name` | Read policy name |

## Derived values

The module derives `auth_role_name` and `jwt_auth_path` internally from `cluster_name`, `workload_name`, and `integration_type`, matching the naming conventions used by the workload and trust modules:

- `auth_role_name` = `"${cluster_name}-${workload_name}"`
- `jwt_auth_path` = `"jwt/${cluster_name}"` (kubernetes) or `"jwt-gitlab/${cluster_name}"` (gitlab)

> **GitLab note:** When `integration_type = "gitlab"`, set `cluster_name` to the `gitlab_instance_name` used by the `gitlab-onboarding` and `add-gitlab-project-access` modules — one of `cloud`, `dedicated-prod`, or `dedicated-dev` — not a Kubernetes cluster identifier. Both the entity lookup and the auth path derive from it, so any other value points at mounts and entities that do not exist.

Environment-specific values (`VAULT_ADDRESS`, `VAULT_NAMESPACE`) and Kubernetes deployment details (`K8S_NAMESPACE`, `K8S_SERVICE_ACCOUNT`) appear as `<PLACEHOLDER>` tokens in the rendered `consumption_examples`, to be filled in by the operator at deployment time.

## No-code notes

- One module run grants one workload one KV-v2 use-case.
- Authorization is delivered through identity group membership; the entity is discovered automatically via `data "vault_identity_entity"` using the name `"${cluster_name}-${workload_name}"`.

## No-code provisioning

This module is no-code enabled in the `hc-ric-demo` private registry (pinned to `0.5.0`). Click **Provision workspace** on the module, pick a project and workspace name, then complete the form.

Form fields:

| Field | Required | Notes |
|---|---|---|
| `cluster_name` | yes | Cluster/scope identifier |
| `integration_type` | no | `kubernetes` (default) or `gitlab`; selects the rendered consumption example |
| `usecase_name` | yes | Use-case identifier |
| `workload_name` | yes | Workload identifier |

## Registry usage

```hcl
module "add_kvv2" {
  source  = "app.terraform.io/<org>/add-kvv2/vault"
  version = "~> 0.5.0"

  cluster_name  = "ocp-prod-eu"
  usecase_name  = "app-config"
  workload_name = "payments"
}
```

For a GitLab-based workload, set `integration_type = "gitlab"` and pass the GitLab
instance name as `cluster_name`:

```hcl
module "add_kvv2_gitlab" {
  source  = "app.terraform.io/<org>/add-kvv2/vault"
  version = "~> 0.5.0"

  cluster_name     = "cloud" # the gitlab_instance_name used by the trust module
  usecase_name     = "app-config"
  workload_name    = "payments"
  integration_type = "gitlab"
}
```

`consumption_examples` then renders a GitLab CI/CD snippet with the `jwt-gitlab/` auth path.

## Example rendered output

`consumption_examples` with `integration_type = "kubernetes"` (default) contains
both the Vault Agent Injector annotations and the Vault Secrets Operator custom
resources:

```yaml
# --- Vault Agent Injector pod annotations ---
vault.hashicorp.com/agent-inject: "true"
vault.hashicorp.com/role: "ocp-prod-eu-payments"
vault.hashicorp.com/auth-path: "auth/jwt/ocp-prod-eu"
...

# --- Vault Secrets Operator (VSO) custom resources ---
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  name: payments-app-config
  namespace: <K8S_NAMESPACE>
...
```

`consumption_examples` with `integration_type = "gitlab"` renders a GitLab
pipeline job:

```yaml
read_vault_secret:
  id_tokens:
    VAULT_ID_TOKEN:
      aud: vault
  variables:
    VAULT_ADDR: "<VAULT_ADDRESS>"
    VAULT_NAMESPACE: "<VAULT_NAMESPACE>"
  script:
    - export VAULT_TOKEN="$(vault write -field=token auth/jwt-gitlab/cloud/login role=cloud-payments jwt=$VAULT_ID_TOKEN)"
    - vault kv get kv/cloud/payments/app-config/app
```
