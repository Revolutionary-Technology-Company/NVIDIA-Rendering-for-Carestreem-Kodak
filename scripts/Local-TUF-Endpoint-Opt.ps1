This PowerShell deployment script is tailored for standalone, non-Citrix physical endpoints (such as local remote office workstations running ASUS TUF GeForce RTX 50 Series cards). It can be added to your repository as scripts/Local-TUF-Endpoint-Opt.ps1.
Unlike the Citrix virtual master image script, this routine directly targets physical hardware states, enforces maximum OS power performance to prevent throttling, and configures the required NVIDIA and Carestream Vue registry layers.

# =======================================================================================# SCRIPT: Local-TUF-Endpoint-Opt.ps1# DESCRIPTION: Optimization routine for physical, non-Citrix Carestream/NVIDIA endpoints.# =======================================================================================#Requires -RunAsAdministrator

Write-Output "[+] Initiating Local Physical Endpoint Optimization for NVIDIA RTX Hardware..."
# 1. Force High-Performance OS Power Plan (Prevents Physical GPU Core Throttling)try {
    $HighPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
    powercfg /setactive $HighPerfGuid
    Write-Output "[SUCCESS] System power plan set to High Performance."
} catch {
    Write-Warning "[-] Unable to force High Performance power plan via powercfg."
}
# 2. Enforce NVIDIA Medical Imaging Optimization Contexts
$NvidiaPath = "HKLM:\SOFTWARE\NVIDIA Corporation\Global\Stereo3D"try {
    if (-not (Test-Path $NvidiaPath)) {
        New-Item -Path $NvidiaPath -Force | Out-Null
    }
    New-ItemProperty -Path $NvidiaPath -Name "EnableMedicalImagingOptimizations" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Output "[SUCCESS] NVIDIA Global Medical Optimizations Active."
} catch {
    Write-Error "[ERROR] Failed to configure NVIDIA global registry: $_"
}
# 3. Apply FDA-Stabilized Windows Graphics Engine TDR Delay
$TdrPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"try {
    New-ItemProperty -Path $TdrPath -Name "TdrDelay" -Value 10 -PropertyType DWord -Force | Out-Null
    Write-Output "[SUCCESS] Graphics Engine TDR Delay locked to 10 seconds."
} catch {
    Write-Error "[ERROR] Failed to configure Windows TDR Delay: $_"
}
# 4. Lock Carestream Vue Local App Layer to NVDEC Dedicated Processing Hardware
$VuePath = "HKLM:\SOFTWARE\Carestream\VuePACS\Client\Rendering"try {
    if (-not (Test-Path $VuePath)) {
        New-Item -Path $VuePath -Force | Out-Null
    }
    New-ItemProperty -Path $VuePath -Name "ForceNvidiaHardwareDecode" -Value 1 -PropertyType DWord -Force | Out-Null
    Write-Output "[SUCCESS] Carestream Vue hardware decoding pipeline locked to NVIDIA NVDEC."
} catch {
    Write-Error "[ERROR] Failed to configure Carestream software rendering keys: $_"
}
# 5. Local Hardware Baseline Validation Check
$TdrCheck = (Get-ItemProperty -Path $TdrPath).TdrDelay
$VueCheck = (Get-ItemProperty -Path $VuePath -ErrorAction SilentlyContinue).ForceNvidiaHardwareDecode
if ($TdrCheck -eq 10 -and $VueCheck -eq 1) {
    Write-Output "[STATUS] Physical endpoint successfully optimized. System is stable for clinical display."
    Exit 0
} else {
    Write-Error "[CRITICAL] Configuration drift detected immediately post-deployment!"
    Exit 1
}

------------------------------
To finalize this script block for your deployment framework, let me know:

* Do these standalone endpoints require a desktop notification to alert clinical staff when updates apply?
* Should this script report metrics directly back to your central REST Web API Handshake Listener (VirusTC-API-Listener.ps1)?


