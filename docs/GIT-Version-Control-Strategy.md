# Git Version-Control & Branching Strategy
**Framework:** Trunk-Based Feature Branching for Clinical Environments
**Scope:** Management of VirusTC Automation Scripts, GPO Assets, and HTML Dashboard Codebases

To ensure zero downtime across hospital clinical networks, updates to deployment scripts, compliance auditors, and monitoring dashboards must follow a strict, isolated version-control pipeline. This strategy prevents untested code from breaking live diagnostic-grade viewports.

---

## 1. Environment and Branch Topology

[ feature/issue-104 ]  ---> (Feature Branch)
|
v (Pull Request / Peer Review)
[ staging ]      ---> (Staging Branch: Test PVS/MCS Master Images)
|
v (Validation & QA Sign-Off)
[ main ]          ---> 
(Production Branch: Live Fleet GPO Deployments)



## 2. CI/CD Lifecycle & Validation Gates

To advance a code change from a developer's local workstation to live hospital endpoints, it must clear three distinct validation gates:

+------------------+     +--------------------+     +-------------------+
|  1. Local Lint   | --> | 2. Staging Deploy  | --> | 3. Main Approval  |
| PSScriptAnalyzer |     | Lab VDI Validation |     | Change Advisory   |
+------------------+     +--------------------+     +-------------------+

### Gate 1: Local Linting & Syntax Verification
Before a feature branch can be merged into `staging`, the engineer must run a syntax assessment using `PSScriptAnalyzer`. This step catches syntax bugs before they hit the network.
```powershell
# Mandatory pre-commit verification command
Invoke-ScriptAnalyzer -Path .\scripts\VirusTC-SelfHealing-Auditor.ps1
```

### Gate 2: Staging Deployment & Clinical Simulation
Once the code passes linting, a Pull Request is opened to merge it into the `staging` branch.
1. The script is deployed to test environments via a staging GPO template.
2. A test VDI session is initiated on a lab machine using an **ASUS TUF RTX 50 Series** card.
3. Engineers manually verify that the registry changes, QoS packet tags, and GPU power levels are configured correctly by running the `VirusTC-Compliance-Auditor.ps1` script in diagnostic mode.

### Gate 3: Production Change Control Approval
Once staging tests pass, a PR is opened from `staging` to `main`.
*   The PR description must include the staging validation logs.
*   A formal review is scheduled with the hospital's Change Advisory Board (CAB) to confirm that the changes comply with clinical safety standards.
*   Upon approval, the PR is merged, and the new version is assigned a production tag (e.g., `v2.26.1`).

---

## 3. Post-Deployment Verification & Emergency Rollbacks

### Production Verification Window
Immediately following a merge to `main`, the deployment engineer must monitor the **VirusTC Compliance Dashboard** for a 15-minute window.
*   **Target Metric:** The "Fleet Compliance Rate" must remain at or above **95%**.
*   **Anomalies:** Any drop in compliance scores or an increase in `Event 40660` (Manual Intervention Required) warnings will trigger an immediate incident review.

### Emergency Rollback Protocol
If an unforeseen bug compromises image-rendering speeds or breaks Citrix communication channels in production, the infrastructure team will execute a fast revert to the previous stable release tag:

```bash
# 1. Immediately checkout the production main branch
git checkout main

# 2. Revert the last merge commit that introduced the instability
git revert -m 1 HEAD

# 3. Force push the correction to trigger immediate GPO synchronization
git push origin main
```
*The rollback script will overwrite the active assets in the Active Directory Sysvol folder within 5 minutes, returning the entire fleet to the previous stable baseline configuration.*

---
**Prepared By:** VirusTC Version Control & Quality Assurance Engineering Team  
**Review Status:** Approved for Implementation Across All Clinical Code Repositories 
