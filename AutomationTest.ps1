<#
    .DESCRIPTION
        A runbook which Shuts Down all running VM's tagged with AutoStart tag matching the value of time,
        using the Run As Account (Service Principal)

    .NOTES
        Author:  Craig Fretwell
        Company: New Signature 
        Updated: June 19, 2020
#>


# Connecting to Azure using the AzureRunAsConnection.
$conn = Get-AzAutomationConnection -Name "AzureRunAsConnection"
$null = Connect-AzAccount -ServicePrincipal -Tenant $conn.TenantId -ApplicationId $conn.ApplicationId -CertificateThumbprint $conn.CertificateThumbprint

# Keys & Values are case sensitive please be aware of that when modifying the script
$VMs = Get-AzVm  |  Where { $_.Tags.Keys -contains "AutoStart" -and $_.Tags.Values -contains "PrePatching" } | Select Name, ResourceGroupName, Tags
ForEach ($VM in $VMs) {
    $VMStatus = Get-AzVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName -Status |
    Select Name, ResourceGroupName, DisplayStatus, Tags
    $VMN = $VM.Name
    $VMRG = $VM.ResourceGroupName
    If ($VMStatus = "VM deallocated") {
        Start-AzureRMVM -Name $VMN -ResourceGroupName $VMRG
        "$VMN Started"
    }
                   
}