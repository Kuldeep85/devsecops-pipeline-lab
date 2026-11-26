#!/usr/bin/env bash
# 1) Secrets scan of the working tree and git history
source "$(dirname "$0")/lib.sh"
mkdir -p reports
gitleaks detect --source . --redact --no-banner --report-format json --report-path reports/gitleaks.json
finish $? "Secrets scan (gitleaks)"
