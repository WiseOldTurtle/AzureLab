# *Azure Landing Zone Project: Terraform, Azure DevOps, Security*

**Main Goal**

**Key Tasks and Points:**
- **DONE** Replace ARM templates and Release Pipeline with Terraform and YAML pipeline for CI/CD 
- **DONE** Aim to see if I can get some smart logic added into Terraform templates using local variables to create loops for repetitive areas such as Vnets and Subnets.
 - *Added in some logic using a ForEach and a Count to iterate VNets and Subnets*
- **DONE** See if I can get the YAML pipeline to pick up the backend.tf so I do not need to declare it in the YAML (to keep the YAML neater)
 - *Added in the backend.tf reference within the main.tf for each directory*
- **DONE** Add a task to destroy resources built to ensure costs are low.
 - *Added in some logic which enables the use of parameters to the pipeline. (Allows the user to select the either Plan, Apply or Destroy)*
- **DONE** Shorten the template and make it more useable
 - *updated template is* **AzureLab\terraform\azure-pipelines-v2.yaml** Made the following changes:
  - Added in testing in the form of trivy (exports reports as artifact to pipeline run)
  - realised that the pipeline tasks were repeatable, see original **AzureLab\terraform\azure-pipelines.yaml** so I added in a for each loop to loop through the directories.
  - Due to the 3 different directories, 3 different state files are created alongside so they need to be referenced in the pipeline.

## **Architecture:** 

(Need to add drawing here)

**Tools:**
- app.eraser.io (Designing Landing Zone Architecture)
- Terraform (Infrastracture As Code)
- Azure (Cloud Infrastructure)
- Azure DevOps (CI/CD Pipelines + Git)
- Trivy (IAC Misconfiguration Scanning)

**Through the integration of these tools, I successfully:**
- Designed an Azure Landing Zone
- Provisioned Azure infrastructure using Terraform infrastructure as code
- Stored the terraform state file in a remote backend in an azure blob container
- Effectively automated the build process for my Terraform infrastructure using Azure Pipelines
- Integrated Trivy for insights into misconfigurations in my Terraform IAC code
- Added in parameters so the pipeline can run specific Terraform commands such as Plan, Apply and Destroy. 

## **Terraform Structure:**
``` BASH
/terraform
   ├── /networking
   │     ├── main.tf          # VNETs and subnets (private)
   │     ├── variables.tf     # Variables for networking
   │     ├── terraform.tfvars # Loop reference for subnet and vnet deployment
   │     ├── outputs.tf       # Outputs from the networking module (not currently being used)
   ├── /security
   │     ├── main.tf          # NSG rules for traffic control
   │     ├── variables.tf     # Variables for NSGs
   │     ├── outputs.tf       # Outputs from the security module (not currently being used)
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

trigger: none

pool:
  vmImage: 'ubuntu-latest'

parameters:
  - name: Action
    displayName: Action
    type: string
    default: 'Plan'
    values:
    - Plan
    - Apply
    - Destroy

variables:
  - group: WiseOldTurtleSP  # Variable group containing SP details
  - group: terraform        # Variable group containing Terraform-related variables
  - name: directories
    value: "networking,security,policy"
  - name: action
    value: ${{ parameters.Action }}

stages:
  - stage: RunTesting
    jobs:
      - job: RunTrivy
        steps:
          # Download and Install Trivy
          - task: CmdLine@2
            displayName: 'Download and Install Trivy vulnerability scanner'
            inputs:
              script: |
                sudo apt-get update
                sudo apt-get install rpm -y
                wget https://github.com/aquasecurity/trivy/releases/download/v0.20.0/trivy_0.20.0_Linux-64bit.deb
                sudo dpkg -i trivy_0.20.0_Linux-64bit.deb
                trivy -v

          # Run Trivy for LOW and MEDIUM severity issues (scans all .tf files within /terraform)
          - task: CmdLine@2
            displayName: 'LOW/MED - Trivy vulnerability scanner in IaC mode for Terraform files'
            inputs:
              script: |
                mkdir -p trivy-reports  # Create a directory to store scan results
                for file in $(find $(System.DefaultWorkingDirectory)/terraform -name "*.tf"); do
                trivy config --severity LOW,MEDIUM --exit-code 0 --format json --output trivy-reports/$(basename $file)_lowmed.json "$file"
                done

          # Run Trivy for HIGH and CRITICAL severity issues (scans all .tf files within /terraform)
          - task: CmdLine@2
            displayName: 'HIGH/CRIT - Trivy vulnerability scanner in IaC mode for Terraform files'
            inputs:
              script: |
                for file in $(find $(System.DefaultWorkingDirectory)/terraform -name "*.tf"); do
                trivy config --severity HIGH,CRITICAL --exit-code 0 --format json --output trivy-reports/$(basename $file)_highcrit.json "$file"
                done

          # Publish Trivy Scan Results as a Build Artifact
          - task: PublishBuildArtifacts@1
            displayName: 'Publish Trivy scan results as a build artifact'
            inputs:
              PathtoPublish: 'trivy-reports'
              ArtifactName: 'TrivyScanResults'
              publishLocation: 'Container'

  - stage: SetupCore
    jobs:
      - job: CreateBackendResources
        displayName: 'Create AZ Storage Account and Container'
        steps:
          # Authenticate using SP in AZ CLI
          - script: |
              az login --service-principal \
                --username $(TF_VAR_client_id) \
                --password $(TF_VAR_client_secret) \
                --tenant $(TF_VAR_tenant_id)
            displayName: 'Azure Login with SP for CLI'

          # Create Resource Group
          - script: |
              az group create --name $(backendRGName) --location "UK South"
            displayName: 'Create Resource Group'

          # Create Storage Account with Private Access
          - script: |
              az storage account create \
                --name $(backendStorageAccountName) \
                --resource-group $(backendRGName) \
                --location "UK South" \
                --sku Standard_LRS \
                --kind StorageV2 \
                --access-tier Hot 
          #     --public-network-access disabled
            displayName: 'Create Storage Account'

          # Retrieve Storage Account Key for container creation
          - script: |
              ACCOUNT_KEY=$(az storage account keys list --resource-group $(backendRGName) \
              --account-name $(backendStorageAccountName) --query '[0].value' -o tsv)
              echo "##vso[task.setvariable variable=ACCOUNT_KEY]$ACCOUNT_KEY"
              export ARM_ACCESS_KEY=$ACCOUNT_KEY
            displayName: 'Retrieve Storage Account Key'

          # Create Storage Container using the retrieved key
          - script: |
              az storage container create \
                --name $(backendContainerName) \
                --account-name $(backendStorageAccountName) \
                --account-key $(ACCOUNT_KEY)
            displayName: 'Create Storage Container for Terraform Backend'

  - stage: DeployCoreResources
    condition: ne('${{ parameters.Action }}', 'Destroy')
    jobs:
      - job: DeployResources
        displayName: 'Deploy Core Resources'
        steps:
          # Install Terraform
          - task: TerraformInstaller@0
            displayName: 'Install Terraform'
            inputs:
              terraformVersion: 'latest'

          # Loop through directories
          - ${{ each dir in split(variables.directories, ',') }}:
            - task: TerraformTaskV2@2
              displayName: 'Terraform Init (${{ dir }})'
              inputs:
                provider: 'azurerm'
                command: 'init'
                backendServiceArm: 'wiseoldturtle-terraform-sp'
                backendAzureRmResourceGroupName: $(backendRGName)
                backendAzureRmStorageAccountName: $(backendStorageAccountName)
                backendAzureRmContainerName: $(backendContainerName)
                backendAzureRmKey: '${{ dir }}.tfstate'
                workingDirectory: '$(System.DefaultWorkingDirectory)/terraform/${{ dir }}'

            - task: TerraformTaskV2@2
              displayName: 'Terraform Plan (${{ dir }})'
              condition: and(succeeded(), eq(variables['Action'], 'Plan'))
              inputs:
                provider: 'azurerm'
                command: 'plan'
                workingDirectory: '$(System.DefaultWorkingDirectory)/terraform/${{ dir }}'
                environmentServiceNameAzureRM: 'wiseoldturtle-terraform-sp'
            
            - task: TerraformTaskV2@2
              displayName: 'Terraform Apply (${{ dir }})'
              condition: and(succeeded(), eq(variables['Action'], 'Apply'))
              inputs:
                provider: 'azurerm'
                command: 'apply'
                workingDirectory: '$(System.DefaultWorkingDirectory)/terraform/${{ dir }}'
                environmentServiceNameAzureRM: 'wiseoldturtle-terraform-sp'

  - stage: terraform_destroy
    condition: eq('${{ parameters.Action }}', 'Destroy')
    jobs:
      - job: terraform_destroy
        displayName: 'Destroy Resources'
        steps:
          - task: TerraformInstaller@0
            displayName: 'Install Terraform'
            inputs:
              terraformVersion: 'latest'
          
          # Loop through directories
          - ${{ each dir in split(variables.directories, ',') }}:
            - task: TerraformTaskV2@2
              displayName: 'Terraform Init (${{ dir }})'
              inputs:
                provider: 'azurerm'
                command: 'init'
                backendServiceArm: 'wiseoldturtle-terraform-sp'
                backendAzureRmResourceGroupName: $(backendRGName)
                backendAzureRmStorageAccountName: $(backendStorageAccountName)
                backendAzureRmContainerName: $(backendContainerName)
                backendAzureRmKey: '${{ dir }}.tfstate'
                workingDirectory: '$(System.DefaultWorkingDirectory)/terraform/${{ dir }}'

            - task: TerraformTaskV2@2
              displayName: 'Terraform Destroy (${{ dir }})'
              condition: and(succeeded(), eq(variables['Action'], 'Destroy'))
              inputs:
                provider: 'azurerm'
                command: 'destroy'
                backendAzureRmKey: '${{ dir }}.tfstate'
                workingDirectory: '$(System.DefaultWorkingDirectory)/terraform/${{ dir }}'
                environmentServiceNameAzureRM: 'wiseoldturtle-terraform-sp'
```


# **Project Summary:** *Azure Landing Zone Deployment*

## **Evaluation:**

- My initial landing zone deployment was done via the use of ARM Templates and a release pipeline. I wanted to change it up and show case the use of terraform 

I developed an Azure Landing Zone utilizing Terraform, showcasing my proficiency in cloud architecture and infrastructure as code (IaC). The project aimed to demonstrate my skills and enhance my resume by showcasing my ability to design and deploy Azure resources efficiently.






