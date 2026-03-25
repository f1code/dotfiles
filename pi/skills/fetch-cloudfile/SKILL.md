---
name: fetch-cloudfile
description: Download a file from cloud storage (via the cloud_file library) to the local filesystem. Use when the user wants to fetch/download a file from the cloud backend, e.g. parquet or dataset files.
---

# Fetch Cloud File

Download a file from cloud storage (via the cloud_file library) to the local filesystem.

## Usage

The user provides:
1. **Cloud file path** — the path as stored in cloud_file (e.g. `p_1/datasets/SGNTUC-028/core.system.audit_trail/01KM5CY6A9CAP61N5EZE7BNT3H/delta.parquet`)
2. **Local destination** (optional) — defaults to current directory, using the filename from the cloud path

## Steps

### 1. Download inside the backend container

Use `manage.py shell -c` (NOT `python -c`) so Django is fully configured:

```bash
docker compose exec backend python manage.py shell -c "
from cloud_file import CloudFileSync, GatewayBackend, make_async_request
from django.core.cache import cache
from prancer_common.gateway import GatewayRequest
from pathlib import PurePath

request = make_async_request(GatewayRequest())
cf = CloudFileSync(backend=GatewayBackend(request, cache))
with open('/tmp/fetched_file', 'wb') as f:
    cf.download_file(PurePath('<CLOUD_PATH>'), f)
print('Done')
"
```

Replace `<CLOUD_PATH>` with the user's cloud file path.

### 2. Copy from container to host

```bash
docker compose cp backend:/tmp/fetched_file <HOST_DESTINATION>
```

Default `<HOST_DESTINATION>` is `./<filename>` (the last component of the cloud path).

### 3. (Optional) Inspect parquet files

If the file is `.parquet`, print shape/columns inside the container before copying:

```bash
docker compose exec backend python manage.py shell -c "
import polars as pl
df = pl.read_parquet('/tmp/fetched_file')
print(f'Shape: {df.shape}')
print(df.columns)
print(df.head(5))
"
```

## Notes

- The backend container must be running (`docker compose up -d backend`)
- The `manage.py shell` auto-imports 700+ objects and prints a line about it — this is normal, ignore it
- Cloud paths typically look like `p_<N>/datasets/<study>/<dataset>/<version>/data.parquet` or `delta.parquet`
