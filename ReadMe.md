# Collaborative Model-Based Systems Engineering
This repository provides the example SysML v2 model, which includes:
* A simplified example model that shows the basic structure of SysML v2 
* A concrete example model about measurement system that enables precise force measurement capabilities 
* One necessary sub-system of measurement system as the load cell model.  

The examples are used to show the collaboration between OEM and the supplier focused on the aspects of model development and model exchange. The collaboration process is based on the idea of the following CMBSE approach. 
![Collaboration process between OEM and suppliers using SysML v2 model](https://github.com/ziruili-tu-ilmenau/CMBSE/blob/60358f93b28067763363fb422bbe7f24ee35d2a5/image/Collaboration%20process%20between%20OEM%20and%20suppliers%20using%20SysML%20v2%20model.png)


## How to check the model
To import and check the model, the relevant installer for eclipse plugins (KerML and SysML Editors & PlantUML visualization) or Jupyter kernel (SysML language kernel) is required. 
The further installation guides can be found in the **SysML-v2-Release repository** (Link:[SysML-v2-Release](https://github.com/Systems-Modeling/SysML-v2-Release/tree/master)), in the _install_ dictionary.
> To visulize the textual notations of the model in the eclipse, model project **sysml.library** in the **SysML-v2-Release repository** must be installed and built with following the installation guides _(Path: install/eclipse/README.adoc)_. 

## Prompt-Driven Model Alignment
To support semantic consistency and model integration in collaborative MBSE scenarios, we introduce a **structured prompt-driven alignment pipeline**, designed to work with SysML v2 textual models and GPT-based large language models (LLMs). This process builds upon the methods described in our research and emphasizes traceable, semantically grounded mapping between independently developed system models (OEM ↔ Supplier).

The alignment prompt enables:

- Extraction of model structure and semantics in structured JSON  
- Iterative alias-based and extension-based matching  
- Explicit user validation and feedback checkpoints at each stage  
- Generation of additive alignment packages using `import` and `alias`  
- Semantic extension support via customizable metadata libraries  

📄 You can find the full prompt specification here:  
[`prompts/sysmlv2_alignment_pipeline.md`](./prompts/sysmlv2_alignment_pipeline.md)

## Related Work
The model shows the implementation of SysML v2 model and Dataspaces in the published paper **Collaborative Model-Based Systems Engineering Using Dataspaces and SysML v2** [Doi](https://doi.org/10.3390/systems12010018) as the contribution from [Product and Systems Engineering Group](https://www.tu-ilmenau.de/en/university/departments/department-of-mechanical-engineering/profile/institutes-and-groups/engineering-design-group), Department of Mechanical Engineering, Technische Universität Ilmenau.