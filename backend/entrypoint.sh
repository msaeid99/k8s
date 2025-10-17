#!/usr/bin/env bash
set -e

echo "Waiting for Postgres…"
for i in {1..10}; do
  python - <<'PY'
import os,sys,psycopg2
url=os.environ.get("DATABASE_URL")
try:
    psycopg2.connect(url).close(); sys.exit(0)
except Exception: sys.exit(1)
PY
  && break || { echo "Postgres not ready ($i/10)"; sleep 3; }
done

# مigrations (لو فشلت مش نوقع السيرفر)
flask db upgrade || true

exec gunicorn -b 0.0.0.0:5000 app:app


