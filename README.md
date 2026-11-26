# DevSecOps Pipeline Lab — security gates in Azure DevOps and GitHub Actions

> **Status:** replace this box with one honest sentence when done, e.g. "Personal learning project, completed Oct 2026. Deliberately vulnerable demo app; not production code."

**What this shows:** I can take a small web app, wire five automated security checks into a CI/CD pipeline, find real issues, fix them, and then make the pipeline block bad changes.

| Check | Tool | Catches |
|---|---|---|
| Secrets | gitleaks | keys/passwords committed to Git |
| SAST | Semgrep | insecure code patterns (SQL injection, XSS) |
| SCA | npm audit | known-vulnerable dependencies |
| Container + IaC | Trivy | vulnerable base image, insecure Kubernetes manifest, SBOM |
| DAST | OWASP ZAP baseline | issues in the running app (missing headers etc.) |

---

## Before you start (read this)

1. **Use personal accounts and your own machine only.** Never use your employer's or a client's Azure DevOps, OpenShift, databases or code for this project.
2. The demo app is **deliberately vulnerable**. Never deploy it anywhere public.
3. **Azure DevOps free tier:** new organisations often have *no* Microsoft-hosted agent grant. Either
   - request the free grant at `https://aka.ms/azpipelines-parallelism-request` (allow several business days — do this on Day 1), **or**
   - register a free **self-hosted agent** on your own Linux/WSL machine (Microsoft Learn: *Azure Pipelines agents → self-hosted Linux agents*). Then set `pool: name: <your-pool>` in `azure-pipelines.yml`.
4. GitHub may block a push that contains something that looks like a secret. The key in `app/server.js` is fake — use the link GitHub gives you to allow it, or change its format.

## What was tested when this starter was prepared

Tested locally: secrets scan (detects the planted key), dependency scan (8 vulnerabilities, 5 high), the custom Semgrep rule (detects the SQL injection), enforce vs report-only behaviour, script and YAML syntax.
**Not tested:** the Docker / Trivy / ZAP steps and the full pipelines inside your Azure DevOps and GitHub. Expect to fix small things (a path, a permission) — and write those fixes into your findings log; that *is* the learning.

## Repository layout

```
app/                 demo Node/Express app + Dockerfile (weak) + Dockerfile.hardened
semgrep/             your custom Semgrep rule
k8s/insecure-example "before" Kubernetes manifest        k8s/hardened  "after" manifest
scripts/             one script per scan (used by BOTH pipelines and by `make`)
azure-pipelines.yml  Azure DevOps YAML pipeline          .github/workflows/devsecops.yml  GitHub Actions
docs/findings-log.md your before/after evidence table    notes/practice-log.md  daily practice log
```

---

## Step-by-step (about 15–20 hours)

### Phase 0 — Setup (1–2 h)
1. Create a **public GitHub repo** `devsecops-pipeline-lab`; push this folder to it.
2. Create a **personal Azure DevOps organisation** + project. Start the free-grant request (or the self-hosted agent) now.
3. Install locally: Git, Node 22, Docker (Docker Desktop or Docker inside WSL2/Linux), Python 3.

### Phase 1 — Baseline scans on your machine (2–3 h)
1. Run `make secrets`, `make sast`, `make sca`.
2. Install Trivy (`bash scripts/install-trivy.sh`), then `make container`. Run `trivy config k8s/insecure-example` for the "before" manifest evidence.
3. Run `make dast`.
4. For **every** scan: screenshot the output and add one row to `docs/findings-log.md` (tool, finding, severity, why it matters).

### Phase 2 — Pipelines in report-only mode (3–4 h)
1. Azure DevOps: **Pipelines → New pipeline →** GitHub (install the Azure Pipelines GitHub app) **→ Existing Azure Pipelines YAML file →** `/azure-pipelines.yml` → Run. Leave `enforceGates` = false.
2. GitHub: open the **Actions** tab and confirm `devsecops` ran on your push.
3. Download the `security-reports` artifact from both. Screenshot the run summary (findings, but green build).

### Phase 3 — Fix the findings (4–5 h) — one commit per fix, with a clear message
| Finding | Fix |
|---|---|
| Hard-coded key in `server.js` | read it from `process.env.API_KEY`; add `.env` to `.gitignore`. The old commit still contains the fake key, so `gitleaks` keeps flagging it: copy the `Fingerprint` line from its output into a `.gitleaksignore` file and explain in the log that a **real** key would have been rotated first (then history cleaned) |
| SQL injection (`/user`) | parameterised query: `db.query("SELECT * FROM users WHERE name = ?", [req.query.name])` (update the stub to accept params) |
| Reflected XSS (`/hello`) | escape output (e.g. the `escape-html` package) or return JSON instead of building HTML |
| Vulnerable dependencies | `cd app && npm install express@latest lodash@latest`, commit the new lockfile, re-run `npm audit`; record anything left over |
| Weak container | copy `app/Dockerfile.hardened` over `app/Dockerfile`; re-run `make container` |
| Insecure Kubernetes manifest | compare `k8s/insecure-example` with `k8s/hardened`; scan both; explain each change |
| ZAP header warnings | `npm install helmet` and `app.use(require('helmet')())`; re-run `make dast` |

### Phase 4 — Make the pipeline enforce (2 h)
1. Set `enforceGates` default to `true` (Azure) and `ENFORCE: 'true'` (GitHub).
2. **Prove it works:** on a branch, re-introduce a secret or an old dependency, open a pull request, and screenshot the pipeline **failing**. Then revert and screenshot it passing.
3. GitHub: Settings → Branches → require the `devsecops` check before merging. (Azure Repos users: add a Build Validation branch policy.)

### Phase 5 — Optional: run it on OpenShift (2–3 h)
Free **Red Hat Developer Sandbox** (developers.redhat.com/developer-sandbox): push your hardened image to a registry, edit the image line in `k8s/hardened/deployment.yaml`, then `oc apply -f k8s/hardened/deployment.yaml` and `oc get pods`. Note in the README that it is a sandbox, not production.

### Phase 6 — Write it up (1–2 h)
Replace the top of this README with: the problem, the diagram of your pipeline stages, the before/after table from your findings log, screenshots (baseline run, enforced failure, final green run), and a short **"What I would do next"** (e.g. Terraform scanning, signed images, secrets in Azure Key Vault, policy as code).

---

## Interview crib — questions this project lets you answer with evidence
1. What is the difference between SAST, DAST and SCA, and where does each run in a pipeline?
2. What did each tool find, and which findings were false positives or low value?
3. Why start in report-only mode and then enforce?
4. How would you handle a secret that was already committed? (rotate first, then clean history)
5. Why run as a non-root user, drop capabilities and set resource limits?
6. What is an SBOM and why would a customer ask for one?
7. What would break if this ran on OpenShift instead of plain Kubernetes? (restricted security context, arbitrary UIDs)
8. What is *not* covered by this project? (be honest: no IaC, no cloud, no runtime monitoring)
