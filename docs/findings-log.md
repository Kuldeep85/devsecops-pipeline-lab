# Findings log

| # | Scan | Tool | Finding | Severity | Why it matters | Fix (commit link) | Re-scan result |
|---|------|------|---------|----------|----------------|-------------------|----------------|
| 1 | Secrets | gitleaks | Hard-coded API key in `app/server.js` line 10 (rule `generic-api-key`), also present in git history | High (if real) | Anyone who can read the repo could use the key, and deleting the line does not remove it from history | Fix on Day 30 | Re-scan on Day 30 |
| 2 | SAST | Semgrep | SQL injection: `db.query` built by string concatenation (custom rule `demo-sqli-string-concat`, `app/server.js` line 24) | High | Attacker-controlled `name` changes the query and can read other rows; fix with a parameterised query | Fix on Day 30 | Re-scan on Day 30 |
| 2b | SAST | Semgrep | Reflected XSS: user input written into HTML (`raw-html-format` and `direct-response-write`, `app/server.js` line 19; two rules, one issue) | High | A crafted link runs script in the victim's browser; escape or sanitise output | Fix on Day 30 | Re-scan on Day 30 |
| 2c | SAST | Semgrep | Container would run as root: no `USER` in `app/Dockerfile` line 8 (`missing-user`) | Medium | A compromised process has root inside the container; use a non-root user (see `Dockerfile.hardened`) | Fix on Day 30 | Re-scan on Day 30 |
| 3 | SCA | npm audit | lodash 4.17.15 (affected: <=4.17.23): command injection, prototype pollution, ReDoS; app uses `_.merge` in `/settings` | High | Attacker JSON merged into an object can alter app behaviour (prototype pollution); upgrade lodash | Fix on Day 30 | Re-scan on Day 30 |
| 3b | SCA | npm audit | express 4.17.1 and its dependencies (body-parser, qs, path-to-regexp, cookie, send): DoS, ReDoS, XSS in `send` | High | Crafted requests can exhaust the service; upgrade express to a patched 4.x | Fix on Day 30 | Re-scan on Day 30 |
| 4 | Container | Trivy | | | | | |
| 5 | K8s manifest | Trivy config | | | | | |
| 6 | DAST | ZAP | | | | | |

If this were a real key: rotate it first, meaning revoke it at the provider and issue a new one, because it's already public in the repo and its history. Then check the provider's logs for misuse, move the key to an environment variable or secret store, optionally rewrite git history, and prevent a repeat with a gitleaks gate in the pipeline plus .env in .gitignore.

SQL injection: a true positive in the code pattern. In this demo the db object is a stub and doesn't actually run SQL, so it isn't exploitable here. With a real database it would be.
XSS: a true positive.
Low value: direct-response-write is the same issue as raw-html-format, flagged a second time, so it adds noise and not a new finding. That's the one to name as low value.
Dockerfile missing-user: a true positive, but it's a container hardening issue, which Day 28 covers.

## Problems I hit and how I solved them
(pipeline agent, permissions, tool versions, false positives... write these down — interviewers love them)
