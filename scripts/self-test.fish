#!/usr/bin/env fish
function header; echo -e "\n==> $argv"; end
set -l FAIL 0

header "Quick smoke"
for c in git gh podman fish yq
  if type -q $c
    echo "[OK] $c — "(command $c --version | head -n1)
  else
    echo "[MISS] $c"
    set FAIL 1
  end
end

header "DevOps status rollup"
if test -f ~/devops-status.fish
  fish ~/devops-status.fish | sed -n '1,200p'
else
  echo "[WARN] ~/devops-status.fish not found; skipping."
end

header "DB toggle sanity"
functions | grep -q '^db-services-on$'; and echo "[OK] db-services-on" ; or echo "[WARN] db-services-on (host-local helper; optional)"
functions | grep -q '^db-labs-on$'; and echo "[OK] db-labs-on" ; or echo "[WARN] db-labs-on (host-local helper; optional)"

header "podman ps snapshot"
podman ps --format '{{.Names}}\t{{.Status}}\t{{.Ports}}' | sort | sed 's/^/[PODMAN] /'

if test $FAIL -eq 0
  echo -e "\n\033[1;32mPASS\033[0m — baseline looks good."
  exit 0
else
  echo -e "\n\033[1;31mFAIL\033[0m — fix items marked MISS."
  exit 1
end
