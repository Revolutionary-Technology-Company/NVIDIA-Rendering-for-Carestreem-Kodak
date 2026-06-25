# IT & Systems Infrastructure Guide: Citrix Virtual Apps and Desktops vGPU Optimization
**Target Hardware:** NVIDIA RTX Pro 6000 (Hosted in Datacenter Hypervisor)
**Target Platform:** Citrix Virtual Apps and Desktops (CVAD) / Carestream (CS) Imaging Suite 3.26
**Hypervisor Support:** VMware ESXi / Citrix Hypervisor (XenServer)

This document outlines the infrastructure-level protocols required to provision, profile, and optimize NVIDIA vGPU resources for Carestream AI applications within a virtualized clinical desktop infrastructure (VDI).

---

## 1. NVIDIA vGPU Profile Architecture Selection
To support advanced clinical processing like 3D CBCT iterative reconstruction and real-time AI noise cancellation, endpoints cannot use shared graphics framebuffers. Workstations must be provisioned with dedicated **"Q-profile" (Virtual Workstation)** templates to pass CUDA and Tensor capabilities directly to the guest OS.

### Recommended Profile Allocation Matrix
Depending on the generation of your RTX Pro 6000 (Ampere 48GB vs. Ada Lovelace 48GB), use the following sizing guidelines per VM node:

| VDI Workstation Profile | VRAM Allocation | Max Density per Host | Target Clinical Use Case |
| :--- | :--- | :--- | :--- |
| **`NVIDIA-RTX-PRO-6000-12Q`** | 12 GB | 4 VMs per GPU | Standard 2D Digital Radiography, Bone Suppression, Tube/Line Tracking, Intraoral Bitewings. |
| **`NVIDIA-RTX-PRO-6000-24Q`** | 24 GB | 2 VMs per GPU | High-throughput 3D Volumetric CBCT Reconstruction, Panoramic Caries Pro Mode modeling. |

---

## 2. Hypervisor-Level Host Configurations

### Enforce Graphics Performance Policy (ESXi Example)
To prevent hypervisor power-saving features from injecting micro-stuttering or latency into the Carestream image-acquisition pipeline:

1. Log in to the **VMware vSphere Client**.
2. Navigate to the host cluster containing the physical RTX Pro 6000 cards.
3. Select a host, go to **Configure** ➔ **Hardware** ➔ **Power Management**.
4. Click **Edit Power Policy** and set it explicitly to **High Performance**.

### Assign the vGPU Device to the Guest VM
1. Power off the target Carestream Master Image VM.
2. Right-click the VM and select **Edit Settings**.
3. Click **Add New Device** ➔ **PCI Device**.
4. Select **NVIDIA vGPU** from the dropdown menu.
5. Choose your designated profile (e.g., `NVIDIA-RTX-PRO-6000-12Q`).
6. Expand the memory section of the VM and check **"Reserve all guest memory (All-locked)"**. This is a mandatory prerequisite for CUDA functionality inside a Citrix session.

---

## 3. Guest OS & Citrix HDX Policy Engineering
Apply these registry and group policy updates to your Master Gold Image before sealing and deploying via Citrix Provisioning Services (PVS) or Machine Creation Services (MCS).

### Optimize Citrix HDX 3D Pro Policies
Configure these settings via Citrix Studio Group Policy to ensure low-latency delivery of the processed X-ray pixel streams to thin clients:

*   **Optimize for 3D graphics workload:** Enabled
*   **Hardware encoding for video codec:** Enabled (Forces Citrix to compress the screen delivery using the NVIDIA NVENC hardware chip)
*   **Use video codec for compression:** For the entire screen
*   **Target frame rate:** 30 FPS (Sufficient for clinical validation while managing datacenter bandwidth)

### Registry Overrides for Carestream Executables
To ensure Citrix HDX graphics acceleration binds tightly to the Carestream application stack, insert the following registry keys into the Master Image:

```cmd
:: Force Citrix Hooking Engine to prioritize Carestream executables for GPU acceleration
reg add "HKLM\SOFTWARE\Citrix\CtxHook\Appops\CSImaging" /v "Name" /t REG_SZ /d "CSImaging.exe" /f
reg add "HKLM\SOFTWARE\Citrix\CtxHook\Appops\CSImaging" /v "Flag" /t REG_DWORD /d 0x00000020 /f

reg add "HKLM\SOFTWARE\Citrix\CtxHook\Appops\CSImagingLinkServer" /v "Name" /t REG_SZ /d "CSImagingLinkServer.exe" /f
reg add "HKLM\SOFTWARE\Citrix\CtxHook\Appops\CSImagingLinkServer" /v "Flag" /t REG_DWORD /d 0x00000020 /f
```

---

## 4. Virtual NVML Configuration & Licensing Framework
Unlike physical hardware, virtual GPUs require a licensing token from an **NVIDIA License System (NLS)** server to activate full performance and compute functionalities.

### Automate vGPU License Acquisition
Add this script to the Citrix startup sequence via Group Policy Object (GPO) to ensure the VM registers with the license pool immediately upon user login:

```batch
@echo off
:: Check vGPU License Status via Virtual NVML command pipeline
"C:\Program Files\NVIDIA Corporation\NVIDIA-SMI\nvidia-smi.exe" -q | findstr /C:"License Status" > C:\Program Files\Carestream\Logs\vgpu_licensing.log

:: If the system returns "Unlicensed", restart the frame-buffer allocation service
findstr /C:"Unlicensed" C:\Program Files\Carestream\Logs\vgpu_licensing.log
if %errorlevel%==0 (
    net stop NVDisplay.ContainerLocalSystem
    timeout /t 5
    net start NVDisplay.ContainerLocalSystem
    echo [ACTION] vGPU Container restarted to force license lease recovery. >> C:\Program Files\Carestream\Logs\vgpu_licensing.log
)
```

---

## 5. VDI Troubleshooting & Performance Validation

| Problem Identification | VDI Root Cause | Corrective Remediation |
| :--- | :--- | :--- |
| Carestream software defaults to CPU rendering inside Citrix session. | VM memory reservation was missed or not set to 100% fully-locked. | Shut down the VM, open vSphere/Hypervisor settings, and enforce **"Reserve all guest memory"**. CUDA will remain disabled if system memory is overcommitted. |
| Grey screen or artifact trailing when moving a 3D dental arch. | Citrix HDX session is using thin-wire CPU compression instead of NVENC hardware encoder. | Open Citrix Studio, check user policies, and verify that **Hardware encoding for video codec** is active. Run `nvidia-smi` on the host to check if the `Encoder` block registers session activity. |
| Processing speeds drop under heavy hospital load conditions. | Multiple high-utilization VMs are conflicting on a single physical GPU node. | Change host consolidation policies from *Breadth-First* (cramming VMs onto a single card) to **Depth-First** to evenly distribute Carestream loads across different physical RTX Pro 6000 cards. |

---
**Prepared By:** Hospital Virtualization & Infrastructure Systems Team  
**Review Status:** Approved for Multi-Session VDI Infrastructure Rollout  
