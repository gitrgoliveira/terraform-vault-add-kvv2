# terraform-vault-add-kvv2

Use-case module that creates a KV-v2 mount, read-only policy, and identity group binding for one principal entity.

## Layer

Use-case.

## Prerequisites

- Principal module output `entity_id` and `auth_role_name`
- Trust module output `jwt_auth_path`

## Inputs

| Name | Type | Description |
|---|---|---|
| `cluster_name` | `string` | Cluster/scope identifier, regex validated |
| `principal_name` | `string` | Principal identifier, regex validated |
| `usecase_name` | `string` | Use-case identifier, regex validated |
| `entity_id` | `string` | Principal entity ID |
| `auth_role_name` | `string` | Principal login role name |
| `jwt_auth_path` | `string` | Trust JWT auth path |
| `integration_type` | `string` | Consumption example style: `kubernetes` (default) or `gitlab` |
| `jwt_audience` | `string` | Render-only `aud` for the GitLab id_token, default `vault` |
| `k8s_namespace` | `string` | YAML render namespace (Kubernetes only) |
| `k8s_service_account` | `string` | Workload ServiceAccount for the rendered VaultAuth CR, default `default` |
| `vault_namespace` | `string` | Render-only |
| `vault_address` | `string` | Render-only |

## Outputs

| Name | Description |
|---|---|
| `kv_mount_path` | KV-v2 mount path |
| `policy_name` | Read policy name |
| `group_name` | Identity group name |
| `consumption_examples` | Rendered example(s) for consuming the secret, tailored to `integration_type` (Kubernetes injector + VSO, or GitLab CI/CD) |

## No-code notes

- One module run grants one principal one KV-v2 use-case.
- Authorization is delivered through identity group membership (`member_entity_ids = [entity_id]`).

## No-code provisioning

This module is no-code enabled in the `hc-ric-demo` private registry (pinned to `0.1.0`). Click **Provision workspace** on the module, pick a project and workspace name, then complete the form. `entity_id` and `auth_role_name` come from the principal module.

Form fields:

| Field | Required | Notes |
|---|---|---|
| `cluster_name` | yes | Cluster/scope identifier |
| `principal_name` | yes | Principal identifier |
| `usecase_name` | yes | Use-case identifier |
| `entity_id` | yes | Principal entity ID |
| `auth_role_name` | yes | Principal login role |
| `jwt_auth_path` | yes | From trust module |
| `integration_type` | no | `kubernetes` (default) or `gitlab`; selects the rendered consumption example |
| `jwt_audience` | no | GitLab id_token audience, default `vault` |
| `k8s_namespace` | no | YAML render namespace (Kubernetes only) |

## Registry usage

```hcl
module "add_kvv2" {
  source  = "app.terraform.io/<org>/add-kvv2/vault"
  version = "~> 0.1.0"

  cluster_name   = "ocp-prod-eu"
  principal_name = "payments"
  usecase_name   = "app-config"
  entity_id      = "11111111-2222-3333-4444-555555555555"
  auth_role_name = "ocp-prod-eu-payments"
  jwt_auth_path  = "jwt/ocp-prod-eu"
  k8s_namespace  = "payments-ns"
}
```

For a GitLab-based principal, set `integration_type = "gitlab"` (and omit the
`k8s_namespace`); `consumption_examples` then renders a GitLab CI/CD snippet.

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
  namespace: payments-ns
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
    VAULT_ADDR: "https://vault.example.com"
    VAULT_NAMESPACE: "admin/prod/payments"
  script:
    - export VAULT_TOKEN="$(vault write -field=token auth/jwt/ocp-prod-eu/login role=ocp-prod-eu-payments jwt=$VAULT_ID_TOKEN)"
    - vault kv get -namespace="admin/prod/payments" kv/ocp-prod-eu/payments/app-config/app
```
