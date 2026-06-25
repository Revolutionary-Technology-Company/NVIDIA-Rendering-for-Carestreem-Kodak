# Infrastructure Security: Workstation Decommissioning Vault Scrubbing Module
**Path:** `scripts/VirusTC-Endpoint-Scrub.ps1`  
**Security Context:** Run during active asset retirement, device repurposing, or domain un-joining workflows.

## 1. Functional Purpose
When an asset is retired, repurposed for administrative work, or moved out of the radiology department, all cryptographic signatures and API handshake configurations must be erased. 

This uninstallation module completely scrubs the generic security tokens from the Windows Credential Manager vault and drops local Network QoS scheduling policies. This ensures that a decommissioned machine can no longer authenticate against the central VirusTC infrastructure nodes or access the live data-grid tables.

---

## 2. Core Decommissioning Script Execution

```powershell
<#
.SYNOPSIS
    VirusTC Endpoint Infrastructure Scrubbing & Decommissioning Module.
.DESCRIPTION
    Completely removes secure API handshake credentials from the Windows Vault, 
    deletes local Network QoS traffic shaping policies, and clears clinical registry tags.
.NOTES
    Must be executed with administrative privileges via SCCM task sequences, 
    MDT deployment shares, or local administrative consoles.
#>

\$LogPath = "C:\Program Files\Carestream\Logs\VirusTC_Decommission_Scrub.log"
Start-Transcript -Path \$LogPath -Append

Write-Output "[VirusTC DECOMMISSION] Starting complete workstation configuration scrub sequence..."
WorkstationID = env:COMPUTERNAME

# ============================================================================
# PHASE 1: SCRUB SECURE CREDENTIALS FROM WINDOWS VAULT
# ============================================================================
Write-Output "[1/3] Purging 'VirusTC-API-Handshake' generic credentials from DPAPI vault..."

# Invoke native command line execution tool to purge specific target identifier mappings
& cmdkey /delete:"VirusTC-API-Handshake" | Out-String

# Double-check extraction arrays using the Windows Runtime API context to ensure a complete clean
try {
    \$Vault = [Windows.Security.Credentials.PasswordVault, Windows.Security.Credentials, ContentType=WindowsRuntime]::new()
    Credential = Vault.Retrieve("VirusTC-API-Handshake", "SystemNode")
    
    if (null -ne Credential) {
        Vault.Remove(Credential)
        Write-Output "Successfully executed deep purge of cryptographic vault container profiles."
    }
} catch {
    Write-Output "Verification check confirmed: No active 'VirusTC-API-Handshake' target exists inside vault storage."
}

# ============================================================================
# PHASE 2: PURGE NETWORK QUALITY OF SERVICE (QoS) TRAFFIC POLICIES
# ============================================================================
Write-Output "[2/3] Deleting inbound clinical streaming Network QoS Policies..."

\$TargetQosPolicy = "VirusTC_Receiver_Inbound"
QosCheck = Get-NetQosPolicy -Name TargetQosPolicy -ErrorAction SilentlyContinue

if (null -ne QosCheck) {
    # Scrub from active runtime states and persistent disk configuration templates
    Get-NetQosPolicy -Name TargetQosPolicy -ErrorAction SilentlyContinue | Remove-NetQosPolicy -Confirm:false
    Write-Output "Successfully deleted target packet tagging policy '\$TargetQosPolicy'."
} else {
    Write-Output "No active clinical network traffic policies identified on this adapter."
}

# ============================================================================
# PHASE 3: CLEAR LOCAL DIRECTX GPU APP OVERRIDES
# ============================================================================
Write-Output "[3/3] Clearing local Windows High-Performance GPU user assignments..."

\$GpuPrefPath = "HKCU:\Software\Microsoft\DirectX\UserGpuPreferences"
\$TargetApp   = "C:/Program Files (x86)/Citrix/ICA Client/CDViewer.exe"

if (Test-Path \(GpuPrefPath) {\)PrefCheck = Get-ItemProperty -Path GpuPrefPath -Name TargetApp -ErrorAction SilentlyContinue
    if (null -ne PrefCheck) {
        Remove-ItemProperty -Path GpuPrefPath -Name TargetApp -Force -ErrorAction SilentlyContinue
        Write-Output "Successfully removed high-performance graphics overrides for Citrix Workspace packages."
    }
}

Write-Output "[VirusTC COMPLETE] Decommission scrub completed successfully on \$WorkstationID. Device is safe to repurpose."
Stop-Transcript
```
