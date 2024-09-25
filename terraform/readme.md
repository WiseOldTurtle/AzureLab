# *Azure Landing Zone Project: Terraform, Azure DevOps, Security*

**Key Tasks and Points:**
- **DONE** Aim to see if I can get some smart logic added into Terraform templates using local variables to create loops for repetitive areas such as Vnets and Subnets.
-- *Added in some logic using a ForEach and a Count to iterate VNets and Subnets*
- See if I can get the YAML pipeline to pick up the backend.tf so I do not need to declare it in the YAML (to keep the YAML neater)
- Add a task to destroy resources built to ensure costs are low.
- Add in some sort of testing to the pipeline, through the use of trivy or terratest. Trivy sample is below (got it to work in early code):

``` YAML
- task: CmdLine@2
      displayName: 'Download and Install Trivy vulnerability scanner'
      inputs:
        script: |
          sudo apt-get install rpm
           wget https://github.com/aquasecurity/trivy/releases/download/v0.20.0/trivy_0.20.0_Linux-64bit.deb
          sudo dpkg -i trivy_0.20.0_Linux-64bit.deb
          trivy -v

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
```

## **Architecture:** 


Tools:
- app.eraser.io (Designing Landing Zone Architecture)
- Azure (Cloud Infrastructure)
- Terraform (Infrastracture As Code)
- Azure DevOps (CI/CD Pipelines + Git Version Control)
- Trivy (IAC Misconfiguration Scanning) or Terratest integration (TO DO)

**Through the integration of these tools, I successfully:**
- Designed an Azure Landing Zone
- Provisioned Azure infrastructure using Terraform infrastructure as code
- Stored the terraform state file in a remote backend in an azure blob container
- Effectively automated the build process for my Terraform infrastructure using Azure Pipelines
- Integrated Trivy for insights into misconfigurations in my Terraform IAC code
- Published the build as an artifact and configured continuous deployment to be triggered by the build artifact and deploy the Terraform infrastructure.
- Added another stage to my release pipeline to automatically cleanup the resources on approval to optimize resource utilization and minimize costs. (TO DO)

## **Terraform Configuration:**
``` BASH
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
```


## **Azure DevOps Pipeline:**
Build Pipeline:
YAML:
``` YAML
name: $(BuildDefinitionName)_$(date:yyyyMMdd)$(rev:.r)

trigger:
  branches:
    include:
      - master

pool:
  vmImage: 'ubuntu-latest'

variables:
  - group: WiseOldTurtleSP  # Variable group containing SP details
  - group: terraform        # Variable group containing Terraform-related variables
  - name: TF_VARS_subscription_id
    value: $(TF_VARS_subscription_id)  # Reference the variable from the Azure DevOps variable group

stages:
  - stage: SetupBackend
    jobs:
      - job: CreateBackendResources
        displayName: 'Create Backend Resources'
        steps:
          # Step 1: Azure CLI Login using Service Principal
          - script: |
              az login --service-principal \
                --username $(TF_VAR_client_id) \
                --password $(TF_VAR_client_secret) \
                --tenant $(TF_VAR_tenant_id)
            displayName: 'Azure Login with SP'

          # Resource Group Creation
          - script: |
              az group create --name $(backendAzureRmResourceGroupName) --location "UK South"
            displayName: 'Create Resource Group'

          # Create Storage Account with Private Access
          - script: |
              az storage account create \
                --name $(backendAzureRmStorageAccountName) \
                --resource-group $(backendAzureRmResourceGroupName) \
                --location "UK South" \
                --sku Standard_LRS \
                --kind StorageV2 \
                --access-tier Hot 
          #     --public-network-access disabled
            displayName: 'Create Storage Account'

          # # Set Network Rules for Storage Account  
          # - script: |
          #     az storage account network-rule add \
          #       --resource-group $(backendAzureRmResourceGroupName) \
          #       --account-name $(backendAzureRmStorageAccountName) \
          #       --bypass AzureServices \
          #       --vnet \
          #       --subnet 
          #   displayName: 'Configure Network Rules for Storage Account'

          # Retrieve Storage Account Key for container creation
          - script: |
              STORAGE_ACCOUNT_KEY=$(az storage account keys list \
                --resource-group $(backendAzureRmResourceGroupName) \
                --account-name $(backendAzureRmStorageAccountName) \
                --query '[0].value' \
                --output tsv)
              echo "##vso[task.setvariable variable=STORAGE_ACCOUNT_KEY]$STORAGE_ACCOUNT_KEY"
            displayName: 'Retrieve Storage Account Key'

          # Create Storage Container using the retrieved key
          - script: |
              az storage container create \
                --name tfstate \
                --account-name $(backendAzureRmStorageAccountName) \
                --account-key $(STORAGE_ACCOUNT_KEY)
            displayName: 'Create Storage Container for Terraform Backend'


  - stage: DeployCoreResources
    jobs:
      - job: DeployNetworking
        displayName: 'Deploy Networking Resources'
        steps:
          # Step 5: Initialize Terraform and deploy resources for Networking
          - task: TerraformInstaller@0
            displayName: 'Install Terraform'
            inputs:
              terraformVersion: 'latest'

          - task: TerraformTaskV2@2
            displayName: 'Terraform Init (Networking)'
            inputs:
              provider: 'azurerm'
              command: 'init'
              backendServiceArm: 'wiseoldturtle-terraform-sp'
              backendAzureRmResourceGroupName: $(backendAzureRmResourceGroupName)
              backendAzureRmStorageAccountName: $(backendAzureRmStorageAccountName)
              backendAzureRmContainerName: 'tfstate'
              backendAzureRmKey: 'networking.tfstate'
              workingDirectory: '$(System.DefaultWorkingDirectory)/terraform/networking'

          - task: TerraformTaskV2@2
            displayName: 'Terraform Plan (Networking)'
            inputs:
              provider: 'azurerm'
              command: 'plan'
         #    commandOptions: '-var subscription_id=$(TF_VARS_subscription_id)'
              workingDirectory: '$(System.DefaultWorkingDirectory)/terraform/networking'
              environmentServiceNameAzureRM: 'wiseoldturtle-terraform-sp'

          - task: TerraformTaskV2@2
            displayName: 'Terraform Apply (Networking)'
            inputs:
              provider: 'azurerm'
              command: 'apply'
              commandOptions: '-auto-approve'
              workingDirectory: '$(System.DefaultWorkingDirectory)/terraform/networking'
              environmentServiceNameAzureRM: 'wiseoldturtle-terraform-sp'

      - job: DeploySecurity
        displayName: 'Deploy Security Resources'
        steps:
          # Step 6: Initialize Terraform and deploy resources for Security
          - task: TerraformTaskV2@2
            displayName: 'Terraform Init (Security)'
            inputs:
              provider: 'azurerm'
              command: 'init'
              backendServiceArm: 'wiseoldturtle-terraform-sp'
              backendAzureRmResourceGroupName: $(backendAzureRmResourceGroupName)
              backendAzureRmStorageAccountName: $(backendAzureRmStorageAccountName)
              backendAzureRmContainerName: 'tfstate'
              backendAzureRmKey: 'security.tfstate'
              workingDirectory: '$(System.DefaultWorkingDirectory)/terraform/security'

          - task: TerraformTaskV2@2
            displayName: 'Terraform Plan (Security)'
            inputs:
              provider: 'azurerm'
              command: 'plan'
          #   commandOptions: '-var subscription_id=$(TF_VARS_subscription_id)'
              workingDirectory: '$(System.DefaultWorkingDirectory)/terraform/security'
              environmentServiceNameAzureRM: 'wiseoldturtle-terraform-sp'

          - task: TerraformTaskV2@2
            displayName: 'Terraform Apply (Security)'
            inputs:
              provider: 'azurerm'
              command: 'apply'
              commandOptions: '-auto-approve'
              workingDirectory: '$(System.DefaultWorkingDirectory)/terraform/security'
              environmentServiceNameAzureRM: 'wiseoldturtle-terraform-sp'

      - job: DeployPolicy
        displayName: 'Deploy Policy Resources'
        steps:
          # Initialize Terraform and deploy resources for Policy
          - task: TerraformInstaller@0
            displayName: 'Install Terraform'
            inputs:
              terraformVersion: 'latest'

          - task: TerraformTaskV2@2
            displayName: 'Terraform Init (Policy)'
            inputs:
              provider: 'azurerm'
              command: 'init'
              backendServiceArm: 'wiseoldturtle-terraform-sp'
              backendAzureRmResourceGroupName: $(backendAzureRmResourceGroupName)
              backendAzureRmStorageAccountName: $(backendAzureRmStorageAccountName)
              backendAzureRmContainerName: 'tfstate'
              backendAzureRmKey: 'policy.tfstate'
              workingDirectory: '$(System.DefaultWorkingDirectory)/terraform/policy'

          - task: TerraformTaskV2@2
            displayName: 'Terraform Plan (Policy)'
            inputs:
              provider: 'azurerm'
              command: 'plan'
          #   commandOptions: '-var subscription_id=$(TF_VARS_subscription_id)'
              workingDirectory: '$(System.DefaultWorkingDirectory)/terraform/policy'
              environmentServiceNameAzureRM: 'wiseoldturtle-terraform-sp'

          - task: TerraformTaskV2@2
            displayName: 'Terraform Apply (Policy)'
            inputs:
              provider: 'azurerm'
              command: 'apply'
              commandOptions: '-auto-approve'
              workingDirectory: '$(System.DefaultWorkingDirectory)/terraform/policy'
              environmentServiceNameAzureRM: 'wiseoldturtle-terraform-sp'
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








