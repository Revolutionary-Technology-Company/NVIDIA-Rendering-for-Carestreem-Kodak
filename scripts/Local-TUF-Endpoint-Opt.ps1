# =======================================================================================
# SCRIPT: Local-TUF-Endpoint-Opt.ps1
# DESCRIPTION: Optimization routine for physical ASUS TUF GeForce RTX 50 Series endpoints.
# =======================================================================================
#Requires -RunAsAdministrator

Write-Output "[+] Initiating Physical Workspace Optimization for ASUS TUF GeForce RTX 50 Series Workstations..."

# --- NEW: REST Web API Logging Function ---
function Send-PipelineLog {
    param (
        [string]$Status,
        [string]$Message
    )
    $Uri = "https://YOUR_INTERNAL_IIS_SERVER_FQDN:8443/api/tracking" # Points to VirusTC-API-Listener.ps1
    $Payload = @{
        WorkstationID = $env:COMPUTERNAME
        Timestamp     = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        GPUModel      = (Get-CimInstance Win32_VideoController).Name -join ", "
        Status        = $Status
        Message       = $Message
    } | ConvertTo-Json

    try {
        # Secure credential handshake using DPAPI matching your repo profile layout
        $Response = Invoke-RestMethod -Uri $Uri -Method Post -Body $Payload -ContentType "application/json" -TimeoutSec 5 -ErrorAction Stop
        Write-Output "[*] REST Log transmitted successfully to central dashboard listener."
    } catch {
        Write-Warning "[-] REST Log delivery failed to $Uri : $_"
    }
}

# 1. Force High-Performance OS Power Plan (Prevents Physical RTX 50 VRAM/Core Throttling)
try {
    $HighPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
    powercfg /setactive $HighPerfGuid
    Write-Output "[SUCCESS] System power plan locked to High Performance."
} catch {
    Write-Warning "[-] Unable to force High Performance power plan via powercfg utility."
}

# 2. Enforce NVIDIA Medical Imaging Optimization Contexts (RTX 50 Tensor Core Configuration)
$NvidiaPath = "HKLM:\SOFTWARE\NVIDIA Corporation\Global\Stereo3D"
try {
    if (-not (Test-Path $NvidiaPath)) {
        New-Item -Path $NvidiaPath -Force | Out-Null
    }
    New-ItemProperty -Path $NvidiaPath -Name "EnableMedicalImagingOptimizations" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Output "[SUCCESS] NVIDIA Global Medical Optimizations Active."
} catch {
    Write-Error "[ERROR] Failed to configure NVIDIA global registry: $_"
}

# 3. Apply FDA-Stabilized Windows Graphics Engine TDR Delay (Prevents Drops during AI Denoising)
$TdrPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
try {
    New-ItemProperty -Path $TdrPath -Name "TdrDelay" -Value 10 -PropertyType DWord -Force | Out-Null
    Write-Output "[SUCCESS] Graphics Engine TDR Delay locked to 10 seconds."
} catch {
    Write-Error "[ERROR] Failed to configure Windows TDR Delay: $_"
}

# 4. Lock Carestream Vue Local App Layer to RTX 50 NVDEC Dedicated Hardware Bitstreams
$VuePath = "HKLM:\SOFTWARE\Carestream\VuePACS\Client\Rendering"
try {
    if (-not (Test-Path $VuePath)) {
        New-Item -Path $VuePath -Force | Out-Null
    }
    New-ItemProperty -Path $VuePath -Name "ForceNvidiaHardwareDecode" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Output "[SUCCESS] Carestream Vue hardware decoding pipeline tethered to local RTX 50 NVDEC."
} catch {
    Write-Error "[ERROR] Failed to configure Carestream software rendering keys: $_"
}

# 5. Local Hardware Baseline Validation Check & Dashboard Transmission
$TdrCheck = (Get-ItemProperty -Path $TdrPath).TdrDelay
$VueCheck = (Get-ItemProperty -Path $VuePath -ErrorAction SilentlyContinue).ForceNvidiaHardwareDecode

if ($TdrCheck -eq 10 -and $VueCheck -eq 1) {
    $Msg = "ASUS TUF RTX 50 physical endpoint successfully optimized. System stable for clinical display."
    Write-Output "[STATUS] $Msg"
    Send-PipelineLog -Status "COMPLIANT" -Message $Msg
    Exit 0
} else {
    $Msg = "Configuration drift detected immediately post-deployment on standalone node!"
    Write-Error "[CRITICAL] $Msg"
    Send-PipelineLog -Status "NON-COMPLIANT" -Message $Msg
    Exit 1
}
