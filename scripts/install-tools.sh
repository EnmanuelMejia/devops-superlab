#!/usr/bin/env bash
# Install the exact tool versions CI uses into a directory (default ./.bin),
# verifying each download against a pinned SHA-256. Linux x86_64 only; on
# other platforms install kubectl, kind, kubeconform and conftest with your
# package manager.
#   ./scripts/install-tools.sh [dir]
set -euo pipefail

DEST="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.bin}"

KUBECTL_VERSION=v1.37.1
KUBECTL_SHA256=65691ff77eb6fa44c908b77a1082c9f092c3b9733b5cefabec0d1104890e21a8
KIND_VERSION=v0.33.0
KIND_SHA256=aee6151561422756b764a4ae28e7f44cda5af5a9eead3cc9985112b1de8d8e0d
KUBECONFORM_VERSION=v0.8.0
KUBECONFORM_SHA256=9bc2bffbf71f261128533edaf912153948b7ff238f9a531ae6d34466ec287883
CONFTEST_VERSION=0.70.1
CONFTEST_SHA256=613d124b8f6c1f3cee890491f7ab19114cca5a2102ca47cb2e6c35b4c23f9c8a

if [ "$(uname -s)-$(uname -m)" != "Linux-x86_64" ]; then
  echo "install-tools.sh only pins Linux x86_64 binaries; install the tools with your package manager." >&2
  exit 1
fi

mkdir -p "$DEST"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

fetch() { # url sha256 output
  curl -fsSL --retry 3 -o "$3" "$1"
  echo "$2  $3" | sha256sum -c --quiet -
}

fetch "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" "$KUBECTL_SHA256" "$work/kubectl"
install -m 0755 "$work/kubectl" "$DEST/kubectl"

fetch "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64" "$KIND_SHA256" "$work/kind"
install -m 0755 "$work/kind" "$DEST/kind"

fetch "https://github.com/yannh/kubeconform/releases/download/${KUBECONFORM_VERSION}/kubeconform-linux-amd64.tar.gz" \
  "$KUBECONFORM_SHA256" "$work/kubeconform.tar.gz"
tar -xzf "$work/kubeconform.tar.gz" -C "$work" kubeconform
install -m 0755 "$work/kubeconform" "$DEST/kubeconform"

fetch "https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz" \
  "$CONFTEST_SHA256" "$work/conftest.tar.gz"
tar -xzf "$work/conftest.tar.gz" -C "$work" conftest
install -m 0755 "$work/conftest" "$DEST/conftest"

echo "[ok] kubectl ${KUBECTL_VERSION}, kind ${KIND_VERSION}, kubeconform ${KUBECONFORM_VERSION}, conftest ${CONFTEST_VERSION} in ${DEST}"
