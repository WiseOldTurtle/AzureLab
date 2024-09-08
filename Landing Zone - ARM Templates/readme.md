# *Azure Landing Zone Project: Release Pipeline, ARM, Azure DevOps, Networking*


## **Architecture:** 


Tools:
- app.eraser.io (Designing Landing Zone Architecture) ## TO BE DONE
- Azure (Cloud Infrastructure)
- ARM Templates / Release Pipelines (Infrastracture As Code)
- Azure DevOps (CI/CD Pipelines + Git Version Control)


**Through the integration of these tools, I successfully:**
- Designed an Azure Landing Zone
- Provisioned Azure infrastructure using ARM/JSON infrastructure as code
- Effectively automated the build process for my ARM infrastructure using Azure Pipelines
- Published the build as an artifact and configured continuous deployment to be triggered by the build artifact and deploy the ARM Infrastructure.
- Added another stage to my release pipeline to automatically cleanup the resources on approval to optimize resource utilization and minimize costs.

## **ARM Configuration:**




## **Azure DevOps Pipeline:**
Build Pipeline:
YAML:
``` YAML

```


# **Project Summary:** *Azure Landing Zone Deployment*

## **Evaluation:**

I first designed an Azure Landing Zone by creating a diagram on app.eraser.io to plan out my project and have a high level understanding of what I was going to build.

I developed an Azure Landing Zone utilizing ARM, showcasing my proficiency in cloud architecture and infrastructure as code (IaC). The project aimed to demonstrate my skills and enhance my resume by showcasing my ability to design and deploy Azure resources efficiently.

The architecture comprised of three resource groups:

Identity: This resource group focused on security, incorporating Azure Security Center, Azure Key Vault, and policy definitions to ensure robust governance and compliance.

Management/Logging: Hosting Log Analytics Workspaces, this group facilitated centralized monitoring and management, enhancing operational efficiency.

Network: Serving as the connectivity backbone, this group included firewall configurations, Virtual Hub, Virtual WAN, DNS configurations, Network Security Groups (NSG) and Application Security Groups (ASG) to ensure secure network communication. I also implemented VNET peering and the use of UDRs. ## TO BE DONE -- ASG, FIREWALL CONFIG, DNS.

Application: This group housed the essential components for application functionality, including Virtual Network (VNet), Load Balancer for the front-end, Virtual Machine (VM) for the application-end, SQL Server, and SQL Database for the database-end. ## TO BE DONE

To automate my infrastructure deployment and ensure security, I utilized Azure DevOps to create a CI/CD pipeline. The pipeline integrated Terraform for provisioning and Trivy for misconfiguration scanning , streamlining deployment and ensuring adherence to security standards.

I additionally implemented a clean-up stage to facilitate resource destruction upon approval, optimizing resource utilization and minimizing costs. ## TO BE DONE 

In conclusion, this project served as a valuable showcase of my skills in cloud architecture, infrastructure automation, and security, demonstrating my proficiency in cloud technologies and DevOps tools.
