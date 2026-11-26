#!/usr/bin/env bash
set -euo pipefail
VER="${GITLEAKS_VERSION:-8.30.1}"
curl -sSfL "https://github.com/gitleaks/gitleaks/releases/download/v${VER}/gitleaks_${VER}_linux_x64.tar.gz" | tar -xz gitleaks
sudo mv gitleaks /usr/local/bin/gitleaks 2>/dev/null || { mkdir -p "$HOME/.local/bin"; mv gitleaks "$HOME/.local/bin/"; }
gitleaks version
