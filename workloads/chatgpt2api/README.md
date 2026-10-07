# chatgpt2api on kb13

Compose source for the standard Unified Artifact Manager. Upstream:
[basketikun/chatgpt2api](https://github.com/basketikun/chatgpt2api).
The pinned image is version 1.8.0, revision
`e55aef2829e7bf1d7256d6ff3feb4b40b02743d2`, linux/arm64.

The workload binds only `127.0.0.1:8320`. Engine/Compose are prepared through
Fleet Host `enableDocker: true`; no separate remote installation script is used.
The container has a 512 MiB memory limit and a 256-process limit.

Build Contract includes `compose.yaml`, `bootstrap.sh`, `config.initial.json`,
and `health.py`. Runtime is `compose`, with an immutable image lock for `app`.
Health is the command `python3 health.py`. It accepts the expected initial
`degraded` state when the account pool is empty, while requiring a valid
application response. API generation still requires accounts to be imported.

Instance configuration declares `listenPorts: [8320]`, a startup grace window,
and `envRefs.CHATGPT2API_AUTH_KEY: chatgpt2api-auth-key`. The real key stays in
the deployment repository's local `.env` and Actions workload secret store.
It is never included in this source or the Artifact.

`bootstrap.sh` preserves `config.json` and `data/` under the manager-provided
stable `/moyu/workload` mount. It connects upstream's `/app/config.json` and
`/app/data` to that persistent state before starting the original application.
The image runs with its upstream default user; files created by the container
are owned by root on the Host. Back up both paths before destructive reinstall
or workload removal.

For access from an operator machine, forward a local port over the configured
kb13 SSH connection, then open `http://127.0.0.1:8320`; the API base is
`http://127.0.0.1:8320/v1`. Obtain the auth key from the private secret store.

Updates must resolve and review a new upstream image digest, then publish a
new MOYUWORK1 Artifact through the manager. Do not replace the pinned image
with a mutable tag or run `docker compose up` outside the managed lifecycle.
