#!/usr/bin/env bash
# 5) DAST: OWASP ZAP baseline (passive) scan against the running container
source "$(dirname "$0")/lib.sh"
IMAGE="${IMAGE:-demo-app:local}"
mkdir -p reports && chmod 777 reports
docker rm -f demo-app >/dev/null 2>&1 || true
docker run -d --name demo-app -p 3000:3000 "$IMAGE"
for i in $(seq 1 15); do curl -sf http://localhost:3000/health >/dev/null && break; sleep 2; done

docker run --rm --network host -v "$(pwd)/reports:/zap/wrk:rw" ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t http://localhost:3000 -r zap-baseline.html -J zap-baseline.json
rc=$?
docker rm -f demo-app >/dev/null 2>&1 || true
[[ $rc -eq 2 ]] && rc=0   # ZAP exit code 2 = warnings only; 1 = failures
finish $rc "DAST (ZAP baseline)"
