---
name: load-datasource
description: Load a reporting framework datasource by ID, analyze its schema and data, and optionally save as parquet. Use when the user wants to inspect, explore, or export a datasource from the reporting framework.
---

# Load Datasource

Load a reporting framework datasource, print schema/stats, and optionally save to parquet.

## Usage

The user provides:
1. **Datasource ID** — e.g. `core.supply.temp_monitoring_detail`
2. **User email** (optional) — defaults to `admin@4gclinical.com`
3. **Save as parquet** (optional) — if yes, copy the file to the host

## Steps

### 1. Load and analyze inside the backend container

```bash
docker compose exec backend python manage.py shell -c "
from prancer_authentication.models import Account
from reporting_framework.api import get_datasource
from reporting_framework.hooks import ReportQueryParamsProvider

DATASOURCE_ID = '<DATASOURCE_ID>'
u = Account.objects.get(email='<EMAIL>')
qp = ReportQueryParamsProvider.instance.default_query_params()
qp.user = u
qp.unblinded = True
ds = get_datasource(DATASOURCE_ID, qp)
df = ds.data.to_pl()

print(f'Shape: {df.shape}')
print(f'Columns ({len(df.columns)}):')
for c in df.columns:
    print(f'  {c}: {df[c].dtype}')
print()
print('Null counts:')
for c in df.columns:
    n = df[c].null_count()
    if n > 0:
        print(f'  {c}: {n}/{df.shape[0]}')
print()
print('Sample (first 5 rows):')
print(df.head(5))
print()
print('Describe:')
print(df.describe())
"
```

Replace `<DATASOURCE_ID>` and `<EMAIL>` with actual values.

### 2. (Optional) Save as parquet

If the user wants to save the data, add to the script:

```python
df.write_parquet('/tmp/datasource_out.parquet')
print('Saved to /tmp/datasource_out.parquet')
```

Then copy from container:

```bash
docker compose cp backend:/tmp/datasource_out.parquet ./<DATASOURCE_ID>.parquet
```

### 3. Analyze

After getting the output, provide a concise summary:
- Row/column count
- Notable column types
- Null patterns
- Any obvious data quality observations

## Notes

- The backend container must be running (`docker compose up -d backend`)
- `manage.py shell` prints an auto-import line — ignore it
- For large datasources, you can add `qp.select = {"col1", "col2"}` to limit columns
- Set `qp.unblinded = False` if blinded view is needed
- The `ds.data` object is a DataSourceData; `.to_pl()` converts to a Polars DataFrame
