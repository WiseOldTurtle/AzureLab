# Landing Zone Deployment with Terraform and Azure DevOps

This repository showcases my skills in **Terraform** and **Azure DevOps** (ADO) by automating the deployment of an Azure Landing Zone. Initially, this project deployed ARM templates via an ADO release pipeline, but I've enhanced it by transitioning to **Terraform** with a **YAML-based CI/CD pipeline**.

## Key Enhancements

- **Terraform Integration:** Replaced ARM templates with **Terraform** files to modernize and simplify the deployment process.
- **CI/CD with Azure Pipelines:** Introduced a YAML-based pipeline in **Azure DevOps** to automate the entire workflow—plan, apply, and destroy.
- **Iterative Task Handling:** Incorporated **foreach loops** in the pipeline to iterate against Terraform tasks, making the deployment process smarter and more efficient.
- **Flexible Terraform Actions:** Added the ability to select specific Terraform operations (plan, apply, destroy) through parameterization, enhancing pipeline flexibility.
- **Resource-Level Iteration:** Utilized **tfvars** files to manage **virtual networks (vnets)** and **subnets**, improving the organization and scalability of infrastructure deployments.

This project reflects my hands-on experience with **Terraform** and showcases my ability to build scalable and automated cloud solutions using **CI/CD pipelines** in ADO. 

Feel free to explore the repo and check out the different stages of deployment!

**Note** *I also have added in some useful Azure and Powershell scripts that I have either created or used during my time working.*
