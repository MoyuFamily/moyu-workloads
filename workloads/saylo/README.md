# Saylo on kb13

Runtime-only Compose source for the unified MOYUWORK1 Artifact pipeline.
The upstream image is private: `ghcr.io/parsifalc/saylo`.

kb13 is `aarch64`. The pinned image is `ghcr.io/parsifalc/saylo@sha256:6d472fee4c9950aebd7c314aa17dcd2cfb3b8efe815a8919876d8df68fa48fd4`.
Upstream commit: `b028c1b321a98091bfe8c0e2989acc5a48e853dd`. Both linux/amd64 and linux/arm64 were
built and health-tested on native CI runners before index promotion.

The Build Contract should include only `compose.yaml`. The README and
`instance.example.yaml` are integration documentation, not runtime payload.
The pipeline locks the image into `imageLocks`; do not deploy a floating tag
outside the managed lifecycle or build application code on the VPS.

`instance.example.yaml` describes the intended `kb13-saylo` configuration.
Registry aliases belong in `WORKLOAD_SECRETS_JSON` and are exclusively used
by the Manager/Host Docker operations. Business credentials use separate
`envRefs`; the CPA inference key is distinct from its management password.

Host networking permits local CPA access at `http://127.0.0.1:8317/v1`.
Saylo binds `127.0.0.1:3100`; the standard runtime mounts stable instance
state at `/moyu/workload`, with SQLite under `/moyu/workload/data`.
The health endpoint is `/api/health`.

`saylo.moyuday.com` uses the existing kb13 Cloudflare Tunnel. Fleet exposure
is `public` because Saylo implements username/password login and validates
its login cookie for `/rt`; no bearer-token `authEnv` contract is claimed.
Verify unauthenticated API/WS rejection and authenticated access after deployment.
Upstream documents prior WebSocket pacing issues through a proxy, so actual
audio pacing and interruption behavior through the Tunnel require acceptance.

Protect the locked deployment digest with upstream's `GHCR_PROTECTED_DIGESTS`
repository variable, preserving any existing protected digests. The registry
image and the public MOYU Artifact ZIP have independent retention lifecycles.

Coach and search both use `gpt-6-luna`. All ten voice previews are
committed in the upstream image and were generated using CPA Realtime.
The Artifact health command checks loopback `/api/health` with curl.
