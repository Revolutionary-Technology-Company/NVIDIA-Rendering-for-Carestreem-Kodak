[SOP-12] Real-Time Pneumothorax & Acute Abnormality Triage Flagging

1\. Clinical Intent & Indications

To screen emergency chest radiographs for life-threatening pathologies (such as free air in the pleural space/pneumothorax or tube misplacements) immediately after image acquisition, moving critical cases to the top of the radiology worklist automatically.

2\. Infrastructure Prerequisites

-   **Hardware:** Workstation paired with an NVIDIA RTX Pro 6000 GPU (leveraging mixed FP16/INT8 precision modes).
-   **Software:** Carestream **Critical Care Suite / AI Triage Engine**.

3\. Configuration Steps

```
[Plugin Manager] ➔ [Triage Profiles] ➔ [Activate NVIDIA Clara Triage Hook]

```

1.  Launch **CS Imaging Suite v3.26**.
2.  Go to **Options** ➔ **Advanced Plugins** ➔ **Carestream Triage Engine**.
3.  Under *Monitored Pathologies*, check the boxes for **Pneumothorax**, **Pleural Effusion**, and **Aortic Dissection**.
4.  Set the **Inference Priority** to **Maximum Accelerated (NVIDIA CUDA)**.
5.  In the PACS workflow manager section, select the action rule: **"If anomaly detected, append STAT Priority Flag to DICOM Metadata header"**.
6.  Click **Commit Configuration to System**.

4\. Clinical Execution & Operator Workflow

1.  Capture an emergency mobile or room-based chest radiograph.
2.  As the image processes, the local GPU analyzes the data matrix against the alert framework.
3.  **Clinical Action Plan:**
    -   If a critical pathology is found, an audible alert chimes and a flashing notification appears on the review screen.
    -   **PACS Transmission Action:** The image enters the diagnostic server tagged as a priority **STAT case**, automatically placing it at the top of the reading radiologist's workflow.

* * * * *
