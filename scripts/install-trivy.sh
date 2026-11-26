#!/usr/bin/env bash
set -euo pipefail
VER="${TRIVY_VERSION:-0.74.0}"
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin "v${VER}"
trivy --version
