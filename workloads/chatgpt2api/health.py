"""Check application availability; an empty account pool is expected initially."""

import json
from urllib.request import urlopen

with urlopen("http://127.0.0.1:8320/health?format=json", timeout=3) as response:
    report = json.load(response)
if report.get("status") not in {"ok", "degraded"} or not report.get("version"):
    raise SystemExit("chatgpt2api health response is invalid")
