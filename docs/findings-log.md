# Findings log

| # | Scan | Tool | Finding | Severity | Why it matters | Fix (commit link) | Re-scan result |
|---|------|------|---------|----------|----------------|-------------------|----------------|
| 1 | Secrets | gitleaks | Hard-coded API key in `app/server.js` line 10 (rule `generic-api-key`), also present in git history | High (if real) | Anyone who can read the repo could use the key, and deleting the line does not remove it from history | Fix on Day 30 | Re-scan on Day 30 |
| 2 | SAST | Semgrep | | | | | |
| 3 | SCA | npm audit | | | | | |
| 4 | Container | Trivy | | | | | |
| 5 | K8s manifest | Trivy config | | | | | |
| 6 | DAST | ZAP | | | | | |

If this were a real key: rotate it first, meaning revoke it at the provider and issue a new one, because it's already public in the repo and its history. Then check the provider's logs for misuse, move the key to an environment variable or secret store, optionally rewrite git history, and prevent a repeat with a gitleaks gate in the pipeline plus .env in .gitignore.

## Problems I hit and how I solved them
(pipeline agent, permissions, tool versions, false positives... write these down — interviewers love them)
