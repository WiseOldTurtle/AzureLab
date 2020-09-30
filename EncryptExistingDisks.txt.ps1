
## Define some useful variables
$vmName = "MachineName"
$rgName = "ReourceGroupOfMachine"
$vm = Get-AzVM -Name $vmName -ResourceGroupName $rgName

## Verify Status of OSDisk to confirm what operating system if you do not know already
$vm.StorageProfile.OSDisk

##  Verify if the disks are encrypted
Get-AzVmDiskEncryptionStatus`-ResourceGroupName $rgName -VMName $vmName

## Set the variables for the KeyVault (Please do not create a new keyVault without confirmation and change approval)
$keyVault = Get-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $rgName

## Command to encrpyt the disks (you will get a prompt if successful, click yes for the prompt)
Set-AzVmDiskEncryptionExtension `
	-ResourceGroupName $rgName `
    -VMName $vmName `
    -VolumeType  All | Data | OS `
	-DiskEncryptionKeyVaultId $keyVault.ResourceId `
	-DiskEncryptionKeyVaultUrl $keyVault.VaultUri `
    -SkipVmBackup

## Confirm the Encryption has been applied
Get-AzVmDiskEncryptionStatus  -ResourceGroupName $rgName -VMName $vmName