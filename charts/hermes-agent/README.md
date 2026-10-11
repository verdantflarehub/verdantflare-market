# hermes-agent Chart candidate

Review status: **candidate, not an installable release**. The default renders no workload. This is the single Chart source for Hub ID `hermes-agent`. It is not a verified Station package and has no GPU claim.

## Upstream evidence

- Official runtime documentation: https://hermes-agent.nousresearch.com/docs/user-guide/docker
- Candidate image repository: `docker.io/nousresearch/hermes-agent`. A specific tag and digest must be audited and supplied before deployment.
- Single replica, internal port `8642`, dedicated PVC at `/opt/data`. No Ingress, NodePort, Docker socket, host paths, privileged container or GPU request.
- Existing Secret must contain `API_SERVER_KEY`. Model-provider credentials and external connector credentials need separate controlled configuration.
- Ingress is limited to the named Studio namespace. Egress is denied until a target-specific allowlist is reviewed and applied; this default intentionally cannot call external models.

## Review gates

1. Fix an upstream source revision, immutable image tag and audit digest; audit image contents, dependencies and license. Record multi-architecture support.
2. Create a per-instance Secret and select a verified StorageClass (`storage.storageClassName`). Confirm data ownership, backup and uninstall behavior.
3. Review startup, health, UID/security context, model egress, tool permissions, Studio authentication proxy and target Station behavior.
4. Only then set `install.enabled=true` with reviewed values. `helm lint` and static rendering alone are not runtime validation.

Use `helm lint charts/hermes-agent` and `helm template review charts/hermes-agent` for syntax checks. An enabled render without required inputs fails. Do not apply this Chart to a cluster in its current review state.
