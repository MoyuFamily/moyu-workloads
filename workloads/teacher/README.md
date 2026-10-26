# Teacher Workload definition

This directory contains integration data for the existing Unified Artifact
Pipeline: `build-plan.json` supplies the normal `BuildPlan` arguments, and
`instance.example.yaml` supplies deployment parameters. It contains no business
source, credentials, protocol implementation, or dedicated deployment entrypoint.

The private `ParsifalC/TeacherCinnamoroll` project owns its Node.js application,
tests, Linux compilation, startup/health commands and SQLite backup tooling.
Its kb26 CI produces `teacher-linux.tar.gz`, an application payload containing
Node.js 24 and `release-info.json`. It is not yet a MOYUWORK1 Artifact.

## Build through the existing pipeline

Download a reviewed CI payload and extract it into a new directory on the
management machine. A build runs in the deployment repository, where the generic
pipeline already exists. The application CI does not fetch this repository.
For example, with the payload at `/tmp/teacher-payload`, use the existing API:

```sh
PYTHONPATH=deploy/runtime:. python3.11 - \
  /tmp/teacher-payload \
  /path/to/moyu-workloads/workloads/teacher/build-plan.json \
  /tmp/workload-artifact.zip <<'PY'
import hashlib
import json
import sys
import tempfile
from pathlib import Path

from deploy.runtime.workloads.artifacts import WorkloadArtifactStore
from scripts.workload_pipeline import BuildPlan, LocalSourceAdapter, build_and_validate

source, definition, output = map(Path, sys.argv[1:])
source, output = source.resolve(), output.resolve()
if output.exists() or output == source or source in output.parents:
    raise ValueError("Output must be a new file outside the payload directory")
release = json.loads((source / "release-info.json").read_text())
if release["platform"] != "linux" or release["arch"] not in {"x64", "arm64"}:
    raise ValueError("Use a Linux payload matching the target architecture")
plan = BuildPlan(version=release["version"], **json.loads(definition.read_text()))
prepared = LocalSourceAdapter(source).prepare()
try:
    artifact = build_and_validate(prepared, plan)
    with tempfile.TemporaryDirectory() as directory:
        staged = WorkloadArtifactStore(Path(directory), plan.name, plan.workload_type).stage(artifact.payload)
        if staged.staged != artifact.fingerprint:
            raise RuntimeError("Staging fingerprint differs from the validated Artifact")
    output.parent.mkdir(parents=True, exist_ok=True)
    with output.open("xb") as stream:
        stream.write(artifact.payload)
    print(json.dumps({"expectedFingerprint": artifact.fingerprint,
                      "sha256": hashlib.sha256(artifact.payload).hexdigest()}, indent=2))
finally:
    prepared.cleanup()
PY
```

This is a direct use of the existing generic API. No control-plane source or
runtime branch needs to know the application name. The resulting ZIP is a
standard self-describing Artifact and can be supplied to Manager's existing
URL/file input.

## Publish and deploy

Application code is private, so keep its Release artifacts in
`ParsifalC/TeacherCinnamoroll`. Confirm that repository is private before publishing.
Use the existing Manager repository override when adding/updating this workload:

```sh
WORKLOAD_ARTIFACT_REPOSITORY=ParsifalC/TeacherCinnamoroll \
  python3.11 -m scripts.manager workload-add
```

Select the validated ZIP as the normal prebuilt Artifact input. Use the existing
private Release download credentials on the management side. Source/registry
credentials are not application environment variables and do not go to the Host.

Choose the Host, set measured `memoryMiB` and `taskRequirement`, and adapt
`instance.example.yaml` to the actual port/domain. Fleet stores only the published
Artifact URL/fingerprint and instance configuration. The Host uses its ordinary
verify/materialize/activate/health/heartbeat lifecycle. Its Core must include the
generic binary credential-scan boundary fix before it consumes the bundled Node.

## State and acceptance

The application listens on loopback and stores SQLite under
`MOYU_WORKLOAD_ROOT/data/store.sqlite`. Artifact contents remain immutable.
The startup adapter also accepts an explicit `TC_STORAGE_PATH`, so the application
can run independently of this control plane. Backups use SQLite's online backup
API and must be copied off the application disk through the normal operations
process.

Before production: smoke-test the exact packaged Node/payload, validate config
failure handling and corrupted-data behavior, measure resources under the
standard task limit, and verify HTTPS/SSE, persistence and SIGTERM handling.
Historical data migration and production domain cutover are separate operations.
