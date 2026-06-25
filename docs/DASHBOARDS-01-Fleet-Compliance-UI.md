# Interface Blueprint: Fleet Compliance Real-Time HTML Monitor Layout
**Path:** `dashboards/VirusTC-Compliance-Dashboard.html`  
**Deployment Context:** Hosted internally via IIS web server, accessible by internal network engineering teams.

## 1. Functional Purpose
This dashboard provides a clear, high-level overview of the configuration compliance status across the managed workstation fleet, using green, yellow, and red indicator badges to flag endpoint configuration drift at a glance.

## 2. Core HTML Interface Code Source
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>VirusTC Clinical Infrastructure Compliance Dashboard</title>
    <style>
        :root {
            --bg-primary: #0f172a; --bg-secondary: #1e293b; --text-main: #f8fafc;
            --text-muted: #94a3b8; --accent-success: #10b981; --accent-warning: #f59e0b;
            --accent-error: #ef4444; --border-color: #334155;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: sans-serif; }
        body { background-color: var(--bg-primary); color: var(--text-main); padding: 2rem; }
        header { margin-bottom: 2rem; border-bottom: 1px solid var(--border-color); padding-bottom: 1rem; display: flex; justify-content: space-between; }
        .branding { color: var(--accent-success); font-weight: bold; }
        .metrics-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 1.5rem; margin-bottom: 2rem; }
        .card { background-color: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: 8px; padding: 1.5rem; text-align: center; }
        .card-title { font-size: 0.875rem; color: var(--text-muted); text-transform: uppercase; }
        .card-value { font-size: 2.25rem; font-weight: bold; margin-top: 0.5rem; }
        .table-section { background-color: var(--bg-secondary); border: 1px solid var(--border-color); border-radius: 8px; padding: 1.5rem; }
        table { width: 100%; border-collapse: collapse; }
        th { background-color: var(--bg-primary); color: var(--text-muted); font-size: 0.875rem; padding: 0.75rem 1rem; border-bottom: 2px solid var(--border-color); }
        td { padding: 1rem; border-bottom: 1px solid var(--border-color); font-size: 0.875rem; }
        .badge { display: inline-block; padding: 0.25rem 0.5rem; border-radius: 4px; font-size: 0.75rem; font-weight: bold; }
        .badge-compliant { background-color: rgba(16, 185, 129, 0.2); color: var(--accent-success); }
        .badge-healed { background-color: rgba(245, 158, 11, 0.2); color: var(--accent-warning); }
        .badge-drifted { background-color: rgba(239, 68, 68, 0.2); color: var(--accent-error); }
        .log-box { font-family: monospace; background-color: var(--bg-primary); padding: 0.5rem; border-radius: 4px; font-size: 0.75rem; color: var(--text-muted); max-width: 400px; white-space: pre-wrap; }
    </style>
</head>
<body>
    <header>
        <div><h1><span class="branding">[VirusTC]</span> Imaging Workspace Fleet Monitor</h1></div>
    </header>
    <div class="metrics-grid">
        <div class="card"><div class="card-title">Total Monitored Nodes</div><div class="card-value">42</div></div>
        <div class="card"><div class="card-title">Fleet Compliance Rate</div><div class="card-value style='color:#10b981;'">95.2%</div></div>
        <div class="card"><div class="card-title">Auto-Healed (Today)</div><div class="card-value style='color:#f59e0b;'">2</div></div>
    </div>
    <div class="table-section">
        <h2>Endpoint Fleet Status</h2>
        <table>
            <thead><tr><th>Workstation ID</th><th>GPU Hardware</th><th>Status</th><th>Remediation / Drift Details Log</th></tr></thead>
            <tbody>
                <tr><td>DR-OFFICE-01</td><td>ASUS TUF RTX 5090</td><td><span class="badge badge-compliant">Fully Compliant</span></td><td><div class="log-box">All metrics within operational limits. Registry keys locked.</div></td></tr>
                <tr><td>DR-OFFICE-02</td><td>ASUS TUF RTX 5080</td><td><span class="badge badge-healed">Self-Healed</span></td><td><div class="log-box">[REPAIR] Citrix Key 'PreferAVC444' drifted to '0'. Enforced value '1'.</div></td></tr>
            </tbody>
        </table>
    </div>
</body>
</html>
```
