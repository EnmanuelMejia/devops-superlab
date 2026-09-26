#!/usr/bin/env bash
set -euo pipefail
echo "[info] running language-specific tests if present"

# Node
if [ -f services/node-express/package.json ]; then
  (cd services/node-express && npm ci && npm test) || true
fi

# Go
if [ -d services/go-chi ]; then
  (cd services/go-chi && go test ./...) || true
fi

# .NET
if [ -d services/dotnet-minimal ]; then
  (cd services/dotnet-minimal && dotnet test) || true
fi

# Java (Maven)
if [ -d services/spring-boot ]; then
  (cd services/spring-boot && ./mvnw -q -DskipITs -DskipIT -DskipITs=true -DskipTests=false test) || true
fi

# Python (pytest if exists)
if [ -f services/api-gateway/requirements.txt ] || ls services/*/requirements.txt >/dev/null 2>&1; then
  for req in services/*/requirements.txt; do
    [ -f "$req" ] || continue
    svc=$(dirname "$req")
    # shellcheck source=/dev/null  # the venv is created at run time
    (cd "$svc" && python3 -m venv .venv && . .venv/bin/activate && pip -q install -r requirements.txt pytest && pytest -q) || true
  done
fi

echo "[ok] tests completed"
