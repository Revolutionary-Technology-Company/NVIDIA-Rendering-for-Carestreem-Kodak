# Endpoint Optimization: Live Computer-Vision Video Stream Routing
**Target Hardware:** ASUS TUF GeForce RTX 50 Series (Client Endpoint Node)  
**Upstream Source:** NVIDIA RTX Pro 6000 (Datacenter Node via NVIDIA Clara Holoscan Edge AI)

## 1. Clinical Intent & Operational Mechanics
The NVIDIA Clara positioning system uses in-room cameras to track patient posture and overlay bounding boxes on the operator screen in real time. For a doctor viewing this data from a private office or remote clinic node, this visual stream arrives as a composite video overlay. The ASUS TUF card ensures that this real-time video feed runs smoothly alongside clinical charts, preventing video frame drops from obscuring critical positioning alerts.

## 2. Infrastructure Setup & Executable Mapping
This protocol ensures that the real-time streaming network packets targeting the local display hardware are classified as high-priority media traffic.

## 3. Configuration Steps
[PowerShell] ➔ [New-NetQosPolicy] ➔ [Bind CDViewer.exe to DSCP 46]

### Inbound Quality of Service (QoS) Target Tagging
1. Open Windows PowerShell with Administrative Privileges.
2. Run the following command to flag the Citrix display viewer container, ensuring its incoming streaming packets bypass local office bandwidth constraints:

```powershell
New-NetQosPolicy -Name "VirusTC_TUF_Inbound_Video" -AppPathNameMatchCondition "CDViewer.exe" -DSCPAction 46
```

### Configure Windows Graphics Acceleration Policy
1. Go to Windows **Settings** ➔ **System** ➔ **Display** ➔ **Graphics**.
2. Click **Browse** and navigate to `C:\Program Files (x86)\Citrix\ICA Client\CDViewer.exe`.
3. Select **Options**, set the profile to **High Performance**, and confirm that it lists your **ASUS TUF GeForce RTX 50** card.
4. Click **Save**.

## 4. Clinical Verification Workflow
1. Launch the Carestream live acquisition monitoring console.
2. Observe the camera stream window showing the patient positioning interface.
3. **Validation Threshold:** The video overlay must display at a consistent 30 frames per second without stuttering or frame skipping, allowing the clinician to accurately confirm proper patient alignment before authorizing an exposure.
