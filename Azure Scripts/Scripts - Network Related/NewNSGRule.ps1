# This script creates a new Network Security Rule Config given the content of a CSV file and the Network Security Group rule definition below.
# The script checks the Network Security Rules in the CSV file and increments the priority to the next available value, then creates the new rule config on each NSG listed.

# To use:
# 1) Update the .\NewNSGRule.csv file with the names of the NSG's to update
# 2) Sign into the destination tenant and set context to the subscription you'll be working in
# Examples
# Connect-AzAccount -Tenant TENANTNAME
# Set-AzContext -SubscriptionId $SubscriptionID
# 3) Run the Script
# .\NewNSGRule.ps1

## variables for connecting into Azure
$TenantId = "";
$SubscriptionId = "";

# CSV File containing the resource group and network security group names
$CSVFile = ".\FILEPATH.csv"

# you can comment out the Connect-AzAccount line if you are running
# in the same environment multiple times
Connect-AzAccount -Tenant $TenantId
Set-AzContext -SubscriptionId $SubscriptionId

# Variables for New NSG Rule Criteria
$RuleName = "NAME" # Name
$Desc = "SHORT DESCRIPTION" #Description
$SrcIP = "192.168.0.1", "127.0.0.1" # Source Information
$DestIP = "*" # Destination Information
$Proto = "TCP" # IP Protocol
$DestPort = "3389" # Destination Port
$SrcPort = "*" # Source Port
$Action = "Allow" # Action - Allow or Deny
$Priority = "222" # Default Priority, will be incremented to the next highest available free rule. Valid values are between 100 to 4096
$Direction = "Inbound" # Direction - Inbound or Outbound

# Import the CSV File and don't process the headers in the for loop
$objCSV = Import-Csv -Path $CSVFile | Select-Object -Skip 0

# The Resource Type for a Network Security Group
$AzureResourceType = "Microsoft.Network/networkSecurityGroups"

# Collect the rule priorities now so we can search for potential collisions later

$aRules = @()
$i = 0
$ii = 0

$objCSV | ForEach-Object {
    $i++
    $NSGName = "$($_.NSGName)"

    Write-Host "Querying Line $i : $NSGName"

    # Get the resource from Azure given the name from the CSV File
    $AzResource = Get-AzResource -Name $NSGName

    $NSGName = "$($AzResource.Name)"
    $RGName = "$($AzResource.ResourceGroupName)"


    # Validate we're working with an object of the expected type for NSG
    If ($AzResource.ResourceType -eq $AzureResourceType ) {

        #$NSG = Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $RGName
        $aRules += $(Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $RGName).SecurityRules.Priority

    }

}

# Create an empty array to store our processing of the priorities
$matchtable = New-Object 'object[,]'2, 3997

# Loop through the rule priority values we collected earlier and set the relative Azure Priority number
# Start and End loop on the minimum/maximum Azure rule Priority limits
For ($s = 100 ; $s -le 4096; $s++) {

    # Set our array index to position 0
    $index = $s - 100

    # For a given array position, set what the rule number is in the array
    # write-host $index, $s
    $matchtable[0, $index] = $s

}

# Loop through the collected priorities from Azure and identify that these are in use
$aRules | ForEach-Object {
    $index = ($_ / 1) - 100
    if ($index -ge 0) {
        #write-host $index
        $matchtable[1, $index] = "Used" 
    }
}

# Locate the first unused rule priority number given the priorities and in-use status stored in the array
For ($s = 0 ; $s -le 3997; $s++) {

    $p1 = $matchtable[0, $s] / 1
    $p2 = $Priority / 1

    if ($matchtable[1, $s] -ne "Used" -and $p1 -ge $p2 ) {

        write-host "Old Priority was $($Priority), New Priority is $($p1)"

        # Set the new priority for use later in the script
        $Priority = $matchtable[0, $s]

        # Exit the loop once we've identified the first free rule priority
        Break
    }

}


# Confirm the Priority value for the update is not an in-use value.
$Priority = $Priority / 1
$check = $Priority - 100
if ($matchtable[1, $check] -eq "Used") {
    write-host "Planned priority $($Priority) is in use, probably out of space in the NSG rules. Please check before continuing"
    exit
}

# Exit the script if the Priority value is not within a range Azure would accept
if ($Priority -ge 100 -and $Priority -le 4096) {
    write-host "Priority is valid, continuing"
}

else
{
    write-host "Outside bounds. Please check Priority values"
    exit
}


# Loop through each row in the CSV file
$objCSV | ForEach-Object {
    $ii++
    # Assign the CSV File values to variables we can work with

    $NSGName = "$($_.NSGName)"

    Write-Host "Processing Line $ii of $i : $NSGName"

    # Get the resource from Azure given the name from the CSV File
    $AzResource = Get-AzResource -Name $NSGName


    # Validate we're working with an object of the expected type for NSG
    If ($AzResource.ResourceType -eq $AzureResourceType ) {

        Write-Host "Updating Azure Resource Name $($AzResource.Name) with Type $($AzResource.ResourceType)"

        # Get the Resource Group name from that resource
        $NSGName = "$($AzResource.Name)"
        $RGName = "$($AzResource.ResourceGroupName)"

        # Get the Network Security Group info
        $NSG = Get-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $RGName

        # Add the new Network Security Group Rule to the Network Security Group
        $NSG | Add-AzNetworkSecurityRuleConfig `
            -Name $RuleName `
            -Description $Desc `
            -Access $Action `
            -Protocol $Proto `
            -Direction $Direction `
            -Priority $Priority `
            -SourceAddressPrefix $SrcIP `
            -SourcePortRange $SrcPort `
            -DestinationAddressPrefix $DestIP `
            -DestinationPortRange $DestPort | Out-Null

        #Write the Network Security Group with the new rule
        $NSG | Set-AzNetworkSecurityGroup | Out-Null
    }
    else { Write-Host "Found Azure Resource with Name $($_.NSGName) but different type, ignoring" }
}