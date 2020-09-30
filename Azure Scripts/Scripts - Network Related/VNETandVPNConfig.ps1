## How to create a VNET and VPN

## Define the variables that will be used for the script

$VNetName  = "NameOfYourVNET"
$FESubName = "FrontEnd"
$BESubName = "Backend"
$GWSubName = "GatewaySubnetName"
$VNetPrefix1 = "192.168.0.0/16"
$VNetPrefix2 = "10.254.0.0/16"
$FESubPrefix = "192.168.1.0/24"
$BESubPrefix = "10.254.1.0/24"
$GWSubPrefix = "192.168.200.0/26"
$VPNClientAddressPool = "172.16.201.0/24"
$ResourceGroup = "RGNAME"
$Location = "LocationName"
$GWName = "NameofGW"
$GWIPName = "NameofGWIP"
$GWIPconfName = "NameOfConfigFile"

## Create a Resource group
New-AzResourceGroup -Name $ResourceGroup -Location $Location

## Create subnets, variables defined are frontend backend and gateway subnet. Have to be within VNET Prefix (address space)
$fesub = New-AzVirtualNetworkSubnetConfig -Name $FESubName -AddressPrefix $FESubPrefix
$besub = New-AzVirtualNetworkSubnetConfig -Name $BESubName -AddressPrefix $BESubPrefix
$gwsub = New-AzVirtualNetworkSubnetConfig -Name $GWSubName -AddressPrefix $GWSubPrefix

## Create a VNET with the subnet values defined and use a static address for the DNS
New-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroup -Location $Location -AddressPrefix $VNetPrefix1,$VNetPrefix2 -Subnet $fesub, $besub, $gwsub -DnsServer 8.8.8.8

## Now define the variables for the network that was just created
$vnet = Get-AzVirtualNetwork -Name $VNetName -ResourceGroupName $ResourceGroup
$subnet = Get-AzVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $vnet

## Dynamically assign a Public IP 
$pip = New-AzPublicIpAddress -Name $GWIPName -ResourceGroupName $ResourceGroup -Location $Location -AllocationMethod Dynamic
$ipconf = New-AzVirtualNetworkGatewayIpConfig -Name $GWIPconfName -Subnet $subnet -PublicIpAddress $pip

## Create the VPN using the variables defined (wait for the command output to verify success)
New-AzVirtualNetworkGateway -Name $GWName -ResourceGroupName $ResourceGroup `
-Location $Location -IpConfigurations $ipconf -GatewayType Vpn `
-VpnType RouteBased -EnableBgp $false -GatewaySku VpnGw1 -VpnClientProtocol "IKEv2"

## CERTIFICATE IS CREATED ON THE WINDOWS MACHINE
## USES POWERSHELL, AZURE POWERSHELL AND WINDOWS CERT MANAGER UTILITY
## Generate a Self Signed Root Certificate 
$cert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
-Subject "CN=P2SRootCert" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign

## Create a Child Cert 
New-SelfSignedCertificate -Type Custom -DnsName P2SChildCert -KeySpec Signature `
-Subject "CN=P2SChildCert" -KeyExportPolicy Exportable `
-HashAlgorithm sha256 -KeyLength 2048 `
-CertStoreLocation "Cert:\CurrentUser\My" `
-Signer $cert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")