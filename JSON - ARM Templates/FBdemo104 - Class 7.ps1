$location = 'westeurope'
$rgname = 'az104-07-rg0'

New-AzResourceGroupDeployment `
    -ResourceGroupName $rgName `
    -TemplateFile $HOME/az104-07-vm-template.json `
    -TemplateParameterFile $HOME/az104-07-vm-parameters.json `
    -AsJob 


## Clean Up 
Get-AzResourceGroup -Name 'az104-09a*'

Get-AzResourceGroup -Name 'az104-09a*' | Remove-AzResourceGroup -Force -AsJob

**Note**: The command executes asynchronously (as determined by the -AsJob parameter), so while you will be able to run another PowerShell command immediately afterwards within the same PowerShell session, it will take a few minutes before the resource groups are actually removed.

