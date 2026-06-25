# IT & Systems Infrastructure Guide: Network & DICOM Streaming Optimization
**Target Environment:** Datacenter VDI Hypervisor to Local Hospital Endpoints / Diagnostic Monitors
**Objective:** Minimize packet-delivery latency and eliminate image stuttering during high-fidelity Carestream 2D/3D DICOM transfers and HDX video streaming.

This document details the network-layer configurations, Quality of Service (QoS) parameters, and DICOM Maximum Transmission Unit (MTU) optimizations required to establish a real-time, low-latency conduit between the centralized VDI host and the endpoint diagnostic display.

---

## 1. Network Interface Card (NIC) & MTU Sizing Protocols
Standard Ethernet frames (1500 bytes) cause massive fragmentation when transporting dense 2D/3D clinical image matrices. Enabling jumbo frames across the entire routing path reduces CPU overhead on the hypervisor and accelerates packet assembly.

### Step-by-Step Infrastructure Alignment
1. **Switch & Router Core Configuration:**
   * Enable **Jumbo Frames** on all core, distribution, and access-layer switches handling clinical VLAN traffic.
   * Set the maximum transmission unit global value to **9000 bytes** (or up to 9216 bytes depending on switch vendor hardware limits).
2. **Hypervisor Virtual Switch (vSwitch) Configuration:**
   * Inside the hypervisor (e.g., VMware vSphere), open the properties of your distributed switch.
   * Change the MTU setting from the default `1500` to **9000**.
3. **Guest OS / VDI Master Image Configuration:**
   * Open Device Manager inside the Master Image (`devmgmt.msc`).
   * Expand **Network Adapters**, right-click the virtual NIC (e.g., *VMXNET3*), and select **Properties**.
   * Under the **Advanced** tab, select **Jumbo Packet** (or Jumbo Frame) and set the value to **9014 bytes** or **9KB MTU**.

---

## 2. Quality of Service (QoS) & Differentiated Services (DiffServ) Map
To prevent automated background server backups or guest internet activity from delaying time-critical diagnostic imaging streams, deploy an explicit end-to-end QoS policy using Differentiated Services Code Point (DSCP) markers.

### DSCP Traffic Classification Architecture

| Traffic Profile | Protocol / Port Range | DSCP Value | Per-Hop Behavior (PHB) | Priority Class |
| :--- | :--- | :--- | :--- | :--- |
| **Citrix HDX Video Stream** | UDP/TCP `1494`, `2598` | **`EF` (DSCP 46)** | Expedited Forwarding | Voice-grade / Real-Time Media |
| **PACS DICOM Transfer** | TCP `104`, `4242`, `11112` | **`AF41` (DSCP 34)** | Assured Forwarding | High-Priority Data |
| **Standard Administrative** | All other corporate ports | **`DF` (DSCP 0)** | Default Best Effort | Standard Workstation |

### Windows GPO Policy Injection (Master Image Baseline)
Execute these commands via local administrative PowerShell or domain GPO to auto-tag outbound packets originating from the Carestream application ecosystem:

```powershell
# Create Policy for Real-Time Citrix HDX Streaming Traffic
New-NetQosPolicy -Name "Citrix_HDX_Graphics" -AppPathNameMatchCondition "wfica32.exe" -DSCPAction 46

# Create Policy for High-Priority Core Carestream DICOM Traffic
New-NetQosPolicy -Name "Carestream_DICOM_Data" -AppPathNameMatchCondition "CSImaging.exe" -DSCPAction 34
```

---

## 3. TCP/IP Stack & Citrix Adaptive Transport Fine-Tuning
By default, standard TCP window negotiation introduces latency penalties over corporate hospital networks. Switching to a UDP-first protocol ensures smooth rendering when manipulating 3D dental arches or scrolling through large image arrays.

### Activate Citrix EDT (Enlightened Data Transport)
Ensure that the Citrix infrastructure is configured to prioritize **EDT (UDP)** over traditional TCP:
1. Open **Citrix Studio** and navigate to **Policies**.
2. Edit or create your baseline workstation performance policy.
3. Locate **HDX Adaptive Transport** and set the state explicitly to **Diagnostic / Preferred**.
4. Set **HDX Adaptive Transport MTU discovery** to **Enabled** to allow automated path tuning across subnets.

### Registry-Level TCP Window Optimizations
If a fallback to TCP occurs due to perimeter firewall rule sets, ensure the guest OS TCP stack handles large clinical objects efficiently by running these commands inside the Master Image:

```cmd
:: Enable Receive-Side Scaling (RSS) to distribute packet processing across CPU cores
netsh int tcp set global rss=enabled

:: Optimize the TCP Auto-Tuning Level for large high-throughput files
netsh int tcp set global autotuninglevel=normal

:: Enable Explicit Congestion Notification (ECN) to reduce packet drop-and-retransmit delays
netsh int tcp set global ecn=enabled
```

---

## 4. Operational Network Validation Checklist (Technologist Node Verify)

Before certifying a newly provisioned VDI diagnostic monitor station for live clinical deployment, a network systems engineer must perform and sign off on the following diagnostic validation tasks:

* [ ] **Jumbo Frame Path Ping Verification:** Open a command prompt on the endpoint and execute `ping -f -l 8972 [VDI_IP_Address]`. The command must return a 100% success rate without requesting packet fragmentation.
* [ ] **DSCP Tag Enforcement Audit:** Execute a sample image transfer session while running a network sniffer (e.g., Wireshark) on the local workstation switchport. Confirm that outbound UDP frames from the datacenter possess the `0x2e` (DSCP 46) header attribute.
* [ ] **Packet Loss & Jitter Benchmarking:** Run a continuous network performance test for 60 seconds during peak operational hours. Jitter bounds between the hypervisor host and the diagnostic display monitor must consistently register **under 5ms**, with a maximum allowable packet loss rate of **< 0.05%**.
* [ ] **Monitor Refresh Rate Alignment:** Verify via Windows Display Settings on the endpoint that the physical monitor refresh rate matches the target output profile configured in Citrix Studio (e.g., 60Hz baseline for diagnostic-grade viewing panels).

---
**Prepared By:** Hospital Network Engineering & Infrastructure Security Team  
**Review Status:** Final Production Release for Hospital LAN Deployment  
