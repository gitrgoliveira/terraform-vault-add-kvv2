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
| `cluster_name` | `string` | Cluster identifier, regex validated |
| `principal_name` | `string` | Principal identifier, regex validated |
| `usecase_name` | `string` | Use-case identifier, regex validated |
| `entity_id` | `string` | Principal entity ID |
| `auth_role_name` | `string` | Principal login role name |
| `jwt_auth_path` | `string` | Trust JWT auth path |
| `k8s_namespace` | `string` | YAML render namespace |
| `k8s_service_account` | `string` | Workload ServiceAccount for the rendered VaultAuth CR, default `default` |
| `vault_namespace` | `string` | Render-only |
| `vault_address` | `string` | Render-only |

## Outputs

| Name | Description |
|---|---|
| `kv_mount_path` | KV-v2 mount path |
| `policy_name` | Read policy name |
| `group_name` | Identity group name |
| `injector_yaml` | Vault Agent Injector annotations YAML |
| `vso_yaml` | Vault Secrets Operator VaultStaticSecret YAML |

## No-code notes

- One module run grants one principal one KV-v2 use-case.
- Authorization is delivered through identity group membership (`member_entity_ids = [entity_id]`).

## No-code provisioning

This module is no-code enabled in the `hc-ric-demo` private registry (pinned to `0.0.1`). Click **Provision workspace** on the module, pick a project and workspace name, then complete the form. `entity_id` and `auth_role_name` come from the principal module.

Form fields:

| Field | Required | Notes |
|---|---|---|
| `cluster_name` | yes | Cluster identifier |
| `principal_name` | yes | Principal identifier |
| `usecase_name` | yes | Use-case identifier |
| `entity_id` | yes | Principal entity ID |
| `auth_role_name` | yes | Principal login role |
| `jwt_auth_path` | yes | From trust module |
| `k8s_namespace` | yes | YAML render namespace |

## Registry usage

```hcl
module "add_kvv2" {
  source  = "app.terraform.io/<org>/add-kvv2/vault"
  version = "~> 0.1"

  cluster_name   = "ocp-prod-eu"
  principal_name = "payments"
  usecase_name   = "app-config"
  entity_id      = "11111111-2222-3333-4444-555555555555"
  auth_role_name = "ocp-prod-eu-payments"
  jwt_auth_path  = "jwt/ocp-prod-eu"
  k8s_namespace  = "payments-ns"
}
```

## Example rendered YAML

`injector_yaml` example:

```yaml
vault.hashicorp.com/agent-inject: "true"
vault.hashicorp.com/role: "ocp-prod-eu-payments"
vault.hashicorp.com/auth-path: "jwt/ocp-prod-eu"
vault.hashicorp.com/service: "https://vault.example.com"
vault.hashicorp.com/namespace: "admin/prod/payments"
vault.hashicorp.com/agent-inject-secret-app-config.json: "kv/ocp-prod-eu/payments/app-config/data/app"
```

`vso_yaml` example:

```yaml
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
  name: payments-app-config
  namespace: payments-ns
spec:
  vaultAuthRef: ocp-prod-eu-payments
  mount: kv/ocp-prod-eu/payments/app-config
  type: kv-v2
  path: app
  refreshAfter: 30s
  destination:
    create: true
    name: payments-app-config
```
