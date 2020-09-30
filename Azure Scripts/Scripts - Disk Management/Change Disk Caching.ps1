## Define some Variables for your VM and RG
$myRgName = [ResourceGroupName]
$myVMName = [VMName]

## Set a Variable to gather information about your VM
$myVM = Get-AzVM -ResourceGroupName $myRgName -VMName $myVmName

## Furhter breakdown the variable with another to gather the properties of the VM through Select-Object
$myVM | select-object -property ResourceGroupName, Name, Type, Location

## ___________________________OS DISK CACHING______________________________##

## Verify the current Caching status of the VM (it will output the result)
$myVM.StorageProfile.OsDisk.Caching

## Adjust the VM Caching Option by ammending the above variable (see below)
$myVM.StorageProfile.OsDisk.Caching = "ReadWrite"

## You need to apply that change to the VM as it will only update the MyVM Object if you dont.
Update-AzVM -ResourceGroupName $myRGName -VM $myVM

## Verify the change has completed (You can also check in the portal)
$myVM = Get-AzVM -ResourceGroupName $myRgName -VMName $myVmName
$myVM.StorageProfile.OsDisk.Caching

## ____________________________DATA DISK CACHING____________________________##

## To see what Data disks you have run this command
$myVM.StorageProfile.DataDisks

## Add a new Disk (for convenience we will store the Disk name as a Variable)
$newDiskName = [DiskName]

## Run this command to configure a 1GB Disk (LUN value has to be not taken if defined)
Add-AzVMDataDisk -VM $myVM -Name $newDiskName  -LUN 1  -DiskSizeinGB 1 -CreateOption Empty

## You need to apply that change to the VM as it will only update the MyVM Object if you dont.
Update-AzVM -ResourceGroupName $myRGName -VM $myVM

## Verify the Data Disk info 
$myVM.StorageProfile.DataDisks

## Change the Cache settings for the New Data Disk (You will need to define the LUN)
Set-AzVMDataDisk -VM $myVM -Lun "1" -Caching ReadWrite


