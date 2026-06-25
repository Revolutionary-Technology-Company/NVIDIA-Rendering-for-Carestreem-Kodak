[SOP-07] Virtual SmartGrid Scatter Mitigation & Dose Optimization

1\. Clinical Intent & Indications

To eliminate the need for physical anti-scatter grids during portable or bed-side X-ray exams (e.g., intensive care, trauma bays). This software-defined module uses convolutional neural networks (CNNs) to calculate and subtract scatter radiation dynamically, lowering patient dose while retaining the high-contrast properties of a physical grid exam.

2\. Infrastructure Prerequisites

-   **Hardware:** NVIDIA RTX Pro 6000 GPU (leveraging specialized Ampere/Ada Lovelace integer math capabilities).
-   **Software:** Carestream **SmartGrid Technology** plugin activated within the acquisition engine.

3\. Configuration Steps

```
[Acquisition Profiles] ➔ [Grid Profiles] ➔ [Virtual SmartGrid (NVIDIA TensorRT)]

```

1.  Open the **Carestream Acquisition Suite** dashboard.
2.  Select **System Configuration** ➔ **Anatomical Processing Settings**.
3.  Navigate to large-anatomy exams (e.g., *Abdomen, Pelvis, Lumbar Spine*).
4.  Under **Scatter Management**, select **SmartGrid Algorithm (Virtual)**.
5.  Set the **Grid Ratio Emulation Factor** to **10:1** or **12:1** depending on the specific patient body mass index (BMI) category.
6.  Verify that the **NVIDIA TensorRT acceleration backend** is checked for ultra-low latency execution (< 0.4 seconds per frame).
7.  Click **Commit Changes**.

4\. Clinical Execution & Operator Workflow

1.  Position the Carestream DRX/Focus detector directly behind the patient *without* snapping on a physical lead grid frame.
2.  Adjust exposure factors down to **Non-Grid Technique baselines** (typically saving 50% or more mAs relative to a traditional physical grid technique).
3.  Take the exposure.
4.  The GPU captures the high-scatter raw data matrix and applies the algorithmic model to restore gray-scale contrast levels instantly.
5.  Confirm the absence of scatter fogging before locking the file into the Electronic Health Record (EHR).
