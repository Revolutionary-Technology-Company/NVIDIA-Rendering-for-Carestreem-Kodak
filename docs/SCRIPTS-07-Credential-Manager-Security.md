# Infrastructure Security: Windows Credential Manager Token Extraction
**Path:** Integration block for `scripts/VirusTC-SelfHealing-Auditor.ps1`  
**Security Context:** Eliminates plaintext hardcoded security tokens inside GPO scripts.

## 1. Functional Purpose
Hardcoding enterprise handshake keys in plaintext inside scripts violates hospital compliance frameworks. This security template uses the native Windows Credential Manager API via PowerShell. 

The token is stored securely in the local system's vault under an administrative context, encrypted using DPAPI (Data Protection API). The script extracts it at runtime directly into a secure memory variable.

---

## 2. Step 1: IT Staging — Provision the Token on the Master Image
Before sealing your PVS/MCS image or deploying the GPO, run this one-time PowerShell command with administrative credentials on the target endpoint to store the secret token inside the Windows Vault:

```powershell
# Run once during workstation staging to store the secret token securely
\$SecretToken = "VTC-ASUS-RTX50-SECURE-HANDSHAKE-TOKEN-2026"

cmdkey /generic:"VirusTC-API-Handshake" /user:"SystemNode" /pass:"\$SecretToken"
```

---

## 3. Step 2: Integrated Code Execution (Replaces Plaintext Token Blocks)
Replace the hardcoded token variables in your endpoint scripts with this clean extraction logic block:

```powershell
# ============================================================================
# SECURITY LAYER: SECURE STORAGE TOKEN EXTRACTION
# ============================================================================
Write-Output "Extracting secure API handshake credentials from Windows Vault..."

# Add assembly pathways to interact with the native Windows Credential UI layers
Add-Type -AssemblyName System.DirectoryServices.AccountManagement

# Fetch the specific generic credential object matching your target identifier name
\$TargetTarget = "VirusTC-API-Handshake"
\$CredentialFetch = [Windows.Security.Credentials.PasswordVault, Windows.Security.Credentials, ContentType=WindowsRuntime]::new()

try {
    # Extract the encrypted password payload string securely from the local system vault
    \$CredentialResult = CredentialFetch.Retrieve(TargetTarget, "SystemNode")
    SecretToken = CredentialResult.Password
    Write-Output "Successfully bound secure authentication token from DPAPI container."
} catch {
    # Fallback response context handling if a local technician deletes the token from the vault
    \$DriftDetected = \(true\)CurrentStatus = "Drifted"
    \(CurrentEventID = 40660\)RemediationLog += "[SECURITY FAULT] Handshake credential 'VirusTC-API-Handshake' not found inside Windows Credential Manager."
    
    # Set fallback token variable state to empty string to prevent successful payload generation leaks
    \$SecretToken = ""
}

# ============================================================================
# CENTRALIZED API DISPATCH (Uses the securely extracted token)
# ============================================================================
if (\$SecretToken -ne "") {
    \$BodyJson = @{
        AuthToken      = \$SecretToken  # Secure token referenced dynamically from memory
        WorkstationID  = \$WorkstationID
        GpuHardware    = "ASUS TUF RTX 5080" 
        EventID        = \$CurrentEventID
        Status         = \$CurrentStatus
        LogDetails     = (\$RemediationLog -join " | ")
    } | ConvertTo-Json

    # Send payload securely to network storage node listener
    Invoke-RestMethod -Uri "https://hospital.local" -Method Post -Body \$BodyJson -ContentType "application/json"
}
```
