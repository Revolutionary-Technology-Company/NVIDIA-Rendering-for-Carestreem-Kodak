[SOP-09] Caries Pro Mode & AI Dental Radiograph Analysis1. Clinical Intent & IndicationsTo automate the localization, depth tracking, and mapping of carious lesions in dental and maxillofacial panoramic/intraoral bitewing radiographs. This uses GPU-accelerated deep-learning vision models to eliminate inter-examiner variance and assist practitioners in discovering early enamel/dentin decay.2. Infrastructure PrerequisitesHardware: Local workstation running an NVIDIA RTX Pro 6000.Software: CS 3D / Intraoral Suite featuring AI Insights: Caries Pro Mode.3. Configuration Steps[Dental Modules] ➔ [AI Insights Config] ➔ [Activate Caries Pro Mapping]
Open CS Imaging Suite 3.26 on the dental operatory workstation.Navigate to Options ➔ AI Diagnostics Configuration.Under the AI Insights panel, check the box to "Enable Caries Pro Detection Mode".Toggle Interactive Tooth Chart Integration to On.Select the GPU Allocation Profile and set it to force the execution directly through your NVIDIA RTX Pro 6000 Workspace Node.Set the minimum confidence threshold to 85% to limit false positives from existing restoration restorations.Click Save.4. Clinical Execution & Operator WorkflowTake standard intraoral bitewing or panoramic exposures using the Carestream RVG sensor or dental unit.Open the captured image inside the patient chart view.Click the AI Insights button on the toolbar.Clinical Evaluation:The software will analyze the image structure via the RTX Pro 6000 and overlay color-coded indicators highlighting carious lesions.Filled Icons represent advanced dentin caries; Hollow/Symbol Icons denote superficial enamel lesions.The corresponding findings will map directly onto the interactive 3D tooth chart interface.Review the structural overlays with the patient on the screen to clarify treatment requirements before saving the findings to the digital chart.[SOP-09] Caries Pro Mode & AI Dental Radiograph Analysis

1\. Clinical Intent & Indications

To automate the localization, depth tracking, and mapping of carious lesions in dental and maxillofacial panoramic/intraoral bitewing radiographs. This uses GPU-accelerated deep-learning vision models to eliminate inter-examiner variance and assist practitioners in discovering early enamel/dentin decay.

2\. Infrastructure Prerequisites

-   **Hardware:** Local workstation running an NVIDIA RTX Pro 6000.
-   **Software:** CS 3D / Intraoral Suite featuring **AI Insights: Caries Pro Mode**.

3\. Configuration Steps

```
[Dental Modules] ➔ [AI Insights Config] ➔ [Activate Caries Pro Mapping]

```

1.  Open **CS Imaging Suite 3.26** on the dental operatory workstation.
2.  Navigate to **Options** ➔ **AI Diagnostics Configuration**.
3.  Under the *AI Insights* panel, check the box to **"Enable Caries Pro Detection Mode"**.
4.  Toggle **Interactive Tooth Chart Integration** to **On**.
5.  Select the **GPU Allocation Profile** and set it to force the execution directly through your **NVIDIA RTX Pro 6000 Workspace Node**.
6.  Set the minimum confidence threshold to **85%** to limit false positives from existing restoration restorations.
7.  Click **Save**.

4\. Clinical Execution & Operator Workflow

1.  Take standard intraoral bitewing or panoramic exposures using the Carestream RVG sensor or dental unit.
2.  Open the captured image inside the patient chart view.
3.  Click the **AI Insights** button on the toolbar.
4.  **Clinical Evaluation:**
    -   The software will analyze the image structure via the RTX Pro 6000 and overlay color-coded indicators highlighting carious lesions.
    -   **Filled Icons** represent advanced dentin caries; **Hollow/Symbol Icons** denote superficial enamel lesions.
    -   The corresponding findings will map directly onto the interactive 3D tooth chart interface.
5.  Review the structural overlays with the patient on the screen to clarify treatment requirements before saving the findings to the digital chart.
