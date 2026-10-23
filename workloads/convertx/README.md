# ConvertX on kb18

Runtime Compose source for the unified MOYUWORK1 v2 Artifact pipeline. Upstream:
[c4illin/ConvertX](https://github.com/C4illin/ConvertX).
The official linux/amd64 image is pinned by digest in `compose.yaml`; no
application build is needed. Its startup command is `bun run dist/src/index.js`.

The Build Contract includes only `compose.yaml` and `bootstrap.sh`. The README
and `instance.example.yaml` are integration documentation, not runtime payload.
Runtime is `compose`, with an immutable image lock for service `convertx`.
Artifact health is the command
`curl --fail --silent --max-time 4 http://127.0.0.1:3300/healthcheck`.

`instance.example.yaml` describes the intended `kb18-convertx` configuration.
The app binds host loopback `127.0.0.1:3300` to container port 3000. Fleet exposes
`https://convertx.moyuday.com` through the existing kb18 Cloudflare Tunnel.
Initialize the first account through loopback before enabling public exposure.
Keep public registration and anonymous access disabled; the application handles
username/password login. `JWT_SECRET` uses the `convertx-jwt-secret` envRef.
The real value stays in the deployment repository's private `.env` and GitHub
Actions workload secret store, never this repository or the Artifact. Initial
administrator credentials also remain private in the deployment repository.

`bootstrap.sh` connects upstream `/app/data` to the manager's stable
`/moyu/workload/data` mount. Accounts, SQLite, uploads and conversion results
survive container recreation and Artifact upgrades. The process uses the
configured runtime UID/GID. Preserve the entire data directory for backups;
stop the workload or use SQLite's backup API for a consistent database copy.
Never place database or media state in an immutable Artifact release directory.

Initial limits: two concurrent conversions, one FFmpeg output thread per
conversion, two CPUs, 1 GiB container memory, and 256 tasks. Cleanup checks every
24 hours for files older than 24 hours, so retention can exceed one day.
The Cloudflare single-request upload limit applies; this deployment does not
add chunked upload support. Cached-download behavior and the initial acceptance
results are recorded in the deployment repository's
[operations record](https://github.com/MoyuFamily/moyu-vps-deploy/blob/main/docs/convertx-operations.md).

For updates, resolve and review a new official image digest, then use the
[standard manager lifecycle](https://github.com/MoyuFamily/moyu-vps-deploy/blob/main/docs/workload-maintenance.md)
with this directory as Source and the same Build Contract. Publish a new
immutable Artifact before updating the Fleet pointer and converging kb18.
Do not use a floating image tag or run Compose outside the managed lifecycle.
