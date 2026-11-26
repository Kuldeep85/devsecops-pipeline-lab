#!/usr/bin/env bash
# 3) SCA: known-vulnerable dependencies
source "$(dirname "$0")/lib.sh"
mkdir -p reports
( cd app && npm ci --silent && npm audit --audit-level=high ) 2>&1 | tee reports/npm-audit.txt
finish "${PIPESTATUS[0]}" "SCA (npm audit)"
