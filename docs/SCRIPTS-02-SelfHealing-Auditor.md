# Infrastructure Automation: Automated Endpoint Drift Monitor & Self-Healer
**Path:** `scripts/VirusTC-SelfHealing-Auditor.ps1`  
**Deployment Context:** Assigned as an Active Directory Computer Startup Script via GPO.

## 1. Functional Purpose
This script runs in the system context during machine startup to audit local client nodes. If it detects changes in registry values, missing network QoS policies, or altered GPU performance power profiles, it applies repairs immediately, logs an event warning to the Windows Event Viewer, and dispatches an IT alert.

## 2. Core Code Execution
```powershell
<#
.SYNOPSIS
    VirusTC Deployment Verification & Self-Healing Tool.
    Deployed via GPO to monitor and automatically repair ASUS TUF RTX 50 Series configurations.
.DESCRIPTION
    Audits registry states, network QoS tracking, and NVIDIA GPU performance profiles.
    Instantly auto-remediates and fixes any drift anomalies on the spot.
#>

\$AlertEmailFrom = "endpoint-remediation@hospital.local"
\$AlertEmailTo   = "it-imaging-alerts@hospital.local"
\$SmtpServer     = "smtp.hospital.local"
\$WorkstationID  = \(env:COMPUTERNAME\)DriftDetected  = \(false\)RemediationLog = @()

Write-Output "Executing VirusTC Active Self-Healing Audit for machine: \$WorkstationID"

# ============================================================================
# REMEDIATION LOOP 1: CITRIX HDX HARDWARE DECODING REGISTRY KEYS
# ============================================================================
\$GfxPath = "HKLM:\SOFTWARE\WOW6432Node\Citrix\ICA Client\Engine\Configuration\Advanced\Modules\GfxRender"
\$RequiredKeys = @{
    "UseHardwareDecoding" = 1
    "PreferAVC444"        = 1
}

if (-not (Test-Path \(GfxPath)) {\)DriftDetected = \(true\)RemediationLog += "[REPAIR] Citrix GfxRender path was missing. Re-creating core directory tree."
    New-Item -Path \$GfxPath -Force | Out-Null
}

foreach (Key in RequiredKeys.Keys) {
    CurrentValue = (Get-ItemProperty -Path GfxPath -Name Key -ErrorAction SilentlyContinue).Key
    if (CurrentValue -ne RequiredKeys[\(Key]) {\)DriftDetected = \(true\)RemediationLog += "[REPAIR] Citrix Registry Key '\$Key' drifted to 'CurrentValue'. Enforcing value '(\(RequiredKeys[\)Key])'."
        Set-ItemProperty -Path GfxPath -Name Key -Value \(RequiredKeys[\)Key] -Type DWord -Force | Out-Null
    }
}

# ============================================================================
# REMEDIATION LOOP 2: WINDOWS USER GRAPHICS ACCELERATION OVERRIDES
# ============================================================================
\$GpuPrefPath = "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences"
\$TargetApp   = "C:/Program Files (x86)/Citrix/ICA Client/CDViewer.exe"

if (-not (Test-Path GpuPrefPath)) New-Item -Path GpuPrefPath -Force | Out-Null }

CurrentPref = (Get-ItemProperty -Path GpuPrefPath -Name TargetApp -ErrorAction SilentlyContinue).TargetApp
if (\$CurrentPref -notmatch "GpuPreference=2;") {
    \$DriftDetected = \(true\)RemediationLog += "[REPAIR] Windows Graphics Preference for CDViewer.exe was lost. Forcing High-Performance Profile."
    Set-ItemProperty -Path GpuPrefPath -Name TargetApp -Value "GpuPreference=2;" -Type String -Force | Out-Null
}

# ============================================================================
# REMEDIATION LOOP 3: INBOUND NETWORK QUALITY OF SERVICE (QoS) POLICY
# ============================================================================
\$QosPolicy = Get-NetQosPolicy -Name "VirusTC_Receiver_Inbound" -ErrorAction SilentlyContinue

if (null -eq QosPolicy -or \(QosPolicy.DSCPAction -ne 46) {\)DriftDetected = \(true\)RemediationLog += "[REPAIR] Network QoS 'VirusTC_Receiver_Inbound' was missing or corrupted. Re-deploying Policy Core."
    Get-NetQosPolicy -Name "VirusTC_Receiver_Inbound" -ErrorAction SilentlyContinue | Remove-NetQosPolicy -Confirm:\$false
    New-NetQosPolicy -Name "VirusTC_Receiver_Inbound" -AppPathNameMatchCondition "CDViewer.exe" -DSCPAction 46 -PolicyStore ActiveStore | Out-Null
    New-NetQosPolicy -Name "VirusTC_Receiver_Inbound" -AppPathNameMatchCondition "CDViewer.exe" -DSCPAction 46 -PolicyStore PersistentStore | Out-Null
}

# ============================================================================
# REMEDIATION LOOP 4: LOCAL ASUS TUF NVIDIA HARDWARE P-STATE PROFILE
# ============================================================================
\$NvidiaSmi = "C:\Program Files\NVIDIA Corporation\NVIDIA-SMI\nvidia-smi.exe"

if (Test-Path \$NvidiaSmi) {
    \(PersistenceMode = &\)NvidiaSmi --query-gpu=persistence_mode --format=csv,noheader,nounits
    if (\$PersistenceMode -notmatch "Enabled") {
        \$DriftDetected = \(true\)RemediationLog += "[REPAIR] NVIDIA Persistence Mode was Disabled. Re-activating driver persistence."
        Start-Process -FilePath \$NvidiaSmi -ArgumentList "-pm 1" -NoNewWindow -Wait
        Start-Process -FilePath \$NvidiaSmi -ArgumentList "-g 0 -acp P0" -NoNewWindow -Wait
    }
} else {
    \$DriftDetected = \(true\)RemediationLog += "[CRITICAL CRASH] NVIDIA-SMI utility missing. Local ASUS TUF graphics driver requires immediate IT reinstall."
}

# ============================================================================
# AUDIT SUBMISSION & POST-REPAIR REPORTING
# ============================================================================
if (\$DriftDetected) {
    CompiledLog = RemediationLog -join "`n"
    $EventID = 40661 
    if (-not [System.Diagnostics.EventLog]::SourceExists("VirusTC-SelfHealer")) {
        New-EventLog -LogName Application -Source "VirusTC-SelfHealer"
    }
    Write-EventLog -LogName Application -Source "VirusTC-SelfHealer" -EntryType Information -EventId $EventID `
                   -Message "VirusTC Auto-Remediation Triggered: Workstation \$WorkstationID configuration drift repaired.`nRemediation Log:`n\$CompiledLog"

    \$EmailBody = "ALERT: Configuration Drift Detected & Fixed on \$WorkstationID.`n`n\$CompiledLog"
    try { Send-MailMessage -From \$AlertEmailFrom -To AlertEmailTo -Subject "RESOLVED: WorkstationID Auto-Remediation" -Body EmailBody -SmtpServer SmtpServer -ErrorAction Stop } catch {}
}
```
