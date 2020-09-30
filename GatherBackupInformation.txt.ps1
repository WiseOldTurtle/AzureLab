﻿## Get Backup Information

## Connect to the Azure Powershell
Connect-AzAccount

## Connect to the Appropriate Subscription
Select-AzSubscription [SubscriptionName]


## Set the Variable to List all Vaults in Subscription
$PVaults = Get-AzRecoveryServicesVault

## ForEach statement using the _iterator so the Get-RSV output can be interrogated line per line. 
foreach ($PVaults_iterator in $PVaults) {

    $vault = Get-AzRecoveryServicesVault -Name $PVaults_iterator
    Get-AzRecoveryServicesBackupJob -From (Get-Date).AddDays(-1).ToUniversalTime() -Operation Backup -Status Failed -VaultId $PVaults_iterator.ID

}