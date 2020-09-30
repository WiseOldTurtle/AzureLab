## Create a Key Vault (the -EnabledForDiskEncryption command is to allow the Key vault to support ADE)
New-AzKeyVault -Location <location> `
    -ResourceGroupName <resource-group> `
    -VaultName "myKeyVault" `
    -EnabledForDiskEncryption
	
	
## 3 policies are available - DiskEncryption (to enable ADE), Deployment (Reference for VM Creation), Template Deployment (Same as previous however, via a Template)
Set-AzKeyVaultAccessPolicy -VaultName <keyvault-name> -ResourceGroupName <resource-group> -EnabledForDiskEncryption

## Prior to enabling encryption you must ensure the Managed Disk is backed up
## The Set-AzVmDiskEncryptionExtension command can be altered to include the -skipvmbackup 
## Purpose of the backup is so the VM can be recovered if Encryption fails for some reason
## Windows Disks should be formatted to NTFS Volumes to be encrypted


## Chooe either All , OS , DATA (All is both OS and the Data disk) Some linux Distros only allow DATA
Set-AzVmDiskEncryptionExtension `
    -ResourceGroupName <resource-group> `
    -VMName <vm-name> `
    -VolumeType [All | OS | Data]
-DiskEncryptionKeyVaultId <keyVault.ResourceId> `
    -DiskEncryptionKeyVaultUrl <keyVault.VaultUri> `
    -SkipVmBackup;

##  To confirm if the managed Disks have been encrypted
Get-AzVmDiskEncryptionStatus  -ResourceGroupName <resource-group> -VMName <vm-name>

## Remember for a Windows VM you will need to run with ALL as you cannot just specify a Data Disk 9It will not allow you)
## To disable Encryption run the following command
Disable-AzVMDiskEncryption -ResourceGroupName <resource-group> -VMName <vm-name> -VolumeType All