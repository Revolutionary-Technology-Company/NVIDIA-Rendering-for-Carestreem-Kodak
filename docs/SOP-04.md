[SOP-04] Real-Time Multimodal Diagnostic Reasoning Deployment

1\. Clinical Intent & Indications

To provide immediate, localized, AI-driven diagnostic insights, preliminary abnormality classifications, and structured annotations directly onto the workstation viewer right after image capture.

2\. Infrastructure Prerequisites

-   **Hardware:** Local NVIDIA RTX Pro 6000 workstation.
-   **Software:** `NV-Reason-CXR-3B` local AI engine or compatible edge reasoning plugin container running locally.

3\. Configuration Steps

```
[Plugins] ➔ [Local AI Models] ➔ [Activate NV-Reason-CXR Inference]

```

1.  Open **CS Imaging Suite 3.26**.
2.  Navigate to **Options** ➔ **Plugin Manager** ➔ **Add Local Engine**.
3.  Target the local installation path of the `NV-Reason-CXR` inference directory.
4.  Select the option labeled: **Run Inference on Local Node via NVIDIA TensorRT-LLM**.
5.  Under **Trigger Mechanics**, select **On Image Capture Finalization**.
6.  Check the box marked **Generate Interactive Text Insights Panel**.
7.  Click **Apply Changes**.

4\. Clinical Execution & Operator Workflow

1.  Capture or import the target radiographic study.
2.  Once rendering finishes, a floating sidebar labeled **NVIDIA Clara Reason Engine** will automatically slide open on the right edge of the viewer window.
3.  **Interpreting Results:**
    -   Review the generated point-by-point architectural text summary.
    -   Observe any highlighted regions of interest (ROI boxes) overlaid directly onto the image canvas.
4.  Use these findings as an immediate secondary review step to verify that no critical, acute abnormalities are missed before the patient leaves the clinic floor.
