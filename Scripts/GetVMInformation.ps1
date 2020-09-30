
$objarray = @() # Create array to hold objects to be written to .csv
Get-AzVM | `
ForEach-Object -Process { `
    $os = $($_.StorageProfile.OsDisk.OsType) # Retrieve OS VM is runing
    $vmsize = $($_.HardwareProfile.VmSize)
    $tags = $_.Tags | ForEach-Object -Process { [string]::Join(";", $_) } # "Flatten" the tags in the Tags object into a single column for export
    $hash = [ordered]@{
        "VmName"   = $_.Name;
        "FQDN"   = $_.PlatformUpdateDomain
        "Location"   = $_.Location;
        "Tags"     = $tags;
    }
    $obj = New-Object -TypeName System.Management.Automation.PSObject -Property $hash
    $objarray += $obj
}
$objarray | Sort-Object -Property VmName | Export-Csv "$HOME\Desktop\ProductionVMList-$(Get-Date -Format FileDateTime).csv" -NoTypeInformation