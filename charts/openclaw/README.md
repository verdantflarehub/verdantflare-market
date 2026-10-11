# openclaw Chart candidate

Review status: **candidate, not an installable release**. The default renders no workload. This is the single Chart source for Hub ID `openclaw`. It is not a verified Station package and has no GPU claim.

## Upstream evidence

- Official runtime documentation: https://docs.openclaw.ai/install/docker
- Candidate image repository: `ghcr.io/openclaw/openclaw`. A specific tag and digest must be audited and supplied before deployment.
- Single replica, internal port `18789`, dedicated PVC at `/home/node/.openclaw`. No Ingress, NodePort, Docker socket, host paths, privileged container or GPU request.
- Existing Secret must contain `OPENCLAW_GATEWAY_TOKEN`. Model-provider credentials and external connector credentials need separate controlled configuration.
- Ingress is limited to the named Studio namespace. Egress is denied until a target-specific allowlist is reviewed and applied; this default intentionally cannot call external models.

## Review gates

1. Fix an upstream source revision, immutable image tag and audit digest; audit image contents, dependencies and license. Record multi-architecture support.
2. Create a per-instance Secret and select a verified StorageClass (`storage.storageClassName`). Confirm data ownership, backup and uninstall behavior.
3. Review startup, health, UID/security context, model egress, tool permissions, Studio authentication proxy and target Station behavior.
4. Only then set `install.enabled=true` with reviewed values. `helm lint` and static rendering alone are not runtime validation.

Use `helm lint charts/openclaw` and `helm template review charts/openclaw` for syntax checks. An enabled render without required inputs fails. Do not apply this Chart to a cluster in its current review state.
