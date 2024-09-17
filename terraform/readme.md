# *Azure Landing Zone Project: Terraform, Azure DevOps, Security*


## **Architecture:** 


Tools:
- app.eraser.io (Designing Landing Zone Architecture)
- Azure (Cloud Infrastructure)
- Terraform (Infrastracture As Code)
- Azure DevOps (CI/CD Pipelines + Git Version Control)
- Trivy (IAC Misconfiguration Scanning)

**Through the integration of these tools, I successfully:**
- Designed an Azure Landing Zone
- Provisioned Azure infrastructure using Terraform infrastructure as code
- Stored the terraform state file in a remote backend in an azure blob container
- Effectively automated the build process for my Terraform infrastructure using Azure Pipelines
- Integrated Trivy for insights into misconfigurations in my Terraform IAC code
- Published the build as an artifact and configured continuous deployment to be triggered by the build artifact and deploy the Terraform infrastructure.
- Added another stage to my release pipeline to automatically cleanup the resources on approval to optimize resource utilization and minimize costs.

## **Terraform Configuration:**

/terraform
   ├── /networking
   │     ├── main.tf          # VNETs and subnets (private)
   │     ├── variables.tf     # Variables for networking
   │     ├── outputs.tf       # Outputs from the networking module
   ├── /security
   │     ├── main.tf          # NSG rules for traffic control
   │     ├── variables.tf     # Variables for NSGs
   │     ├── outputs.tf       # Outputs from the security module
   ├── /policy
   │     ├── main.tf          # Azure policy for restricting public IPs and VM sizes
   ├── backend.tf             # Terraform state storage in Azure Blob Storage
   └── azure-pipelines.yml    # Azure DevOps pipeline for Terraform deployment



## **Azure DevOps Pipeline:**
Build Pipeline:
YAML:
``` YAML
trigger: 
- main

stages:
- stage: Build
  jobs:
  - job: Build
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    - checkout: self
      path: src
      clean: true
    - task: TerraformInstaller@1
      inputs:
        terraformVersion: 'latest'

    - task: CmdLine@2
      displayName: 'Download and Install Trivy vulnerability scanner'
      inputs:
        script: |
          sudo apt-get install rpm
           wget https://github.com/aquasecurity/trivy/releases/download/v0.20.0/trivy_0.20.0_Linux-64bit.deb
          sudo dpkg -i trivy_0.20.0_Linux-64bit.deb
          trivy -v

    - task: TerraformTaskV4@4
      displayName: Tf init
      inputs:
        provider: 'azurerm'
        command: 'init'
        backendServiceArm: Azure
        backendAzureRmResourceGroupName: 'tfstate'
        backendAzureRmStorageAccountName: 'tfbackend7890'
        backendAzureRmContainerName: 'tfbackend'
        backendAzureRmKey: 'prod.terraform.tfstate'

    - task: CmdLine@2
      displayName: 'LOW/MED - Trivy vulnerability scanner in IaC mode'
      inputs:
        script: |
          for file in $(find /home/vsts/work/1/src -name "*.tf"); do
              trivy config --severity LOW,MEDIUM --exit-code 0 "$file"
          done


    - task: CmdLine@2
      displayName: 'HIGH/CRIT - Trivy vulnerability scanner in IaC mode'
      inputs:
        script: |
          for file in $(find /home/vsts/work/1/src -name "*.tf"); do
              trivy config --severity HIGH,CRITICAL --exit-code 0 "$file"
          done

    - task: TerraformTaskV4@4
      displayName: Tf plan
      inputs:
        provider: 'azurerm'
        command: 'plan'
        commandOptions: '-out $(Build.SourcesDirectory)/tfplanfile'
        environmentServiceNameAzureRM: Azure
            
    - task: CopyFiles@2
      displayName: 'Copy Files to Staging'
      inputs:
        SourceFolder: '$(Agent.BuildDirectory)/src'
        Contents: 'Terraform/**'
        TargetFolder: '$(Build.ArtifactStagingDirectory)'
    - task: ArchiveFiles@2
      displayName: Archive files
      inputs:
        rootFolderOrFile: '$(Build.SourcesDirectory)/'
        includeRootFolder: false
        archiveType: 'zip'
        archiveFile: '$(Build.ArtifactStagingDirectory)/$(Build.BuildId).zip'
        replaceExistingArchive: true

    - task: PublishBuildArtifacts@1
      inputs:
        PathtoPublish: '$(Build.ArtifactStagingDirectory)'
        ArtifactName: '$(Build.BuildId)-build'
        publishLocation: 'Container'
```


# **Project Summary:** *Azure Landing Zone Deployment*

## **Evaluation:**

I first designed an Azure Landing Zone by creating a diagram on app.eraser.io to plan out my project and have a high level understanding of what i was going to build.

I developed an Azure Landing Zone utilizing Terraform, showcasing my proficiency in cloud architecture and infrastructure as code (IaC). The project aimed to demonstrate my skills and enhance my resume by showcasing my ability to design and deploy Azure resources efficiently.

The architecture comprised of three resource groups:

Identity: This resource group focused on security, incorporating Azure Security Center, Azure Key Vault, and policy definitions to ensure robust governance and compliance.

Management/Logging: Hosting Log Analytics Workspaces, this group facilitated centralized monitoring and management, enhancing operational efficiency.

Network: Serving as the connectivity backbone, this group included firewall configurations, Virtual Hub, Virtual WAN, DNS configurations, Network Security Groups (NSG) and Application Security Groups (ASG) to ensure secure network communication.

Application: This group housed the essential components for application functionality, including Virtual Network (VNet), Load Balancer for the front-end, Virtual Machine (VM) for the application-end, SQL Server, and SQL Database for the database-end.

To automate my infrastructure deployment and ensure security, I utilized Azure DevOps to create a CI/CD pipeline. The pipeline integrated Terraform for provisioning and Trivy for misconfiguration scanning , streamlining deployment and ensuring adherence to security standards.

I additionally implemented a clean-up stage to facilitate resource destruction upon approval, optimizing resource utilization and minimizing costs.

In conclusion, this project served as a valuable showcase of my skills in cloud architecture, infrastructure automation, and security, demonstrating my proficiency in cloud technologies and DevOps tools.








