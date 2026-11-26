# Findings log

| # | Scan | Tool | Finding | Severity | Why it matters | Fix (commit link) | Re-scan result |
|---|------|------|---------|----------|----------------|-------------------|----------------|
| 1 | Secrets | gitleaks | Hard-coded API key in `app/server.js` line 10 (rule `generic-api-key`), also present in git history | High (if real) | Anyone who can read the repo could use the key, and deleting the line does not remove it from history | Fix on Day 30 | Re-scan on Day 30 |
| 2 | SAST | Semgrep | | | | | |
| 3 | SCA | npm audit | | | | | |
| 4 | Container | Trivy | | | | | |
| 5 | K8s manifest | Trivy config | | | | | |
| 6 | DAST | ZAP | | | | | |

## Problems I hit and how I solved them
(pipeline agent, permissions, tool versions, false positives... write these down — interviewers love them)
