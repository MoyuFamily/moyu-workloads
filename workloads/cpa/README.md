# CPA workload packaging

This directory packages CLIProxyAPI as a generic `command` Artifact for `kb13` (`aarch64`). It contains no passwords, provider credentials, OAuth files, or client API keys.

## Pinned upstream input

- Release: CLIProxyAPI `v8.0.10`
- Official Linux asset: `CLIProxyAPI_8.0.10_linux_aarch64.tar.gz`
- URL: <https://github.com/router-for-me/CLIProxyAPI/releases/download/v8.0.10/CLIProxyAPI_8.0.10_linux_aarch64.tar.gz>
- Official archive SHA256: `80aa0615d5d538c1988542ab99bc2d9a7b46360814c0f8c93db9e30127e249ff`
- Archive member used as the executable asset: `cli-proxy-api`
- Extracted executable SHA256: `1907830c0bb24ef3377c98609ef69899e5a375139c9ec2b6043779492fdfa391`

The Unified Workload Multi-Asset source packages individual files, so the executable asset is the verified `cli-proxy-api` member, not the upstream tarball. The binary, this `bootstrap.sh`, and `config.initial.yaml` are the only runtime assets. Keep this README out of the MOYUWORK1 inventory.

## Runtime contract

- Runtime command: select `./bootstrap.sh` as the command entrypoint. The script then executes `cli-proxy-api --config <persistent config path>`.
- `MOYU_WORKLOAD_ROOT` holds `config.yaml` and `auths/`; both survive Artifact updates and restarts.
- `MOYU_ARTIFACT_ROOT` is the immutable current Artifact directory containing the binary and initial template.
- The initial config binds only to `127.0.0.1:8317`. OAuth `auth-dir` is initialized under the persistent root because this pinned version does not expand environment variables in that field.
- The initial config is copied only when persistent `config.yaml` is absent. A later Artifact template never replaces it.
- vps-deploy injects `MANAGEMENT_PASSWORD` from the `cpa-management-key` secret reference. The password is not stored here or in the Artifact.
- The health endpoint for this pinned version is `/healthz`.

## First-start access gate

`access.api-keys` intentionally starts empty so no client key is packaged. In v8.0.10 the inference auth middleware permits requests when no API-key provider is configured. Therefore, do not configure or activate the public `cpa.moyuday.com` exposure while `config.yaml` has no client API key.

First deploy with no Cloudflare Tunnel exposure. Open the Management UI through an SSH local port-forward to `127.0.0.1:8317`, sign in with the injected Management password, and create a client API key. Confirm an unauthenticated inference request is rejected and an authenticated request succeeds; only then add the public exposure to `config/fleet.yaml` and converge it through the standard vps-deploy lifecycle. Keep client keys and provider OAuth state in CPA's persistent runtime state, never in Fleet, this repository, or the Artifact.

## Source verification

The v8.0.10 tag was checked for the `--config` option, config version 8 schema, `MANAGEMENT_PASSWORD`, empty-key middleware behavior, Management UI routes, and `/healthz`. Recheck these facts whenever changing the pinned upstream version.
