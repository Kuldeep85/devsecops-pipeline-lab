#!/usr/bin/env bash
# Shared helper. Scans always run; the build fails only when ENFORCE=true.
enforce() { [[ "${ENFORCE:-false}" =~ ^([Tt]rue|1)$ ]]; }

finish() { # $1 = scanner exit code, $2 = scan name
  local rc=$1 name=$2
  if [[ $rc -ne 0 ]]; then
    if enforce; then
      echo "ERROR: $name found issues and ENFORCE=true -> failing the build"
      exit "$rc"
    else
      echo "WARNING: $name found issues (report-only mode) -> continuing"
    fi
  else
    echo "OK: $name is clean"
  fi
  return 0
}
