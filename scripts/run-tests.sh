#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
python3 -m unittest discover -s samples/health-service -p 'test_*.py' -v
python3 -m unittest discover -s tests -p 'test_*.py' -v
# Optional future services run only when source is present; failures propagate.
if [ -f services/node-express/package.json ]; then
  (cd services/node-express && npm ci && npm test)
fi
if [ -d services/go-chi ]; then
  (cd services/go-chi && go test ./...)
fi
if [ -d services/dotnet-minimal ]; then
  (cd services/dotnet-minimal && dotnet test)
fi
if [ -f services/spring-boot/mvnw ]; then
  (cd services/spring-boot && ./mvnw test)
fi
echo '[ok] tests passed for source present in this checkout'
