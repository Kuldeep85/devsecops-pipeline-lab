#!/usr/bin/env bash
# 2) SAST with Semgrep: your custom rule + community rule packs
source "$(dirname "$0")/lib.sh"
mkdir -p reports
# isolated virtualenv avoids "externally-managed-environment" errors on newer Ubuntu images
python3 -m venv .venv-semgrep
# shellcheck disable=SC1091
source .venv-semgrep/bin/activate
pip install --quiet semgrep
semgrep scan --config semgrep/custom-rules.yml --config p/javascript --config p/owasp-top-ten \
  --error --metrics=off --json-output=reports/semgrep.json app/
finish $? "SAST (semgrep)"
